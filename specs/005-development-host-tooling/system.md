# System Specification

## Development Host Tooling

For every [development host](#development-host), the
[primary user](#primary-user) has these development tools available in
the command lookup path:

* `codex`
* `specd`

`codex` is provided from [nixpkgs stable](#nixpkgs-stable).

`specd` is provided by the repository package-set attribute
`pkgs.specd`, which packages the genuine SpecD CLI from the `@specd/cli`
project.

If a host is not a [development host](#development-host), or the user is
not the [primary user](#primary-user), these packages MAY NOT be available
in the command lookup path.

Traceability:

- Satisfies
  [`REQ-001: Development hosts expose required workflow tools`](requirements.md#req-001-development-hosts-expose-required-workflow-tools).
- Satisfies
  [`REQ-002: Non-development hosts are not required to expose development tooling`](requirements.md#req-002-non-development-hosts-are-not-required-to-expose-development-tooling).

## SpecD CLI Package

The repository package set provides:

```nix
pkgs.specd
```

`pkgs.specd` is the package-set member for the genuine SpecD CLI from
the `@specd/cli` project. It MUST expose the `specd` command.

The package SHOULD behave like an ordinary package-set member under the
[`pkgs`](#pkgs) layer. It MUST NOT encode host-specific policy. Host
selection for installing `specd` belongs to [Development Host Tooling](#development-host-tooling).

The package contract is validated by a repository per-package NixOS test under
the `tests/pkgs/` test-support area. The test boots a minimal test machine with
`pkgs.specd` installed and verifies that invoking `specd` with valid inspection
arguments succeeds and reports behavior consistent with the genuine SpecD CLI.
