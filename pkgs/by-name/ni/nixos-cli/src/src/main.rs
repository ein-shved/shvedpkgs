#![deny(warnings, missing_docs)]

//! Manage local and named NixOS rebuilds.

use nixos_cli::cli;

fn main() -> anyhow::Result<()> {
    let _invocation = match cli::parse(std::env::args_os(), std::iter::empty::<String>()) {
        Ok(invocation) => invocation,
        Err(error) => error.exit(),
    };
    anyhow::bail!("unimplemented")
}
