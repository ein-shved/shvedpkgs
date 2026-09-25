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

## REQ-002: Validate Secret-Dependent Hosts Without Private Material

The repository must support evaluation and build-planning validation for host
configurations that normally depend on private secrets or downstream private
values, without requiring those private inputs to be present in the public
checkout.

Validation support must make it possible to identify the host system build in a
test context. It must not replace or weaken the final host configurations used
for deployment.

### Rationale

- SDD changes need reproducible validation commands that work from the public
  repository state.
- Some active hosts intentionally depend on private or machine-specific values.
- Missing private values should not prevent validating unrelated structural
  changes when safe test substitutes are sufficient.
- Test substitutes must remain clearly separated from deployable host
  configurations.

### Acceptance criteria

- For a host whose normal configuration depends on private values, a validation
  command can identify the host system build without requiring the real private
  values.
- Validation substitutes do not implicitly affect final deployable host
  configurations.
- Validation substitutes are stored in repository test support files rather
  than embedded in production host configuration.
- Validation substitutes are explicitly identifiable as test-only values.

## REQ-003: Provide Configured Ripgrep

The primary user must have the `ripgrep` command-line search utility available
with the repository's custom search type configuration.

The configuration must add search support for the repository-specific `cin`
file type and extend the standard C/C++ search type to cover the repository's
additional C-family file patterns.

The configured utility must preserve the ordinary package-set `pkgs.ripgrep`
behavior for unrelated package consumers. Repository-specific configuration
must be applied by a module-local overridden ripgrep package installed for
users, not by changing the global `pkgs.ripgrep` package contract.

### Rationale

- `ripgrep` is a baseline text-search tool used during repository maintenance
  and SDD work.
- The repository relies on custom file type definitions when searching source
  and generated configuration files.
- Upstream `ripgrep` does not know the repository's `cin` file type and does
  not include all local C-family file patterns in the desired C/C++ search
  type.
- Other packages may depend on the ordinary package-set `ripgrep` package.
  The configured package must not make unrelated consumers fail when they use
  unconfigured `pkgs.ripgrep`.

### Acceptance criteria

- The primary user can invoke `rg`.
- The configured `rg` recognizes `Config.in` files as type `cin`.
- The configured `rg` treats `*.[chH]`, `*.[chH].in`, and `*.cats` files as
  type `cc`.
- The unconfigured `pkgs.ripgrep` package remains usable by package-set
  consumers and is not globally overridden with repository configuration.
- Adding another package that depends on `pkgs.ripgrep` does not force that
  package to consume the repository's configured ripgrep package.
