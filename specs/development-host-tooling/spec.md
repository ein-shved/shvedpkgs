# Development Host Tooling

## Purpose

This spec captures the steady-state contract for tools that must be available
on hosts classified as development hosts. It mirrors the current SDD
requirements and system specification so SpecD can provide focused context for
future tooling changes.

## Spec Dependencies

_none_

## Requirements

### Requirement: Development hosts expose required workflow tools

Development hosts MUST make the required repository workflow tools available in
the primary user's command lookup path.

The required tools are:

- `codex`
- `specd`

The `codex` command MUST resolve to the genuine Codex CLI supplied by the
selected package source.

The `specd` command MUST resolve to the genuine SpecD CLI supplied by the
repository package-set attribute `pkgs.specd`.

### Requirement: Non-development hosts are not required to expose development tooling

Hosts that are not classified as development hosts MUST NOT be required by this
spec to expose `codex`, `specd`, or other development-host-only workflow tools.

### Requirement: Tooling selection belongs to development host configuration

Packages required only because a host is a development host MUST be selected
through development-host configuration policy rather than by encoding
host-specific installation policy in package definitions.

## Constraints

- The development host classification is `hardware.development = true`.
- Development-host packages are collected through `environment.developmentPackages`.
- Package definitions under `pkgs` must remain ordinary package-set members.
