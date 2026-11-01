#![deny(warnings, missing_docs)]

//! Smoke checks for the standalone nixos command.

use std::fs;
use std::path::PathBuf;
use std::process::Command;
use std::sync::atomic::{AtomicUsize, Ordering};

use nixos_cli::{
    cli::{self, Target},
    config::{Catalog, Error, HostConfig, CATALOG_ENV},
};

mod common;

fn binary() -> Command {
    let mut command = Command::new(env!("CARGO_BIN_EXE_nixos"));
    command.env_remove(CATALOG_ENV);
    command
}

struct Fixture(PathBuf);

impl Fixture {
    fn new(json: &str) -> Self {
        static NEXT_ID: AtomicUsize = AtomicUsize::new(0);
        let directory = std::env::temp_dir().join(format!(
            "nixos-cli-test-{}-{}",
            std::process::id(),
            NEXT_ID.fetch_add(1, Ordering::Relaxed),
        ));
        fs::create_dir(&directory).unwrap();
        let fixture = Self(directory.join("catalog.json"));
        fs::write(&fixture.0, json).unwrap();
        fixture
    }
}

impl Drop for Fixture {
    fn drop(&mut self) {
        fs::remove_dir_all(self.0.parent().unwrap()).unwrap();
    }
}

#[test]
fn help_and_version_work_in_the_binary() {
    for option in ["-h", "--help"] {
        let output = binary().arg(option).output().unwrap();
        assert!(output.status.success());
        assert!(String::from_utf8(output.stdout)
            .unwrap()
            .contains("nixos [HOST]"));
        assert!(output.stderr.is_empty());
    }

    for option in ["-V", "--version"] {
        let output = binary().arg(option).output().unwrap();
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
    let output = binary().output().unwrap();
    assert!(output.status.success());
    assert!(String::from_utf8(output.stdout)
        .unwrap()
        .contains("nixos [HOST]"));
    assert!(output.stderr.is_empty());
}

#[test]
fn deployment_is_unimplemented() {
    let output = binary().arg("switch").output().unwrap();
    assert_eq!(output.status.code(), Some(1));
    assert!(output.stdout.is_empty());
    assert!(String::from_utf8(output.stderr)
        .unwrap()
        .starts_with("Error: unimplemented\n"));
}

#[test]
fn catalog_decodes_settings_and_resolves_only_the_selected_target() {
    let fixture = Fixture::new(
        r#"{
            "сервер": {"target_host": "server.example"},
            "gerrit": {
                "target_host": "192.0.2.10",
                "user": "operator",
                "use_sudo": true
            }
        }"#,
    );
    let catalog = Catalog::from_path(&fixture.0).unwrap();
    let mut expected_names = vec!["gerrit".to_owned(), "сервер".to_owned(), common::hostname()];
    expected_names.sort();
    expected_names.dedup();
    let mut names = catalog.names().collect::<Vec<_>>();
    names.sort();
    assert_eq!(names, expected_names);
    assert_eq!(catalog.resolve(None).unwrap(), None);
    assert_eq!(
        catalog.resolve(Some("сервер")).unwrap(),
        Some(&HostConfig {
            target_host: "server.example".into(),
            user: None,
            use_sudo: false,
        }),
    );
    let invocation = cli::parse(["nixos", "gerrit", "switch"], catalog.names()).unwrap();
    assert_eq!(invocation.rebuild_args, ["switch"]);
    let Target::Host(name) = invocation.target else {
        panic!("catalog name must select a remote target");
    };
    assert_eq!(
        catalog.resolve(Some(&name)).unwrap(),
        Some(&HostConfig {
            target_host: "192.0.2.10".into(),
            user: Some("operator".into()),
            use_sudo: true,
        }),
    );
    assert!(matches!(
        catalog.resolve(Some("ger")),
        Err(Error::UnknownHost(name)) if name == "ger",
    ));
}

#[test]
fn env_catalog_populates_root_help_and_named_help_and_version() {
    let fixture = Fixture::new(r#"{"gerrit": {"target_host": "192.0.2.10"}}"#);
    for args in [&["--help"][..], &["gerrit"], &["gerrit", "--help"]] {
        let output = binary()
            .env(CATALOG_ENV, &fixture.0)
            .args(args)
            .output()
            .unwrap();
        assert!(output.status.success());
        let help = String::from_utf8(output.stdout).unwrap();
        assert!(help.contains("gerrit"));
        assert!(help.contains("nixos 'gerrit' switch"));
        assert!(!help.contains("No named hosts are configured."));
        assert!(output.stderr.is_empty());
    }
    let output = binary()
        .env(CATALOG_ENV, &fixture.0)
        .args(["gerrit", "--version"])
        .output()
        .unwrap();
    assert!(output.status.success());
    assert_eq!(
        String::from_utf8(output.stdout).unwrap(),
        concat!("nixos ", env!("CARGO_PKG_VERSION"), "\n"),
    );
    assert!(output.stderr.is_empty());
}

#[test]
fn local_hostname_is_in_help_with_empty_nonempty_and_unset_catalogs() {
    let hostname = common::hostname();
    for json in ["{}", r#"{"gerrit":{"target_host":"192.0.2.10"}}"#] {
        let fixture = Fixture::new(json);
        for configured in [false, true] {
            for args in [vec![], vec!["--help"], vec![hostname.as_str(), "--help"]] {
                let mut command = binary();
                if configured {
                    command.env(CATALOG_ENV, &fixture.0);
                }
                let output = command.args(&args).output().unwrap();
                assert!(output.status.success());
                let help = String::from_utf8(output.stdout).unwrap();
                assert!(help.contains("nixos [HOST]"));
                if args.len() <= 1 {
                    assert!(help.contains(&hostname));
                }
                assert!(!help.contains("No named hosts are configured."));
                assert!(output.stderr.is_empty());
                assert_eq!(fs::read_to_string(&fixture.0).unwrap(), json);
            }
        }
    }
}

#[test]
fn malformed_catalogs_report_the_file_and_fail_before_deployment() {
    for json in [
        "{",
        "[]",
        "null",
        r#"{"gerrit": {}}"#,
        r#"{"gerrit": null}"#,
        r#"{"gerrit": {"target_host": "host", "use_sudo": "yes"}}"#,
        r#"{"gerrit": {"target_host": "host", "use_sudoo": true}}"#,
    ] {
        let fixture = Fixture::new(json);
        assert!(matches!(
            Catalog::from_path(&fixture.0),
            Err(Error::Decode { .. }),
        ));
        let output = binary()
            .env(CATALOG_ENV, &fixture.0)
            .args(["gerrit", "switch"])
            .output()
            .unwrap();
        assert_eq!(output.status.code(), Some(1));
        assert!(output.stdout.is_empty());
        let error = String::from_utf8(output.stderr).unwrap();
        assert!(error.contains("cannot load catalog"));
        assert!(error.contains(fixture.0.to_str().unwrap()));
        assert!(!error.contains("unimplemented"));
    }
}

#[test]
fn missing_catalog_reports_the_path_instead_of_using_an_empty_catalog() {
    let fixture = Fixture::new("{}");
    let missing = fixture.0.with_file_name("missing.json");
    assert!(matches!(
        Catalog::from_path(&missing),
        Err(Error::Read { source, .. }) if source.kind() == std::io::ErrorKind::NotFound,
    ));
    let output = binary()
        .env(CATALOG_ENV, &missing)
        .arg("switch")
        .output()
        .unwrap();
    assert_eq!(output.status.code(), Some(1));
    assert!(output.stdout.is_empty());
    let error = String::from_utf8(output.stderr).unwrap();
    assert!(error.contains("cannot open catalog"));
    assert!(error.contains(missing.to_str().unwrap()));
}

#[cfg(unix)]
#[test]
fn env_catalog_path_preserves_non_utf8_bytes() {
    use std::ffi::OsString;
    use std::os::unix::ffi::OsStringExt;

    let fixture = Fixture::new(r#"{"gerrit": {"target_host": "192.0.2.10"}}"#);
    let path = fixture
        .0
        .with_file_name(OsString::from_vec(vec![b'h', 0xff]));
    fs::rename(&fixture.0, &path).unwrap();
    let output = binary()
        .env(CATALOG_ENV, path)
        .arg("--help")
        .output()
        .unwrap();
    assert!(output.status.success());
    assert!(String::from_utf8(output.stdout).unwrap().contains("gerrit"));
    assert!(output.stderr.is_empty());
}
