# System Specification

## Development Host Classification

A development host is an evaluated NixOS configuration with:

```nix
hardware.development = true;
```

Development-host behavior applies only when this flag is true.

## Development Package Bucket

Development-host packages are collected through:

```nix
environment.developmentPackages
```

That bucket is merged into the evaluated system package set only for
development hosts.

## Required Tool Sources

`codex` is provided from the selected nixpkgs package set.

`specd` is provided by the repository package-set attribute:

```nix
pkgs.specd
```

`pkgs.specd` packages the genuine SpecD CLI from the `@specd/cli` project and
must remain an ordinary package-set member without host-specific installation
policy.

## Constraints

- Development-host classification is controlled by `hardware.development`.
- User-facing development tooling is selected through
  `environment.developmentPackages`.
- Package definitions under `pkgs` must not encode host installation policy.
