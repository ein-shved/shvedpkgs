# Configured Ripgrep

The system provides a configured `ripgrep` command for the primary user.

The package-set attribute `pkgs.ripgrep` MUST remain the ordinary stable
nixpkgs `ripgrep` package. Repository-specific configuration MUST NOT be
implemented by globally overriding `pkgs.ripgrep`, because other package-set
consumers may depend on the ordinary unconfigured package.

The repository enables the configured command through the NixOS module:

```nix
config/tools/text/ripgrep/default.nix
```

That module creates a module-local overridden ripgrep package and installs that
package into `environment.systemPackages`. The override is local to the module
expression and MUST NOT be exposed as the package-set attribute
`pkgs.ripgrep`.

The module-local overridden package MUST:

- use the stable nixpkgs `ripgrep` package as its underlying implementation;
- create or reference a repository-owned ripgrep configuration file containing
  these custom file type definitions:

  ```text
  --type-add=cin:Config.in
  --type-add=cc:*.[chH], *.[chH].in, *.cats
  ```

- expose `rg` in the user's command lookup path;
- set `RIPGREP_CONFIG_PATH` for its `rg` executable so the custom
  configuration is used.

The configured package's repository configuration MUST remain local to the
package installed by the module. It MUST NOT change how packages that depend on
`pkgs.ripgrep` build or run.

Traceability:

- Satisfies
  [`REQ-001: Provide Configured Ripgrep`](requirements.md#req-001-provide-configured-ripgrep).
