# Requirements

## REQ-001: Provide Configured Ripgrep

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
