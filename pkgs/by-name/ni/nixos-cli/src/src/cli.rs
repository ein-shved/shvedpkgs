//! Select a rebuild target while preserving opaque upstream arguments.

use std::ffi::OsString;

use clap::{error::ErrorKind, Command, CommandFactory, FromArgMatches, Parser};

/// Target selected from the caller-provided host catalog.
#[derive(Debug, PartialEq, Eq)]
pub enum Target {
    /// Rebuild the local host.
    Local,
    /// Rebuild the catalog host with this name.
    Host(String),
}

/// A selected target and its upstream rebuild arguments.
#[derive(Debug, PartialEq, Eq)]
pub struct Invocation {
    /// Local target or the selected catalog host.
    pub target: Target,
    /// Ordered upstream arguments in their native OS representation.
    pub rebuild_args: Vec<OsString>,
}

#[derive(Parser)]
#[command(
    name = "nixos",
    display_name = "nixos",
    version,
    about = "Manage local and named NixOS rebuilds",
    override_usage = "nixos [HOST] [--] [NIXOS_REBUILD_ARGS]...",
    disable_help_subcommand = true,
    subcommand_value_name = "HOST",
    subcommand_help_heading = "Hosts",
    after_help = "Only the first argument can select a host from the supplied catalog.\n\
                  A leading -- bypasses host selection. Help and version options apply\n\
                  only before upstream arguments or --."
)]
struct Cli {
    /// Arguments passed unchanged to nixos-rebuild
    #[arg(
        value_name = "NIXOS_REBUILD_ARGS",
        num_args = 0..,
        trailing_var_arg = true,
        allow_hyphen_values = true
    )]
    rebuild_args: Vec<OsString>,
}

pub(crate) fn command(host_names: impl IntoIterator<Item = impl Into<String>>) -> Command {
    // Named subcommands let clap choose a host before the opaque upstream tail.
    // The separator stays reserved even if the catalog contains that name.
    let command = Cli::command().subcommands(
        host_names
            .into_iter()
            .map(Into::into)
            .filter(|name| name != "--")
            .map(|name| Cli::command().name(name)),
    );

    let mut after_help = command.get_after_help().cloned().unwrap_or_default();
    after_help.push_str("\n\nExamples:\n");
    if command.find_subcommand("switch").is_none() {
        after_help.push_str("  nixos switch\n");
    }
    if let Some(host) = command.get_subcommands().next() {
        // Keep the example host in one shell argument, including spaces or quotes.
        after_help.push_str(&format!(
            "  nixos '{}' switch\n",
            host.get_name().replace('\'', "'\\''"),
        ));
    }
    after_help.push_str("  nixos -- switch\n  nixos -- --help");
    if !command.has_subcommands() {
        after_help.push_str("\n\nNo named hosts are configured.");
    }

    command
        .mut_subcommands(|host| host.after_help(after_help.clone()))
        .after_help(after_help)
}

/// Parse argv including the program name. Catalog names are supplied by the caller;
/// no environment or deployment configuration is read here.
///
/// # Errors
///
/// Returns clap parsing errors. Help, version and empty upstream arguments return
/// display errors with a successful exit code, which callers can print or exit with.
pub fn parse(
    argv: impl IntoIterator<Item = impl Into<OsString> + Clone>,
    host_names: impl IntoIterator<Item = impl Into<String>>,
) -> Result<Invocation, clap::Error> {
    let mut command = command(host_names);
    let mut matches = command.try_get_matches_from_mut(argv)?;
    let target = if let Some((name, host_matches)) = matches.remove_subcommand() {
        matches = host_matches;
        Target::Host(name)
    } else {
        Target::Local
    };

    let Cli { rebuild_args } = Cli::from_arg_matches_mut(&mut matches)?;

    if rebuild_args.is_empty() {
        return Err(clap::Error::raw(
            ErrorKind::DisplayHelp,
            command.render_help().to_string(),
        ));
    }

    Ok(Invocation {
        target,
        rebuild_args,
    })
}

#[cfg(test)]
mod tests {
    use super::*;

    fn assert_invocation(argv: &[&str], hosts: &[&str], target: Target, upstream: &[&str]) {
        assert_eq!(
            parse(argv.iter().copied(), hosts.iter().copied()).unwrap(),
            Invocation {
                target,
                rebuild_args: upstream.iter().map(OsString::from).collect(),
            },
        );
    }

    #[test]
    fn catalog_accepts_owned_unicode_names_and_borrowed_strings() {
        let names = vec![String::from("сервер")];
        let argv = ["nixos", "сервер", "switch"];
        let expected = Invocation {
            target: Target::Host("сервер".into()),
            rebuild_args: vec!["switch".into()],
        };
        assert_eq!(parse(argv, &names).unwrap(), expected);
        assert_eq!(parse(argv, names).unwrap(), expected);
    }

    #[test]
    fn catalog_iterator_needs_no_clone_and_supports_empty_upstream_help() {
        fn names() -> impl Iterator<Item = String> {
            std::iter::once("gerrit".to_owned())
        }

        assert_eq!(
            parse(["nixos", "gerrit", "switch"], names()).unwrap(),
            Invocation {
                target: Target::Host("gerrit".into()),
                rebuild_args: vec!["switch".into()],
            },
        );
        let error = parse(["nixos", "gerrit"], names()).unwrap_err();
        assert_eq!(error.kind(), ErrorKind::DisplayHelp);
        assert_eq!(error.exit_code(), 0);
        assert!(error.to_string().contains("gerrit"));
    }

    #[test]
    fn empty_catalog_help_only_shows_local_examples() {
        for names in [vec![], vec!["--"]] {
            for option in ["-h", "--help"] {
                let error = parse(["nixos", option], names.iter().copied()).unwrap_err();
                assert_eq!(error.kind(), ErrorKind::DisplayHelp);
                let help = error.to_string();
                assert!(help.contains("No named hosts are configured."));
                assert!(help.contains("  nixos switch\n"));
                assert!(!help.contains("nixos '"));
                assert!(!help.contains("gerrit"));
            }
        }
    }

    #[test]
    fn help_uses_a_registered_host_for_root_and_named_invocations() {
        for argv in [
            &["nixos", "--help"][..],
            &["nixos", "switch", "--help"][..],
            &["nixos", "switch"][..],
        ] {
            let error = parse(argv.iter().copied(), ["--", "switch"]).unwrap_err();
            assert_eq!(error.kind(), ErrorKind::DisplayHelp);
            let help = error.to_string();
            assert!(help.contains("nixos 'switch' switch"));
            assert!(help.contains("  nixos -- switch\n"));
            assert!(!help.contains("  nixos switch\n"));
            assert!(!help.contains("No named hosts are configured."));
            assert!(!help.contains("gerrit"));
        }
    }

    #[test]
    fn help_quotes_example_host_as_one_shell_argument() {
        let host = "remote host's";
        for argv in [vec!["nixos", "--help"], vec!["nixos", host, "--help"]] {
            let error = parse(argv, [host]).unwrap_err();
            assert_eq!(error.kind(), ErrorKind::DisplayHelp);
            assert!(error
                .to_string()
                .contains(r"nixos 'remote host'\''s' switch"));
        }
    }

    #[test]
    fn local_target_preserves_action_and_options() {
        assert_invocation(
            &["nixos", "switch", "--flake", ".#local"],
            &["gerrit"],
            Target::Local,
            &["switch", "--flake", ".#local"],
        );
    }

    #[test]
    fn named_target_removes_only_the_host() {
        assert_invocation(
            &[
                "nixos",
                "gerrit",
                "switch",
                "--target-host",
                "root@override",
            ],
            &["gerrit", "switch"],
            Target::Host("gerrit".into()),
            &["switch", "--target-host", "root@override"],
        );
    }

    #[test]
    fn unknown_first_argument_stays_upstream() {
        assert_invocation(
            &["nixos", "unknown", "switch"],
            &["gerrit"],
            Target::Local,
            &["unknown", "switch"],
        );
    }

    #[test]
    fn later_catalog_name_cannot_select_a_host() {
        assert_invocation(
            &["nixos", "switch", "gerrit"],
            &["gerrit"],
            Target::Local,
            &["switch", "gerrit"],
        );
    }

    #[test]
    fn action_name_collision_selects_host_unless_bypassed() {
        assert_invocation(
            &["nixos", "switch", "boot"],
            &["switch"],
            Target::Host("switch".into()),
            &["boot"],
        );
        assert_invocation(
            &["nixos", "--", "switch", "boot"],
            &["switch"],
            Target::Local,
            &["switch", "boot"],
        );
    }

    #[test]
    fn boundary_after_host_is_removed() {
        assert_invocation(
            &["nixos", "gerrit", "--", "--help", "--", "-V"],
            &["gerrit"],
            Target::Host("gerrit".into()),
            &["--help", "--", "-V"],
        );
    }

    #[test]
    fn later_separators_and_wrapper_options_stay_upstream() {
        assert_invocation(
            &[
                "nixos",
                "switch",
                "--",
                "--help",
                "-h",
                "--version",
                "-V",
                "--",
            ],
            &[],
            Target::Local,
            &["switch", "--", "--help", "-h", "--version", "-V", "--"],
        );
    }

    #[test]
    fn unknown_option_starts_upstream_even_before_action() {
        assert_invocation(
            &["nixos", "--flake", "my path#host", "--help", "switch"],
            &[],
            Target::Local,
            &["--flake", "my path#host", "--help", "switch"],
        );
    }

    #[test]
    fn separator_bypasses_wrapper_options_and_preserves_later_separator() {
        assert_invocation(
            &["nixos", "--", "--help", "--", "--version"],
            &[],
            Target::Local,
            &["--help", "--", "--version"],
        );
        assert_invocation(
            &["nixos", "--", "--", "--help"],
            &["--"],
            Target::Local,
            &["--", "--help"],
        );
    }

    #[test]
    fn help_is_an_upstream_argument_or_catalog_host_without_special_syntax() {
        assert_invocation(
            &["nixos", "help", "--help"],
            &["gerrit"],
            Target::Local,
            &["help", "--help"],
        );
        assert_invocation(
            &["nixos", "help", "switch"],
            &["help"],
            Target::Host("help".into()),
            &["switch"],
        );
    }

    #[test]
    fn host_matching_is_exact_without_prefix_inference() {
        assert_invocation(
            &["nixos", "ger", "switch"],
            &["gerrit"],
            Target::Local,
            &["ger", "switch"],
        );
    }

    #[test]
    fn own_help_and_version_are_handled_before_upstream() {
        for (option, expected) in [
            ("-h", ErrorKind::DisplayHelp),
            ("--help", ErrorKind::DisplayHelp),
            ("-V", ErrorKind::DisplayVersion),
            ("--version", ErrorKind::DisplayVersion),
        ] {
            for prefix in [&["nixos"][..], &["nixos", "gerrit"][..]] {
                let argv = prefix.iter().copied().chain([option]);
                let error = parse(argv, ["gerrit"]).unwrap_err();
                assert_eq!(error.kind(), expected);
                assert_eq!(error.exit_code(), 0);
                if expected == ErrorKind::DisplayVersion {
                    assert_eq!(
                        error.to_string(),
                        concat!("nixos ", env!("CARGO_PKG_VERSION"), "\n"),
                    );
                }
            }
        }
    }

    #[test]
    fn empty_upstream_shows_help() {
        for argv in [
            &[][..],
            &["nixos"][..],
            &["nixos", "--"][..],
            &["nixos", "gerrit"][..],
            &["nixos", "gerrit", "--"][..],
        ] {
            let error = parse(argv.iter().copied(), ["gerrit"]).unwrap_err();
            assert_eq!(error.kind(), ErrorKind::DisplayHelp);
            assert_eq!(error.exit_code(), 0);
            assert!(error.to_string().contains("nixos [HOST]"));
        }
    }

    #[test]
    fn spaces_empty_values_and_shell_characters_are_opaque() {
        let upstream = [
            "switch",
            "",
            "two words",
            "$(touch /tmp/unused)",
            "a=b",
            "хост",
        ];
        let argv = std::iter::once("nixos").chain(upstream);
        assert_eq!(
            parse(argv, std::iter::empty::<String>())
                .unwrap()
                .rebuild_args,
            upstream.map(OsString::from),
        );
    }

    #[cfg(unix)]
    #[test]
    fn non_utf8_arguments_are_preserved_including_the_first_argument() {
        use std::os::unix::ffi::OsStringExt;

        let invalid = OsString::from_vec(vec![b'-', b'-', b'x', b'=', 0xff]);
        for upstream in [
            vec![invalid.clone(), "--help".into()],
            vec!["switch".into(), invalid.clone()],
        ] {
            let argv = std::iter::once(OsString::from("nixos")).chain(upstream.clone());
            assert_eq!(
                parse(argv, ["gerrit"]).unwrap(),
                Invocation {
                    target: Target::Local,
                    rebuild_args: upstream,
                },
            );
        }
        let upstream = vec!["switch".into(), invalid];
        let argv = [OsString::from("nixos"), OsString::from("gerrit")]
            .into_iter()
            .chain(upstream.clone());
        assert_eq!(
            parse(argv, ["gerrit"]).unwrap(),
            Invocation {
                target: Target::Host("gerrit".into()),
                rebuild_args: upstream,
            },
        );
    }
}
