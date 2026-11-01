//! Load a JSON host catalog from [`CATALOG_ENV`] and add the local OS hostname.
//!
//! The root object maps host names to settings. `target_host` is required;
//! omitted `user` uses the SSH default. Sudo and password prompting default on.
//! Configuration source selection belongs to nixos-rebuild, so it is not part
//! of these settings.

use std::collections::BTreeMap;
use std::fs::File;
use std::io::{self, BufReader};
use std::path::{Path, PathBuf};

use serde::Deserialize;

/// Environment variable containing the path to the JSON host catalog.
pub const CATALOG_ENV: &str = "NIXOS_CLI_CONFIG";

/// Connection and privilege settings for a named remote target.
#[derive(Debug, Deserialize, PartialEq, Eq)]
#[serde(deny_unknown_fields)]
pub struct HostConfig {
    /// Address of the target host.
    pub target_host: String,
    /// Connection user, or the SSH default when omitted.
    pub user: Option<String>,
    /// Whether updating the target requires sudo; defaults to true.
    #[serde(default = "enabled")]
    pub use_sudo: bool,
    /// Whether sudo needs a password prompt; defaults to true.
    #[serde(default = "enabled")]
    pub ask_sudo_password: bool,
}

fn enabled() -> bool {
    true
}

/// Host settings keyed by the names accepted by the CLI.
#[derive(Debug, Default, Deserialize)]
#[serde(transparent)]
pub struct Catalog {
    hosts: BTreeMap<String, HostConfig>,
    #[serde(skip)]
    local_name: Option<String>,
}

/// A failure to load a catalog or resolve a named target.
#[derive(Debug, thiserror::Error)]
pub enum Error {
    /// The operating system's hostname could not be obtained as a CLI name.
    #[error("cannot get local hostname")]
    Hostname(#[source] io::Error),
    /// The catalog file could not be opened.
    #[error("cannot open catalog {}", .path.display())]
    Read {
        /// Path to the requested catalog.
        path: PathBuf,
        /// Underlying filesystem error.
        source: io::Error,
    },
    /// The file could not be read as a JSON host catalog.
    #[error("cannot load catalog {}", .path.display())]
    Decode {
        /// Path to the requested catalog.
        path: PathBuf,
        /// Underlying JSON, schema or read error.
        source: serde_json::Error,
    },
    /// A requested target is absent from the catalog.
    #[error("unknown catalog host {0:?}")]
    UnknownHost(String),
}

impl Catalog {
    /// Read the catalog at [`CATALOG_ENV`], or use an empty remote catalog if unset,
    /// then add the local hostname if absent. Paths retain their OS representation.
    ///
    /// # Errors
    ///
    /// Returns an error if the configured file cannot be opened or decoded,
    /// or the local hostname cannot be read.
    pub fn from_env() -> Result<Self, Error> {
        match std::env::var_os(CATALOG_ENV) {
            Some(path) => Self::from_path(path),
            None => Self::default().with_local_hostname(hostname),
        }
    }

    /// Read a JSON object mapping host names to their settings, then add the
    /// local hostname if absent. The file is never modified.
    ///
    /// # Errors
    ///
    /// Returns an error if the file cannot be opened or decoded. Unknown
    /// setting fields and missing target addresses are rejected. Hostname
    /// acquisition errors also fail initialization.
    pub fn from_path(path: impl AsRef<Path>) -> Result<Self, Error> {
        let path = path.as_ref();
        let file = File::open(path).map_err(|source| Error::Read {
            path: path.to_owned(),
            source,
        })?;
        let catalog: Self =
            serde_json::from_reader(BufReader::new(file)).map_err(|source| Error::Decode {
                path: path.to_owned(),
                source,
            })?;
        catalog.with_local_hostname(hostname)
    }

    fn with_local_hostname(
        mut self,
        provider: impl FnOnce() -> io::Result<String>,
    ) -> Result<Self, Error> {
        let name = provider().map_err(Error::Hostname)?;
        if name.is_empty() {
            return Err(Error::Hostname(io::Error::new(
                io::ErrorKind::InvalidData,
                "local hostname is empty",
            )));
        }
        if !self.hosts.contains_key(&name) {
            self.local_name = Some(name);
        }
        Ok(self)
    }

    /// Return catalog names for CLI parsing and help.
    pub fn names(&self) -> impl Iterator<Item = &str> {
        self.hosts
            .keys()
            .map(String::as_str)
            .chain(self.local_name.as_deref())
    }

    /// Resolve a selected name to its settings. `None` selects the local host
    /// and returns `None`, without applying any remote settings. An inserted
    /// local hostname resolves the same way; existing remote entries keep theirs.
    ///
    /// # Errors
    ///
    /// Returns [`Error::UnknownHost`] when the selected name is absent.
    pub fn resolve(&self, name: Option<&str>) -> Result<Option<&HostConfig>, Error> {
        match name {
            None => Ok(None),
            Some(name) if self.local_name.as_deref() == Some(name) => Ok(None),
            Some(name) => self
                .hosts
                .get(name)
                .map(Some)
                .ok_or_else(|| Error::UnknownHost(name.to_owned())),
        }
    }
}

fn hostname() -> io::Result<String> {
    let mut buffer = vec![0_u8; 256];
    loop {
        // SAFETY: the buffer is writable for the supplied length. gethostname
        // retains no pointer; its return value is checked before reading bytes.
        let result = unsafe { libc::gethostname(buffer.as_mut_ptr().cast(), buffer.len()) };
        if result == 0 {
            if let Some(end) = buffer.iter().position(|byte| *byte == 0) {
                buffer.truncate(end);
                return String::from_utf8(buffer)
                    .map_err(|error| io::Error::new(io::ErrorKind::InvalidData, error));
            }
        } else {
            let error = io::Error::last_os_error();
            if error.raw_os_error() != Some(libc::ENAMETOOLONG) {
                return Err(error);
            }
        }
        // Some Unix implementations truncate without a terminator; retry with
        // a larger buffer in that case as well as on ENAMETOOLONG.
        buffer.resize(buffer.len() * 2, 0);
    }
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn local_alias_is_added_to_empty_and_nonempty_catalogs_without_remote_settings() {
        for json in ["{}", r#"{"remote":{"target_host":"server.example"}}"#] {
            let catalog: Catalog = serde_json::from_str(json).unwrap();
            let catalog = catalog.with_local_hostname(|| Ok("local".into())).unwrap();
            assert_eq!(catalog.names().filter(|name| *name == "local").count(), 1);
            assert_eq!(
                catalog.resolve(Some("local")).unwrap(),
                catalog.resolve(None).unwrap()
            );
            assert_eq!(catalog.resolve(Some("local")).unwrap(), None);
            assert!(!catalog.hosts.contains_key("local"));
            if json != "{}" {
                assert_eq!(
                    catalog
                        .resolve(Some("remote"))
                        .unwrap()
                        .unwrap()
                        .target_host,
                    "server.example"
                );
            }
        }
    }

    #[test]
    fn existing_hostname_keeps_all_remote_settings() {
        let catalog: Catalog = serde_json::from_str(
            r#"{"local":{
            "target_host":"server.example", "user":"operator",
            "use_sudo":false, "ask_sudo_password":false
        }}"#,
        )
        .unwrap();
        let catalog = catalog.with_local_hostname(|| Ok("local".into())).unwrap();
        assert_eq!(catalog.names().collect::<Vec<_>>(), ["local"]);
        assert_eq!(
            catalog.resolve(Some("local")).unwrap(),
            Some(&HostConfig {
                target_host: "server.example".into(),
                user: Some("operator".into()),
                use_sudo: false,
                ask_sudo_password: false,
            })
        );
        assert_eq!(catalog.local_name, None);
    }

    #[test]
    fn hostname_provider_failure_fails_initialization() {
        let error = Catalog::default()
            .with_local_hostname(|| {
                Err(io::Error::new(
                    io::ErrorKind::PermissionDenied,
                    "hostname unavailable",
                ))
            })
            .unwrap_err();
        assert!(matches!(error, Error::Hostname(source)
            if source.kind() == io::ErrorKind::PermissionDenied
            && source.to_string() == "hostname unavailable"));
    }

    #[test]
    fn empty_hostname_is_an_initialization_error() {
        assert!(
            matches!(Catalog::default().with_local_hostname(|| Ok(String::new())),
            Err(Error::Hostname(source)) if source.kind() == io::ErrorKind::InvalidData)
        );
    }
}
