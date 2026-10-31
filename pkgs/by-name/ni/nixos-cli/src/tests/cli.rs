#![deny(warnings, missing_docs)]

//! Smoke checks for the standalone nixos command.

use std::process::Command;

#[test]
fn help_and_version_work_in_the_binary() {
    for option in ["-h", "--help"] {
        let output = Command::new(env!("CARGO_BIN_EXE_nixos"))
            .arg(option)
            .output()
            .unwrap();
        assert!(output.status.success());
        assert!(String::from_utf8(output.stdout)
            .unwrap()
            .contains("nixos [HOST]"));
        assert!(output.stderr.is_empty());
    }

    for option in ["-V", "--version"] {
        let output = Command::new(env!("CARGO_BIN_EXE_nixos"))
            .arg(option)
            .output()
            .unwrap();
        assert!(output.status.success());
        assert_eq!(
            String::from_utf8(output.stdout).unwrap(),
            concat!("nixos ", env!("CARGO_PKG_VERSION"), "\n"),
        );
        assert!(output.stderr.is_empty());
    }
}

#[test]
fn empty_invocation_shows_help_successfully() {
    let output = Command::new(env!("CARGO_BIN_EXE_nixos")).output().unwrap();
    assert!(output.status.success());
    assert!(String::from_utf8(output.stdout)
        .unwrap()
        .contains("nixos [HOST]"));
    assert!(output.stderr.is_empty());
}

#[test]
fn deployment_is_unimplemented() {
    let output = Command::new(env!("CARGO_BIN_EXE_nixos"))
        .arg("switch")
        .output()
        .unwrap();
    assert_eq!(output.status.code(), Some(1));
    assert!(output.stdout.is_empty());
    assert!(String::from_utf8(output.stderr)
        .unwrap()
        .starts_with("Error: unimplemented\n"));
}
