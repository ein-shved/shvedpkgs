#![deny(warnings, missing_docs)]

//! Exercise the exec boundary with a mock upstream executable on PATH.

use std::ffi::{OsStr, OsString};
use std::fs;
use std::io::Write;
use std::os::unix::ffi::{OsStrExt, OsStringExt};
use std::os::unix::fs::PermissionsExt;
use std::os::unix::process::ExitStatusExt;
use std::path::PathBuf;
use std::process::{Command, Output, Stdio};
use std::sync::atomic::{AtomicUsize, Ordering};

use nixos_cli::config::CATALOG_ENV;

mod common;

fn executable(name: &str) -> PathBuf {
    std::env::split_paths(&std::env::var_os("PATH").unwrap())
        .map(|directory| directory.join(name))
        .find(|path| path.is_file())
        .unwrap_or_else(|| panic!("test prerequisite {name} is missing from PATH"))
}

struct Fixture {
    directory: PathBuf,
    cwd: PathBuf,
    bin: PathBuf,
    catalog: PathBuf,
}

impl Fixture {
    fn new(host: serde_json::Value) -> Self {
        static NEXT_ID: AtomicUsize = AtomicUsize::new(0);
        let directory = std::env::temp_dir().join(format!(
            "nixos-deployment-{}-{}",
            std::process::id(),
            NEXT_ID.fetch_add(1, Ordering::Relaxed),
        ));
        fs::create_dir(&directory).unwrap();
        let directory = directory.canonicalize().unwrap();
        let cwd = directory.join(OsString::from_vec(b"empty working directory-\xff".to_vec()));
        let bin = directory.join("bin");
        fs::create_dir(&cwd).unwrap();
        fs::create_dir(&bin).unwrap();
        let catalog = directory.join("catalog.json");
        fs::write(&catalog, serde_json::json!({"remote": host}).to_string()).unwrap();
        let mock = bin.join("nixos-rebuild");
        fs::write(
            &mock,
            format!(
                "#!{}\n{}",
                executable("sh").display(),
                include_str!("fixtures/nixos-rebuild.sh"),
            ),
        )
        .unwrap();
        fs::set_permissions(&mock, fs::Permissions::from_mode(0o755)).unwrap();
        Self {
            directory,
            cwd,
            bin,
            catalog,
        }
    }

    fn command(&self) -> Command {
        let mut command = Command::new(env!("CARGO_BIN_EXE_nixos"));
        command
            .env_clear()
            .env("PATH", &self.bin)
            .env(CATALOG_ENV, &self.catalog)
            .env("MOCK_DIR", &self.directory)
            .env("MOCK_CAT", executable("cat"))
            .env("MOCK_RESULT", "0")
            .env(
                "PROBE_VALUE",
                OsStr::from_bytes(b"opaque environment \xff\n"),
            )
            .current_dir(&self.cwd);
        command
    }

    fn run(&self, command: &mut Command, input: &[u8]) -> Output {
        let mut child = command
            .stdin(Stdio::piped())
            .stdout(Stdio::piped())
            .stderr(Stdio::piped())
            .spawn()
            .unwrap();
        let pid = child.id();
        child.stdin.take().unwrap().write_all(input).unwrap();
        let output = child.wait_with_output().unwrap();
        assert_eq!(self.read("pid"), format!("{pid}\n").as_bytes());
        assert_eq!(
            self.read("cwd"),
            [self.cwd.as_os_str().as_bytes(), b"\n"].concat()
        );
        assert_eq!(self.read("env"), b"opaque environment \xff\n");
        assert_eq!(
            self.read("catalog-env"),
            self.catalog.as_os_str().as_bytes()
        );
        assert_eq!(self.read("path-env"), self.bin.as_os_str().as_bytes());
        assert_eq!(output.stdout, [input, b"upstream stdout\n"].concat());
        assert_eq!(output.stderr, b"upstream stderr\n");
        output
    }

    fn read(&self, name: &str) -> Vec<u8> {
        fs::read(self.directory.join(name)).unwrap()
    }

    fn assert_argv(&self, expected: &[OsString]) {
        let mut bytes = Vec::new();
        for arg in expected {
            bytes.extend_from_slice(arg.as_bytes());
            bytes.push(0);
        }
        assert_eq!(self.read("argv"), bytes);
    }

    fn success(&self, args: &[&str], expected: &[&str]) {
        let output = self.run(self.command().args(args), b"");
        assert!(output.status.success(), "{:?}", output.status);
        self.assert_argv(&expected.iter().map(OsString::from).collect::<Vec<_>>());
    }
}

impl Drop for Fixture {
    fn drop(&mut self) {
        fs::remove_dir_all(&self.directory).unwrap();
    }
}

fn host() -> serde_json::Value {
    serde_json::json!({"target_host": "server.example", "user": "operator"})
}

#[test]
fn runtime_hostname_alias_executes_locally_without_modifying_the_catalog() {
    let hostname = common::hostname();
    let uid = Command::new(executable("id")).arg("-u").output().unwrap();
    assert!(uid.status.success());
    let expected = if uid.stdout == b"0\n" {
        vec!["switch"]
    } else {
        vec!["--sudo", "switch"]
    };
    for catalog in [serde_json::json!({}), serde_json::json!({"remote": host()})] {
        let fixture = Fixture::new(host());
        let original = catalog.to_string();
        fs::write(&fixture.catalog, &original).unwrap();
        for args in [vec!["switch"], vec![hostname.as_str(), "switch"]] {
            fixture.success(&args, &expected);
            assert_eq!(fs::read_to_string(&fixture.catalog).unwrap(), original);
        }
        // An explicit target remains an upstream override for the local alias.
        fixture.success(
            &[&hostname, "test", "--target-host=root@override"],
            &["test", "--target-host=root@override"],
        );
    }
}

#[test]
fn existing_remote_entry_matching_hostname_keeps_address_and_sudo_policy() {
    let hostname = common::hostname();
    let fixture = Fixture::new(host());
    let original = serde_json::json!({hostname.clone(): host()}).to_string();
    fs::write(&fixture.catalog, &original).unwrap();
    fixture.success(
        &[&hostname, "switch"],
        &[
            "--target-host",
            "operator@server.example",
            "--ask-sudo-password",
            "switch",
        ],
    );
    assert_eq!(fs::read_to_string(&fixture.catalog).unwrap(), original);
}

#[test]
fn named_target_uses_catalog_address_and_defaults_to_password_sudo() {
    Fixture::new(host()).success(
        &["remote", "switch"],
        &[
            "--target-host",
            "operator@server.example",
            "--ask-sudo-password",
            "switch",
        ],
    );
}

#[test]
fn absent_user_is_left_to_ssh_and_sudo_can_be_disabled() {
    for ask_password in [false, true] {
        Fixture::new(serde_json::json!({
            "target_host": "server.example", "use_sudo": false,
            "ask_sudo_password": ask_password,
        }))
        .success(
            &["remote", "test"],
            &["--target-host", "server.example", "test"],
        );
    }
}

#[test]
fn passwordless_sudo_is_added_once_including_upstream_alias() {
    let mut config = host();
    config["ask_sudo_password"] = false.into();
    for flags in [vec![], vec!["--sudo"], vec!["--use-remote-sudo"]] {
        let mut args = vec!["remote", "switch"];
        args.extend(&flags);
        let mut expected = vec!["--target-host", "operator@server.example"];
        if flags.is_empty() {
            expected.push("--sudo");
        }
        expected.push("switch");
        expected.extend(flags);
        Fixture::new(config.clone()).success(&args, &expected);
    }
}

#[test]
fn explicit_password_options_are_not_duplicated() {
    for ask_password in [false, true] {
        let mut config = host();
        config["ask_sudo_password"] = ask_password.into();
        for flag in ["--ask-sudo-password", "-S", "--ask-sudo-password=true"] {
            Fixture::new(config.clone()).success(
                &["remote", "switch", flag],
                &["--target-host", "operator@server.example", "switch", flag],
            );
        }
    }
}

#[test]
fn explicit_sudo_does_not_cancel_catalog_password_prompt() {
    Fixture::new(host()).success(
        &["remote", "switch", "--sudo"],
        &[
            "--target-host",
            "operator@server.example",
            "--ask-sudo-password",
            "switch",
            "--sudo",
        ],
    );
}

#[test]
fn explicit_target_replaces_catalog_access_and_sudo_policy() {
    for prefix in [vec![], vec!["remote"]] {
        for target in [
            vec!["--target-host", "root@override"],
            vec!["--target-host=root@override"],
        ] {
            for flags in [vec![], vec!["--sudo"]] {
                let mut args = prefix.clone();
                let mut upstream = vec!["switch", "--build-host", "builder@elsewhere"];
                upstream.extend(&target);
                upstream.extend(flags);
                args.extend(&upstream);
                Fixture::new(host()).success(&args, &upstream);
            }
        }
    }
}

#[test]
fn build_host_is_forwarded_without_changing_target_or_sudo_policy() {
    for flags in [
        vec!["--build-host", "builder@elsewhere"],
        vec!["--build-host=builder@elsewhere"],
    ] {
        let mut args = vec!["remote", "build"];
        args.extend(&flags);
        let mut expected = vec![
            "--target-host",
            "operator@server.example",
            "--ask-sudo-password",
            "build",
        ];
        expected.extend(flags);
        Fixture::new(host()).success(&args, &expected);
    }
}

#[test]
fn option_prefixes_and_options_after_separator_do_not_override_policy() {
    for tail in [
        vec![
            "--target-host-suffix=x",
            "--sudo-suffix",
            "--ask-sudo-password-suffix",
        ],
        vec![
            "--",
            "--target-host=x",
            "--sudo",
            "--ask-sudo-password",
            "-S",
        ],
    ] {
        let mut args = vec!["remote", "switch"];
        args.extend(&tail);
        let mut expected = vec![
            "--target-host",
            "operator@server.example",
            "--ask-sudo-password",
            "switch",
        ];
        expected.extend(tail);
        Fixture::new(host()).success(&args, &expected);
    }
}

#[test]
fn local_sudo_depends_on_real_uid_and_respects_explicit_options() {
    let uid = Command::new(executable("id")).arg("-u").output().unwrap();
    assert!(uid.status.success());
    for flags in [
        vec![],
        vec!["--sudo"],
        vec!["--use-remote-sudo"],
        vec!["--ask-sudo-password"],
        vec!["-S"],
    ] {
        let mut args = vec!["switch"];
        args.extend(&flags);
        let mut expected = Vec::new();
        if uid.stdout != b"0\n" && flags.is_empty() {
            expected.push("--sudo");
        }
        expected.extend(&args);
        Fixture::new(host()).success(&args, &expected);
    }
}

#[test]
fn exec_preserves_pid_native_arguments_environment_cwd_and_streams() {
    let fixture = Fixture::new(host());
    let upstream: Vec<OsString> = [
        "switch",
        "--target-host=root@override",
        "--build-host",
        "builder with spaces",
        "--flake",
        "/configuration with spaces#host",
        "",
        "$(touch unexpected)",
        "--",
        "--help",
        "--",
        "--version",
    ]
    .into_iter()
    .map(OsString::from)
    .chain([OsString::from_vec(b"--opaque=\xff".to_vec())])
    .collect();
    let output = fixture.run(
        fixture.command().arg("remote").args(&upstream),
        b"stdin\0\xff\nsecond line\n",
    );
    assert!(output.status.success());
    fixture.assert_argv(&upstream);
    assert!(!fixture.cwd.join("unexpected").exists());
}

#[test]
fn upstream_exit_codes_and_signal_become_the_command_result() {
    for result in ["0", "37", "signal"] {
        let fixture = Fixture::new(host());
        let output = fixture.run(
            fixture
                .command()
                .args(["remote", "switch"])
                .env("MOCK_RESULT", result),
            b"",
        );
        if result == "signal" {
            assert_eq!(output.status.signal(), Some(15));
            assert_eq!(output.status.code(), None);
        } else {
            assert_eq!(output.status.code(), Some(result.parse().unwrap()));
            assert_eq!(output.status.signal(), None);
        }
    }
}

#[test]
fn flake_lock_is_untouched_before_and_after_upstream() {
    for contents in [None, Some(&b"{\"locked\": \"sentinel\"}\n"[..])] {
        let fixture = Fixture::new(host());
        let lock = fixture.cwd.join("flake.lock");
        if let Some(contents) = contents {
            fs::write(&lock, contents).unwrap();
        }
        let args = [
            "remote",
            "switch",
            "--no-write-lock-file",
            "--no-update-lock-file",
            "--override-input",
            "nixpkgs",
            "path:/pinned source",
        ];
        let output = fixture.run(fixture.command().args(args), b"");
        assert!(output.status.success());
        fixture.assert_argv(
            &[
                "--target-host",
                "operator@server.example",
                "--ask-sudo-password",
            ]
            .into_iter()
            .chain(args.into_iter().skip(1))
            .map(OsString::from)
            .collect::<Vec<_>>(),
        );
        if let Some(contents) = contents {
            assert_eq!(fixture.read("lock"), contents);
            assert_eq!(fs::read(lock).unwrap(), contents);
        } else {
            assert!(fixture.directory.join("lock-missing").exists());
            assert!(!lock.exists());
        }
    }
}

#[test]
fn missing_or_nonexecutable_upstream_reports_launch_error() {
    for missing in [true, false] {
        let fixture = Fixture::new(host());
        let mock = fixture.bin.join("nixos-rebuild");
        if missing {
            fs::remove_file(mock).unwrap();
        } else {
            fs::set_permissions(mock, fs::Permissions::from_mode(0o644)).unwrap();
        }
        let lock = fixture.cwd.join("flake.lock");
        fs::write(&lock, b"keep this lock\n").unwrap();
        let output = fixture.command().arg("switch").output().unwrap();
        assert_eq!(output.status.code(), Some(1));
        assert!(output.stdout.is_empty());
        assert!(String::from_utf8(output.stderr)
            .unwrap()
            .contains("cannot execute nixos-rebuild"));
        assert!(!fixture.directory.join("pid").exists());
        assert_eq!(fs::read(lock).unwrap(), b"keep this lock\n");
    }
}
