# Requirements

## REQ-001: Development hosts expose required workflow tools

Development hosts must make the required repository workflow tools available
in the primary user's command lookup path.

The required tools are:

- `codex`
- `specd`

Each listed command must resolve to the widely recognized developer tool
identified by that command name at the time the command is added to this
list. For example, `codex` means the genuine Codex CLI originated by
OpenAI, and `git` means the distributed version control system originally
created by Linus Torvalds. Listed commands must not resolve to stubs,
placeholders, or unrelated executables unless this document explicitly says
otherwise.

### Rationale

Development hosts support the repository SDD workflow and related project
maintenance. Providing the tools through host configuration keeps the workflow
reproducible across development machines.

## REQ-002: Non-development hosts are not required to expose development tooling

Hosts that are not classified as development hosts are not required by this
spec to expose `codex`, `specd`, or other development-host-only workflow tools.

## REQ-003: Tooling selection belongs to development host configuration

Packages required only because a host is a development host must be selected
through development-host configuration policy rather than by encoding
host-specific installation policy in package definitions.
