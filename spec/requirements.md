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

## REQ-004: Development Hosts Provide SpecD

Hosts intended for development must provide the `specd` tool in the user
environment. Here, `specd` refers to the genuine SpecD CLI from the
`@specd/cli` project, rather than SpecDD, a stub, placeholder, or unrelated
executable exposed under the `specd` command name.

### Rationale

- SpecD is being evaluated as candidate tooling for agent-assisted SDD in this
  repository.
- The evaluation should be reproducible across development machines, not tied
  to one specific host.
- Providing SpecD on development hosts allows the project to test whether the
  tool can carry the current SDD artifacts, project state, and active work
  without changing the SDD model defined by `spec/sdd-process.md`.

### Validation scenarios

The scenarios below are an experimental replacement for acceptance criteria in
this requirement only. The project has not yet adopted scenarios as the general
requirement validation model.

#### Scenario: Development host can invoke SpecD

- **WHERE** a host is classified as a development host.
- **WHEN** the primary user runs the `specd` command with any valid arguments.
- **THEN** the command resolves to the genuine SpecD CLI.
- **AND** the result corresponds to the behavior of the genuine SpecD CLI.

#### Scenario: SpecD can be used for repository evaluation

- **WHERE** a development host has valid runtime prerequisites for SpecD.
- **WHEN** the primary user runs the `specd` command against this repository
  with any valid workflow arguments.
- **THEN** SpecD performs the requested repository/specification workflow.
- **AND** the result corresponds to the behavior of the genuine SpecD CLI.
- **AND** the workflow does not rely on host-local manual installation outside
  the evaluated system configuration.

#### Scenario: Non-development hosts are not required to provide SpecD

- **WHERE** a host is not intended for development.
- **WHEN** that host is evaluated.
- **THEN** the evaluated host configuration is not required to provide `specd`.
- **AND** any absence of `specd` on that host does not violate this
  requirement merely because development hosts provide it.
