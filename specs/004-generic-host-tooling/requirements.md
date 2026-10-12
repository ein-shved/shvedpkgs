# Requirements

## REQ-001: Provide Configured Ripgrep

The primary user must have the `ripgrep` command-line search utility available
with the repository's custom search type configuration.

The configuration must let the primary user search `Config.in` files as a
distinct file category. It must also make C/C++ file-type searches include
template variants of C/C++ files that use an additional `.in` extension.

The configured utility must preserve the ordinary package-set `pkgs.ripgrep`
behavior for unrelated package consumers. Repository-specific configuration
must not change the global `pkgs.ripgrep` package contract.

### Rationale

- `ripgrep` is a baseline text-search tool used during repository maintenance
  and SDD work.
- The repository relies on file categories when searching source and generated
  configuration files.
- Upstream `ripgrep` does not provide the repository's desired `Config.in`
  search behavior and does not include C/C++ template files in the desired
  C/C++ file-type searches.
- Other packages may depend on the ordinary package-set `ripgrep` package.
  The configured package must not make unrelated consumers fail when they use
  unconfigured `pkgs.ripgrep`.

### Scenario: Primary user can invoke configured rg

- WHEN the primary user searches from the host command line
- THEN the `rg` command is available to the primary user
- AND it uses the repository's custom search type configuration

### Scenario: Config.in files are separately searchable

- WHEN the primary user searches only the file category used for `Config.in` files
- THEN `Config.in` files are included in the search
- AND the requirement does not prescribe the argument name used for that category

### Scenario: C/C++ file-type searches include template files

- WHEN the primary user searches C/C++ file types
- THEN template variants of C/C++ files with an additional `.in` extension are included in the search
- AND the requirement does not prescribe the exact pattern used to recognize those files

### Scenario: Package-set ripgrep remains ordinary for unrelated consumers

- WHEN another package or package-set consumer depends on `pkgs.ripgrep`
- THEN it can use the ordinary unconfigured `pkgs.ripgrep` package
- AND it is not forced to consume the repository's configured user-facing `rg`
