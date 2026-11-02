#![deny(warnings, missing_docs)]

//! Manage local and named NixOS rebuilds.

use nixos_cli::{cli, completion, config::Catalog, deployment};

fn main() -> anyhow::Result<()> {
    let catalog = Catalog::from_env()?;
    if completion::from_env(&catalog)? {
        return Ok(());
    }
    let invocation = match cli::parse(std::env::args_os(), catalog.names()) {
        Ok(invocation) => invocation,
        Err(error) => error.exit(),
    };
    let name = match &invocation.target {
        cli::Target::Local => None,
        cli::Target::Host(name) => Some(name.as_str()),
    };
    let target_config = catalog.resolve(name)?;
    Err(
        anyhow::Error::new(deployment::exec(target_config, &invocation.rebuild_args))
            .context("cannot execute nixos-rebuild"),
    )
}
