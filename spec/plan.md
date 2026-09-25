# Implementation Plan

This document tracks implementation plans for changes that are being carried
through the SDD process. It is not a normative requirements or system
specification document.

## PLAN-001: Align Host Classification And Provide Codex

Status: Draft

Related artifacts:

- Requirement: [`REQ-001: Development Hosts Provide Codex`](requirements.md#req-001-development-hosts-provide-codex)
- Specification: [`Host Classification`](system.md#host-classification)
- Specification: [`Development Host Tooling`](system.md#development-host-tooling)
- ADR: [`ADR-0001: Explicit Host Classification`](adr/0001-explicit-host-classification.md)
- ADR: [`ADR-0002: Remove pkgs.isDesktop`](adr/0002-remove-pkgs-isdesktop.md)

### Goal

Bring the implementation into conformance with the current system
specification and ADRs:

- host classification flags are disabled by default;
- each host or reusable host profile declares only the positive role flags it
  needs, with all omitted role flags staying disabled by default;
- package buckets are gated by their corresponding host classification flags;
- `pkgs.isDesktop` is removed from the package set interface;
- every evaluated development host provides the genuine `codex` CLI from
  stable nixpkgs in the primary user's command lookup path.

### Assumptions

- The stable nixpkgs package set currently contains `pkgs.codex`.
- Making `codex` available through `environment.systemPackages` is sufficient
  for the primary user's command lookup path.

### Constraints

- Host classification is determined by evaluated `hardware.*` role flags.
- Host classification flags are disabled by default.
- Each host or reusable host profile declares only the positive role flags it
  needs; omitted role flags remain disabled by default.
- Package buckets are gated by their corresponding host classification flags.
- `pkgs.isDesktop` is removed from the package set interface.
- Every generated host output, including inactive hosts, boot profiles, test
  profiles, and `generic`, must remain evaluable after defaults become false.
- The specification permits `codex` to also be available to non-primary users
  on a development host.

### Minimal Change Set

1. Update `modules/hardware/hosts/default.nix`:
   - make all host classification flags default to `false`;
   - remove the compatibility hack that forces `hardware.needGraphic = false`
     and `hardware.development = false` when `hardware.isNas` or
     `hardware.isVps` is true;
   - remove the `pkgs.isDesktop` overlay flag;
   - gate package buckets by their corresponding flags:
     `graphicPackages` by `hardware.needGraphic`,
     `developmentPackages` by `hardware.development`,
     `nasPackages` by `hardware.isNas`, and
     `vpsPackages` by `hardware.isVps`.
2. Add explicit positive host classification declarations to every
   host/profile output, relying on default `false` values for omitted roles.
3. Add `codex` to `environment.developmentPackages` in
   `config/applications/default.nix`.

### Intended Host Classification

This table preserves the currently implied behavior as the starting point for
review.

| Host/Profile | Laptop | NAS | VPS | VPS Client | Graphical | Development |
| --- | --- | --- | --- | --- | --- | --- |
| `ShvedGaming` | false | false | false | true | true | true |
| `ShvedMedia` | false | true | false | true | false | false |
| `gerrit` | false | false | true | false | false | false |
| `generic` | false | false | false | false | true | true |
| `bootWork` | false | false | false | false | true | true |
| `bootGaming` | false | false | false | false | true | true |
| `bootServer` | false | false | true | false | false | false |
| `testA` | false | false | false | false | true | true |
| `testB` | false | false | false | false | true | true |
| `testNas` | false | true | false | false | false | false |
| `testVps` | false | false | true | false | false | false |
| `Shvedov` | false | false | false | false | true | true |
| `Shvedov-NB` | true | false | false | false | true | true |
| `ShvedLaptop` | true | false | false | false | true | true |

### Out Of Scope

- Do not add a new package source, overlay, or wrapper for `codex`.
- Do not change `config.user.name` or Home Manager behavior.
- Do not redesign host roles beyond the flags already specified.
- Do not decide the long-term fate of inactive hosts.
- Do not review private downstream repositories in this change, except to note
  that `pkgs.isDesktop` removal requires follow-up review there.

### Validation Plan

Use targeted Nix evaluations rather than full host builds unless evaluation
reveals a need for broader validation.

The key purpose of validation is to confirm that current behavior is preserved
unless a change is required by the new classification design or by adding
`codex` to development hosts.

1. Verify that stable nixpkgs exposes the expected `codex` package:

   ```sh
   nix eval --raw .#nixosConfigurations.ShvedGaming.pkgs.codex.name
   ```

2. Verify that every generated host output evaluates after host classification
   defaults become false:

   ```sh
   nix eval .#nixosConfigurations.<Hostname>.config.system.build.toplevel.drvPath
   ```

3. Verify representative evaluated classification values:
   - `ShvedGaming`: `hardware.needGraphic = true`,
     `hardware.development = true`, `hardware.isVpsClient = true`;
   - `ShvedMedia`: `hardware.isNas = true`, `hardware.needGraphic = false`,
     `hardware.development = false`;
   - `gerrit`: `hardware.isVps = true`, `hardware.needGraphic = false`,
     `hardware.development = false`;
   - `Shvedov-NB` or `ShvedLaptop`: `hardware.isLaptop = true`.

   Example commands:

   ```sh
   nix eval .#nixosConfigurations.<Hostname>.config.hardware.needGraphic
   nix eval .#nixosConfigurations.<Hostname>.config.hardware.development
   nix eval .#nixosConfigurations.<Hostname>.config.hardware.isLaptop
   nix eval .#nixosConfigurations.<Hostname>.config.hardware.isNas
   nix eval .#nixosConfigurations.<Hostname>.config.hardware.isVps
   nix eval .#nixosConfigurations.<Hostname>.config.hardware.isVpsClient
   ```

4. Verify that no evaluated package set exposes `pkgs.isDesktop`.

   ```sh
   nix eval .#nixosConfigurations.<Hostname>.pkgs.isDesktop
   ```

   This command should fail with a missing attribute error.

5. Before adding `codex` to `environment.developmentPackages`, verify that the
   docs-disabled OS build derivation hash for each active host is unchanged by
   the host classification migration.

   This comparison disables NixOS documentation generation because generated
   documentation can embed module declaration source paths. Those source paths
   make the full toplevel derivation sensitive to unrelated flake source tree
   changes.

   ```sh
   nix eval --impure --raw --expr 'let flake = builtins.getFlake (toString ./.); extended = flake.outputs.extend { modules = [ ({ ... }: { documentation.nixos.enable = false; }) ]; }; in extended.nixosConfigurations.<Hostname>.config.system.build.toplevel.drvPath'
   nix eval --impure --raw --expr 'let flake = builtins.getFlake (toString ./.); extended = flake.outputs.extend { modules = [ ({ ... }: { documentation.nixos.enable = false; }) ]; }; in extended.nixosValidationConfigurations.<Hostname>.config.system.build.toplevel.drvPath'
   ```

   Use `nixosConfigurations` for active hosts whose deployable configuration is
   evaluable in the public checkout, and `nixosValidationConfigurations` for
   active hosts whose deployable configuration requires private values.

6. Verify that a development host includes `codex` in evaluated system
   packages.

   ```sh
   nix eval --json .#nixosConfigurations.<Hostname>.config.environment.systemPackages
   ```

7. Verify that a non-development host such as `ShvedMedia`, `gerrit`,
   `testNas`, or `testVps` does not receive `codex` through the development
   package bucket.

   ```sh
   nix eval --json .#nixosConfigurations.<Hostname>.config.environment.systemPackages
   ```

8. Verify structurally that `environment.developmentPackages` is gated by
   `hardware.development`, not by `hardware.needGraphic`.

   ```sh
   rg -n "developmentPackages|hardware\\.development|hardware\\.needGraphic" modules/hardware/hosts/default.nix
   ```

   The current repository does not define a headless development host output,
   so this check is performed by reviewing the package bucket aggregation
   expression.

### Review Notes

- The key implementation risk is preserving current behavior while changing
  classification defaults from enabling to disabling.
- The `environment.vpsPackages` gate is no longer out of scope because package
  bucket gates are part of the host classification contract.
- `pkgs.isDesktop` removal can break downstream package expressions, including
  private extensions not visible in this repository.

### Post-Implementation Validation Note

The validation plan above was incomplete for package additions to system
tooling. Evaluating `drvPath` and using `nix build --dry-run --no-link` did not
force enough package derivation attributes to catch a local `ripgrep` package
override failure introduced into the `codex` closure.

Future validation for changes that add packages to host system tooling should
include a real build without `--dry-run` for at least one affected active host,
for example:

```sh
nix build .#nixosConfigurations.ShvedGaming.config.system.build.toplevel --no-link
```

## PLAN-002: Add Validation Configurations With Test Stubs

Status: Draft

Related artifacts:

- Requirement:
  [`REQ-002: Validate Secret-Dependent Hosts Without Private Material`](requirements.md#req-002-validate-secret-dependent-hosts-without-private-material)
- Specification:
  [`Validation Configurations`](system.md#validation-configurations)

### Goal

Add a repository-owned validation path that can evaluate and build-plan
secret-dependent hosts without requiring private material, while keeping normal
deployable host outputs unchanged.

The immediate validation targets are:

- `ShvedMedia`, which currently needs `age.secrets.cloudflare` and
  `age.secrets.lastfm-navidrome` for full toplevel evaluation.
- `gerrit`, which currently needs `services.vps.domain` for full toplevel
  evaluation.

### Research Findings

A temporary local spike validated this mechanism:

- adding a test-only NixOS module to the host module stack can satisfy the
  missing private values without changing production `nixosConfigurations`;
- `age.secrets.<name>.file` is a suitable module-level interface for age secret
  placeholders;
- `services.vps.domain = lib.mkDefault "validation.invalid"` is sufficient for
  Gerrit toplevel evaluation when no private domain is present;
- separate validation outputs can expose full NixOS configuration objects that
  are usable with `nix eval`;
- production `nixosConfigurations.ShvedMedia` and `nixosConfigurations.gerrit`
  still fail without the private values, confirming that the validation stubs
  do not leak into deployable outputs.

The spike successfully evaluated:

```sh
nix eval --raw .#nixosValidationConfigurations.ShvedMedia.config.system.build.toplevel.drvPath
nix eval --raw .#nixosValidationConfigurations.gerrit.config.system.build.toplevel.drvPath
```

and successfully build-planned:

```sh
nix build --dry-run --no-link .#nixosValidationConfigurations.ShvedMedia.config.system.build.toplevel
nix build --dry-run --no-link .#nixosValidationConfigurations.gerrit.config.system.build.toplevel
```

### Output Shape

Expose validation configurations as a project-specific flake output:

```nix
nixosValidationConfigurations.<host>
```

This output is intentionally separate from `nixosConfigurations` so validation
hosts are not presented as deployable production systems.

The output is project-specific rather than a standard flake output. This is an
accepted tradeoff for now because it provides direct `config.*` introspection,
which is useful for SDD validation commands. Standard `checks` integration can
be added later if the repository decides to make broad `nix flake check`
behavior part of the validation contract.

### Minimal Change Set

1. Add a validation stub module under
   `tests/modules/stubs/private-values/default.nix`.
2. Add placeholder age files under
   `tests/modules/stubs/private-values/secrets/`.
3. In the validation stub module:
   - set `age.secrets.cloudflare.file` to the Cloudflare placeholder file;
   - set `age.secrets.lastfm-navidrome.file` to the Last.fm placeholder file;
   - set `services.vps.domain = lib.mkDefault "validation.invalid"`.
4. Update `lib/system.nix` so `mkExtendableSystems` accepts
   `validationModules`, defaults them to the repository private-value
   validation stub module, and derives `nixosValidationConfigurations` from
   the same extended hosts, base modules, `mkSystem`, `defaultSystem`, and
   `defaultHost` as `nixosConfigurations`, with validation modules appended to
   the validation module list only.
5. Expose the validation NixOS configurations from the extendable system set as:

   ```nix
   nixosValidationConfigurations.<host>
   ```

6. Keep the existing top-level output behavior unchanged for
   `nixosConfigurations`, `packages`, and `extend`.

### Validation Plan

1. Verify that validation configurations evaluate for the previously blocked
   active hosts:

   ```sh
   nix eval --raw .#nixosValidationConfigurations.ShvedMedia.config.system.build.toplevel.drvPath
   nix eval --raw .#nixosValidationConfigurations.gerrit.config.system.build.toplevel.drvPath
   ```

2. Verify that validation configurations can be build-planned:

   ```sh
   nix build --dry-run --no-link .#nixosValidationConfigurations.ShvedMedia.config.system.build.toplevel
   nix build --dry-run --no-link .#nixosValidationConfigurations.gerrit.config.system.build.toplevel
   ```

3. Verify that production deployable outputs still do not receive validation
   stubs implicitly:

   ```sh
   nix eval --raw .#nixosConfigurations.ShvedMedia.config.system.build.toplevel.drvPath
   nix eval --raw .#nixosConfigurations.gerrit.config.system.build.toplevel.drvPath
   ```

   In the public checkout without private values, these commands are expected
   to fail for the same missing-value reasons observed before this change.

4. Verify that the validation output is structurally available:

   ```sh
   nix eval --json .#nixosValidationConfigurations --apply builtins.attrNames
   ```

5. Verify that the documented `extend` usage still works after introducing
   validation configurations:

   ```sh
   nix eval --impure --json --expr 'let outputs = (builtins.getFlake (toString ./.)).outputs; extended = outputs.extend { hosts.newHost = { system = "aarch64-linux"; modules = [ ({ ... }: { user.name = "Validation"; }) ]; }; modules = [ ({ ... }: { }) ]; defaultHost = "newHost"; }; in { hostNames = builtins.attrNames extended.nixosConfigurations; validationHostNames = builtins.attrNames extended.nixosValidationConfigurations; hostSystem = extended.nixosConfigurations.newHost.pkgs.stdenv.hostPlatform.system; validationHostSystem = extended.nixosValidationConfigurations.newHost.pkgs.stdenv.hostPlatform.system; packageSystems = builtins.attrNames extended.packages; hasDefaultPackageSet = builtins.hasAttr "system" extended.packages.aarch64-linux; }'
   ```

   The result should include `newHost` in `hostNames` and
   `validationHostNames`, `hostSystem = "aarch64-linux"`,
   `validationHostSystem = "aarch64-linux"`, `aarch64-linux` in
   `packageSystems`, and `hasDefaultPackageSet = true`.

6. Verify that the placeholder files are non-secret test data:

   ```sh
   rg -n "validation|stub|dummy|invalid" tests/modules/stubs/private-values
   ```

### Out Of Scope

- Do not redesign the private extension mechanism.
- Do not add real secrets, encrypted production secrets, private domains, or
  private machine-local values to this repository.
- Do not move secret-consuming service configuration as part of this change.
- Do not make `nix flake check` semantics part of this plan.
- Do not remove the need for private material from real deployable host
  configurations.

### Review Notes

- The main risk is accidentally making validation substitutes available to
  production outputs. Keeping validation modules outside `nixosConfigurations`
  is the primary guardrail.
- The custom `nixosValidationConfigurations` output is intentionally a
  repository API. It should be documented as validation-only and not used for
  deployment.
- If future validation needs grow, this mechanism can be extended with per-host
  validation modules or a standard `checks.<system>.*` layer without changing
  the deployable host contract.

## PLAN-003: Provide Configured Ripgrep Without Overriding Package Set

Status: Draft

Related artifacts:

- Requirement:
  [`REQ-003: Provide Configured Ripgrep`](requirements.md#req-003-provide-configured-ripgrep)
- Specification:
  [`Project Layers`](system.md#project-layers)
- Specification:
  [`Configured Ripgrep`](system.md#configured-ripgrep)

### Goal

Provide the primary user with a configured `rg` command that understands the
repository's `cin` and extended `cc` file types, while keeping `pkgs.ripgrep`
as the ordinary stable nixpkgs package for unrelated package-set consumers.

### Problem Statement

The current repository configuration gives the user a configured `rg` command
by relying on a local `pkgs.ripgrep` package override. That crosses the
package/configuration layer boundary: a user-facing tool policy leaks into the
global package set.

This became visible when `codex` entered the system closure. The upstream
`codex` package depends on ordinary `pkgs.ripgrep`, so any repository-specific
change to the global `pkgs.ripgrep` package can affect unrelated packages.

### Assumptions

- The stable nixpkgs package set provides a working `pkgs.ripgrep`.
- The configured user-facing command can be implemented as a module-local
  overridden package based on stable `pkgs.ripgrep`.
- The repository's desired ripgrep configuration is limited to type
  definitions and can be supplied through `RIPGREP_CONFIG_PATH`.

### Constraints

- Do not globally override `pkgs.ripgrep` to apply repository user
  configuration.
- Keep the configured command available through `environment.systemPackages`.
- Keep the ordinary package-set `pkgs.ripgrep` usable by unrelated packages,
  including `codex`.
- Keep the implementation in the configuration layer unless a reusable module
  interface becomes necessary.
- Validation for this change must include a real affected-host build without
  `--dry-run`.

### Minimal Change Set

1. Remove the local by-name package override for `ripgrep`, or otherwise stop
   exposing repository-specific configured behavior as `pkgs.ripgrep`.
2. Update `config/tools/text/ripgrep/default.nix` so it creates a module-local
   overridden ripgrep package for the user-facing `rg` command.
3. The overridden package should:
   - use stable `pkgs.ripgrep` as the underlying implementation;
   - provide a repository-owned ripgrep configuration containing:

     ```text
     --type-add=cin:Config.in
     --type-add=cc:*.[chH], *.[chH].in, *.cats
     ```

   - set `RIPGREP_CONFIG_PATH` for its `rg` executable so it points at that
     configuration;
   - be installed through `environment.systemPackages`.

### Validation Plan

1. Verify that the ordinary package-set `ripgrep` remains available:

   ```sh
   nix eval --raw .#nixosConfigurations.ShvedGaming.pkgs.ripgrep.name
   ```

2. Verify that `codex` still evaluates against ordinary package-set
   dependencies:

   ```sh
   nix eval --raw .#nixosConfigurations.ShvedGaming.pkgs.codex.name
   ```

3. Verify that the configured ripgrep package is present in the evaluated system
   packages for `ShvedGaming`.

   The exact command may depend on the package name chosen in implementation,
   but it should inspect `config.environment.systemPackages` rather than only
   checking package availability in `pkgs`.

4. Verify the configured package behavior by building or running its `rg` and
   checking that `rg --type-list` includes:

   ```text
   cin: Config.in
   cc: *.[chH], *.[chH].in, *.cats
   ```

   The exact output formatting may differ; the validation should confirm the
   effective type definitions, not only the presence of a package.

5. Verify the affected active host with a real build, not only `drvPath`
   evaluation or dry-run build planning:

   ```sh
   nix build .#nixosConfigurations.ShvedGaming.config.system.build.toplevel --no-link
   ```

### Out Of Scope

- Do not change `codex` packaging.
- Do not introduce a new host role or package bucket.
- Do not redesign the repository package overlay mechanism.
- Do not move the existing ripgrep module to a different directory as part of
  this change.

### Review Notes

- The core design boundary is that `pkgs` provides packages, while `config`
  applies user-facing repository policy.
- Removing a by-name package override changes the package-set surface. Validate
  against at least the affected active host because `codex` depends on
  `pkgs.ripgrep`.
