//! Adapt target settings and replace this process with nixos-rebuild.

use std::ffi::{OsStr, OsString};
use std::io;
use std::os::unix::process::CommandExt;
use std::process::Command;

use crate::config::HostConfig;

// POSIX uid_t is an unsigned 32-bit integer on the supported Nix platforms.
extern "C" {
    fn getuid() -> u32;
}

fn is_arguments_contains(arguments: &[OsString], names: &[&str]) -> bool {
    arguments
        .iter()
        .take_while(|arg| arg.as_os_str() != OsStr::new("--"))
        .any(|arg| {
            names.iter().any(|name| {
                let bytes = arg.as_encoded_bytes();
                bytes == name.as_bytes()
                    || bytes
                        .strip_prefix(name.as_bytes())
                        .is_some_and(|tail| tail.starts_with(b"="))
            })
        })
}

/// Execute upstream with the resolved target settings and opaque arguments.
///
/// A successful exec never returns. Otherwise, returns the operating system's
/// launch error. The caller retains its environment, directory and standard IO.
pub fn exec(host: Option<&HostConfig>, args: &[OsString]) -> io::Error {
    let mut command = Command::new("nixos-rebuild");
    let is_contains = |names: &[&str]| is_arguments_contains(args, names);

    // An explicit target replaces both the catalog address and its sudo policy.
    if !is_contains(&["--target-host"]) {
        let (sudo, ask_password) = if let Some(host) = host {
            let address = match &host.user {
                Some(user) => format!("{user}@{}", host.target_host),
                None => host.target_host.clone(),
            };
            command.args(["--target-host", &address]);
            (host.use_sudo, host.ask_sudo_password)
        } else {
            // SAFETY: getuid has no preconditions and cannot fail.
            (unsafe { getuid() } != 0, false)
        };

        if sudo && !is_contains(&["--ask-sudo-password", "-S"]) {
            if ask_password {
                command.arg("--ask-sudo-password");
            } else if !is_contains(&["--sudo", "--use-remote-sudo"]) {
                command.arg("--sudo");
            }
        }
    }

    command.args(args).exec()
}
