# Requirements

## Requirement: Development hosts expose required workflow tools

Development hosts must make the required repository workflow tools available in
the primary user's command lookup path.

The required tools are:

- `codex`
- `specd`

The `codex` command must resolve to the genuine Codex CLI supplied by the
selected package source.

The `specd` command must resolve to the genuine SpecD CLI supplied by the
repository package-set attribute `pkgs.specd`.

## Requirement: Non-development hosts are not required to expose development tooling

Hosts that are not classified as development hosts are not required by this
spec to expose `codex`, `specd`, or other development-host-only workflow tools.

## Requirement: Tooling selection belongs to development host configuration

Packages required only because a host is a development host must be selected
through development-host configuration policy rather than by encoding
host-specific installation policy in package definitions.
