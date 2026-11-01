#![deny(warnings, missing_docs)]

//! Manage local and named NixOS rebuilds.

use nixos_cli::{cli, config::Catalog};

fn main() -> anyhow::Result<()> {
    let catalog = Catalog::from_env()?;
    let invocation = match cli::parse(std::env::args_os(), catalog.names()) {
        Ok(invocation) => invocation,
        Err(error) => error.exit(),
    };
    let name = match &invocation.target {
        cli::Target::Local => None,
        cli::Target::Host(name) => Some(name.as_str()),
    };
    let _target_config = catalog.resolve(name)?;
    anyhow::bail!("unimplemented")
}
