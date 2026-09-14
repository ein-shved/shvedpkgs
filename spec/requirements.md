# Requirements

This document tracks system-level requirements. Requirements describe intended
behavior and constraints; implementation details belong in design notes and
code changes.

## REQ-001: Development Hosts Provide Codex

Hosts intended for development must provide the `codex` tool in the user
environment. Here, `codex` refers to the genuine Codex CLI (initially by
OpenAI), rather than a stub, placeholder, or unrelated executable exposed
under the `codex` command name.

### Rationale

- Development hosts are expected to support the SDD workflow used for this
  repository and other projects.
- Codex is part of the expected development workflow and should be reproducible
  across development machines, not tied to one specific host.

### Acceptance criteria

- On a development host, the primary user can invoke `codex`.
- Given valid credentials and network connectivity, `codex` can successfully
  communicate with the service it is designed to use and perform its intended
  function.
- Hosts that are not intended for development are not required to provide
  `codex`.
