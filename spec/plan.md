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
- each host or reusable host profile declares its intended classification
  explicitly;
- package buckets are gated by their corresponding host classification flags;
- `pkgs.isDesktop` is removed from the package set interface;
- every evaluated development host provides the genuine `codex` CLI from
  stable nixpkgs in the primary user's command lookup path.

### Assumptions

- The repository already has a project-wide system specification in a usable
  form for this task.
- Host classification is determined by evaluated `hardware.*` role flags.
- Every generated host output, including inactive hosts, boot profiles, test
  profiles, and `generic`, must remain evaluable after defaults become false.
- The stable nixpkgs package set currently contains `pkgs.codex`.
- Making `codex` available through `environment.systemPackages` is sufficient
  for the primary user's command lookup path.
- The specification permits `codex` to also be available to non-primary users
  on a development host.
- Current behavior should be preserved unless it conflicts with the new
  classification design.

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
2. Add explicit host classification declarations to every host/profile output.
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

1. Verify that stable nixpkgs exposes the expected `codex` package:

   ```sh
   nix eval --raw .#nixosConfigurations.ShvedGaming.pkgs.codex.name
   ```

2. Verify that every generated host output evaluates after host classification
   defaults become false.

3. Verify representative evaluated classification values:
   - `ShvedGaming`: `hardware.needGraphic = true`,
     `hardware.development = true`, `hardware.isVpsClient = true`;
   - `ShvedMedia`: `hardware.isNas = true`, `hardware.needGraphic = false`,
     `hardware.development = false`;
   - `gerrit`: `hardware.isVps = true`, `hardware.needGraphic = false`,
     `hardware.development = false`;
   - `Shvedov-NB` or `ShvedLaptop`: `hardware.isLaptop = true`.

4. Verify that no evaluated package set exposes `pkgs.isDesktop`.

5. Verify that a development host includes `codex` in evaluated system
   packages.

6. Verify that a non-development host such as `ShvedMedia`, `gerrit`,
   `testNas`, or `testVps` does not receive `codex` through the development
   package bucket.

7. Verify that the package bucket gate follows `hardware.development`, not
   `hardware.needGraphic`, so a headless development host would still receive
   development tooling.

### Review Notes

- The key implementation risk is preserving current behavior while changing
  classification defaults from enabling to disabling.
- The `environment.vpsPackages` gate is no longer out of scope because package
  bucket gates are part of the host classification contract.
- `pkgs.isDesktop` removal can break downstream package expressions, including
  private extensions not visible in this repository.
