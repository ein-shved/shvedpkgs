//! Runtime candidates and native-shell context for the upstream completer.

use std::ffi::OsString;
use std::io::{self, Write};
use std::os::unix::ffi::OsStrExt;

use crate::{cli, config::Catalog};

/// Select the private completion protocol instead of executing a deployment.
pub const COMPLETION_ENV: &str = "NIXOS_CLI_COMPLETE";

#[derive(Clone, Copy)]
enum Shell {
    Bash,
    Zsh,
}

impl Shell {
    fn offset(self) -> usize {
        match self {
            Self::Bash => 0,
            Self::Zsh => 1,
        }
    }
}

#[derive(Debug, PartialEq, Eq)]
struct Context {
    words: Vec<OsString>,
    cursor: usize,
}

struct Completion {
    upstream: Context,
    candidates: Vec<OsString>,
}

fn complete(
    shell: Shell,
    words: Vec<OsString>,
    cursor: usize,
    catalog: &Catalog,
) -> io::Result<Completion> {
    let cursor = cursor
        .checked_sub(shell.offset())
        .filter(|&cursor| cursor > 0 && cursor < words.len())
        .ok_or_else(|| io::Error::new(io::ErrorKind::InvalidInput, "invalid completion cursor"))?;

    // Only words before the cursor have been committed. An exact current host
    // remains a candidate until the user advances to the next argument.
    let selected = cursor > 1 && words[1] != "--" && catalog.names().any(|name| words[1] == name);
    let start = 1 + usize::from(selected);
    let boundary = cursor > start && words[start] == "--";
    let upstream_start = start + usize::from(boundary);

    let candidates = if !boundary && cursor == start {
        let names: Vec<_> = if selected {
            Vec::new()
        } else {
            catalog.names().collect()
        };
        let mut command = cli::command(names)
            .mut_arg("rebuild_args", |arg| arg.value_hint(clap::ValueHint::Other));
        let partial = &words[cursor];
        // Avoid the engine's grouped short flags such as -hh for a complete -h.
        let prefix =
            if partial.as_bytes().starts_with(b"-") && !partial.as_bytes().starts_with(b"--") {
                OsString::from("-")
            } else {
                partial.clone()
            };
        clap_complete::engine::complete(&mut command, vec!["nixos".into(), prefix], 1, None)?
            .into_iter()
            .filter(|candidate| {
                candidate
                    .get_value()
                    .as_bytes()
                    .starts_with(partial.as_bytes())
            })
            .map(|candidate| candidate.get_value().to_owned())
            .collect()
    } else {
        Vec::new()
    };

    let upstream = Context {
        words: std::iter::once(OsString::from("nixos-rebuild"))
            .chain(words.into_iter().skip(upstream_start))
            .collect(),
        cursor: cursor - upstream_start + 1 + shell.offset(),
    };
    Ok(Completion {
        upstream,
        candidates,
    })
}

/// Handle a completion request when [`COMPLETION_ENV`] is set.
///
/// Arguments are the native shell cursor followed by its words, including the
/// command and current (possibly empty) word. Output is NUL-separated: upstream
/// cursor, word count, words, then wrapper candidates. Native shell scripts call
/// upstream in their existing completion context to retain contextual values.
///
/// # Errors
///
/// Rejects unknown shells, malformed cursors and failed completion/output.
pub fn from_env(catalog: &Catalog) -> anyhow::Result<bool> {
    let Some(shell) = std::env::var_os(COMPLETION_ENV) else {
        return Ok(false);
    };
    let shell = match shell.to_str() {
        Some("bash") => Shell::Bash,
        Some("zsh") => Shell::Zsh,
        _ => anyhow::bail!("unsupported completion shell {shell:?}"),
    };
    let mut args = std::env::args_os().skip(1);
    let cursor = args
        .next()
        .and_then(|value| value.to_str().and_then(|value| value.parse().ok()))
        .ok_or_else(|| anyhow::anyhow!("missing or invalid completion cursor"))?;
    let completion = complete(shell, args.collect(), cursor, catalog)?;
    let mut output = io::stdout().lock();
    for field in [
        OsString::from(completion.upstream.cursor.to_string()),
        OsString::from(completion.upstream.words.len().to_string()),
    ]
    .into_iter()
    .chain(completion.upstream.words)
    .chain(completion.candidates)
    {
        output.write_all(field.as_bytes())?;
        output.write_all(&[0])?;
    }
    Ok(true)
}

#[cfg(test)]
mod tests {
    use super::*;

    fn words(values: &[&str]) -> Vec<OsString> {
        values.iter().map(OsString::from).collect()
    }

    #[test]
    fn candidates_follow_catalog_and_cli_boundary() {
        let catalog = Catalog::from_env().unwrap();
        let local = catalog.names().next().unwrap();
        let catalog: Catalog = serde_json::from_value(serde_json::json!({
            local: {"target_host": "local.example"},
            "remote": {"target_host": "remote.example"},
            "switch": {"target_host": "collision.example"},
            "remote host's": {"target_host": "quoted.example"}
        }))
        .unwrap();
        let candidates = |args: &[&str], cursor| {
            complete(Shell::Bash, words(args), cursor, &catalog)
                .unwrap()
                .candidates
        };
        let first = candidates(&["nixos", ""], 1);
        for name in [local, "remote", "switch", "remote host's"] {
            assert!(first.contains(&name.into()), "{first:?}");
        }
        assert!(candidates(&["nixos", "rem"], 1).contains(&"remote".into()));
        for prefix in [&["nixos"][..], &["nixos", "remote"][..]] {
            for option in ["--help", "--version", "-h", "-V"] {
                let mut args = prefix.to_vec();
                args.push(option);
                let actual = candidates(&args, args.len() - 1);
                assert!(actual.contains(&option.into()), "{args:?}: {actual:?}");
            }
        }
        assert!(!candidates(&["nixos", "remote", ""], 2).contains(&"remote".into()));
        for args in [
            vec!["nixos", "--", ""],
            vec!["nixos", "remote", "--", ""],
            vec!["nixos", "switch", "boot", ""],
            vec!["nixos", "unknown", ""],
            vec!["nixos", "--flake", ""],
        ] {
            assert!(candidates(&args, args.len() - 1).is_empty());
        }
    }

    #[test]
    fn native_shell_adapters_receive_exact_upstream_context() {
        use std::os::unix::ffi::OsStringExt;

        let catalog: Catalog = serde_json::from_str(
            r#"{"remote":{"target_host":"server"},"switch":{"target_host":"collision"}}"#,
        )
        .unwrap();
        for shell in [Shell::Bash, Shell::Zsh] {
            for (input, cursor, expected, expected_cursor) in [
                (vec!["nixos", ""], 1, vec!["nixos-rebuild", ""], 1),
                (vec!["nixos", "remote", ""], 2, vec!["nixos-rebuild", ""], 1),
                (
                    vec!["nixos", "--", "switch", ""],
                    3,
                    vec!["nixos-rebuild", "switch", ""],
                    2,
                ),
                (
                    vec!["nixos", "remote", "--", "switch", "--", ""],
                    5,
                    vec!["nixos-rebuild", "switch", "--", ""],
                    3,
                ),
                (
                    vec![
                        "nixos",
                        "remote",
                        "switch",
                        "--",
                        "--flake",
                        "two words#host",
                    ],
                    5,
                    vec!["nixos-rebuild", "switch", "--", "--flake", "two words#host"],
                    4,
                ),
                (
                    vec!["nixos", "--", "--", ""],
                    3,
                    vec!["nixos-rebuild", "--", ""],
                    2,
                ),
                (
                    vec!["nixos", "switch", "boot", ""],
                    3,
                    vec!["nixos-rebuild", "boot", ""],
                    2,
                ),
                (
                    vec!["nixos", "unknown", "remote", ""],
                    3,
                    vec!["nixos-rebuild", "unknown", "remote", ""],
                    3,
                ),
                (
                    vec!["nixos", "remote", "sw", "--later"],
                    2,
                    vec!["nixos-rebuild", "sw", "--later"],
                    1,
                ),
            ] {
                let completion =
                    complete(shell, words(&input), cursor + shell.offset(), &catalog).unwrap();
                let upstream_stub = |context: Context| {
                    assert_eq!(
                        context,
                        Context {
                            words: words(&expected),
                            cursor: expected_cursor + shell.offset(),
                        }
                    );
                };
                upstream_stub(completion.upstream);
            }
            let opaque = OsString::from_vec(vec![b'x', 0xff]);
            let completion = complete(
                shell,
                vec![
                    "nixos".into(),
                    "remote".into(),
                    "switch".into(),
                    opaque.clone(),
                ],
                3 + shell.offset(),
                &catalog,
            )
            .unwrap();
            assert_eq!(
                completion.upstream.words,
                vec![OsString::from("nixos-rebuild"), "switch".into(), opaque]
            );
            assert_eq!(completion.upstream.cursor, 2 + shell.offset());
        }
    }
}
