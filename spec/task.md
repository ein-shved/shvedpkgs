# Tasks

This document tracks implementation tasks derived from SDD plans. It is a work
queue, not a requirements or system specification document.

Each task is expected to leave the system in an agreed and validated state.
Validation is a completion criterion for the task, not a separate task.

If implementation work is committed, the execution artifact should be either
one atomic self-contained commit or a chain of atomic self-contained commits.

## PLAN-001: Align Host Classification And Provide Codex

Source plan: [`PLAN-001`](plan.md#plan-001-align-host-classification-and-provide-codex)

- [x] Capture the pre-migration baseline for active hosts.

  Record OS build derivation paths for `ShvedGaming`, `ShvedMedia`, and
  `gerrit` before implementation changes. Use the validation commands from
  `PLAN-001`.

  Progress:

  - Captured docs-disabled `ShvedGaming` production baseline:
    `/nix/store/j21abnv26d31wlk74i0cjfiqmh037187-nixos-system-ShvedGaming-26.05.20260806.445d861.drv`
  - Captured docs-disabled `ShvedMedia` validation baseline:
    `/nix/store/0mxw4mgv20kpdgna39xi45nb0kq88rzp-nixos-system-ShvedMedia-26.05.20260806.445d861.drv`
  - Captured docs-disabled `gerrit` validation baseline:
    `/nix/store/hm36fwjn91pn17x6dsr6zzz6r8k7sb9m-nixos-system-gerrit-26.05.20260806.445d861.drv`
  - Baseline capture uses an `extend` module with
    `documentation.nixos.enable = false` because generated documentation makes
    the full toplevel derivation sensitive to unrelated flake source tree
    changes.
  - `ShvedMedia` and `gerrit` use validation configurations for this baseline
    because their deployable production outputs intentionally still require
    private values in the public checkout.

- [x] Migrate host classification to the explicit model.

  Update `modules/hardware/hosts/default.nix` so classification flags default
  to `false`, package buckets are gated by their matching classification flags,
  and obsolete host-derived package-set behavior such as `pkgs.isDesktop` is
  removed.

  Apply the intended classification table from `PLAN-001` to real hosts,
  inactive hosts, boot profiles, test profiles, and `generic` by declaring only
  positive role flags and relying on default `false` values for omitted roles,
  so all generated outputs remain evaluable without relying on enabling
  defaults.

  Completion criteria: run the classification validation from `PLAN-001`,
  including active-host derivation comparison before `codex` is added.

  Progress:

  - Changed host classification defaults for `hardware.needGraphic` and
    `hardware.development` to `false`.
  - Removed the derived `pkgs.isDesktop` overlay attribute.
  - Gated package buckets by their matching explicit classification flags:
    graphics by `hardware.needGraphic`, development by
    `hardware.development`, NAS by `hardware.isNas`, and VPS by
    `hardware.isVps`.
  - Applied the classification table to real hosts, inactive hosts, boot
    profiles, test profiles, and `generic` by declaring only positive role
    flags and relying on default `false` values for omitted roles.
  - Fixed `Shvedov-NB` evaluation by deriving the build-machine `system` from
    `pkgs.stdenv.system` instead of an unprovided module argument.
  - Verified the evaluated classification matrix for all validation
    configurations matches `PLAN-001`.
  - Verified `pkgs.codex` remains available before package-bucket wiring, and
    verified `pkgs.isDesktop` is absent from production and validation package
    sets.
  - Verified docs-disabled active-host derivation paths remain unchanged:
    `ShvedGaming`,
    `/nix/store/j21abnv26d31wlk74i0cjfiqmh037187-nixos-system-ShvedGaming-26.05.20260806.445d861.drv`;
    `ShvedMedia`,
    `/nix/store/0mxw4mgv20kpdgna39xi45nb0kq88rzp-nixos-system-ShvedMedia-26.05.20260806.445d861.drv`;
    and `gerrit`,
    `/nix/store/hm36fwjn91pn17x6dsr6zzz6r8k7sb9m-nixos-system-gerrit-26.05.20260806.445d861.drv`.
  - Verified real and test validation configurations evaluate to toplevel
    derivation paths after the migration. Full toplevel evaluation for
    `bootWork`, `bootGaming`, `bootServer`, and `generic` remains blocked by
    their pre-existing incomplete bootable-system definitions, namely missing
    root file system and GRUB device settings; their classification options
    still evaluate as part of the all-output classification matrix check.

- [ ] Add `codex` to development host tooling.

  Add `codex` to the development package bucket using stable nixpkgs, without
  introducing a new package source, overlay, or wrapper.

  Completion criteria: confirm that development hosts receive `codex` through
  evaluated system packages and that non-development hosts do not receive it
  through the development package bucket.

- [ ] Update context after implementation.

  Update `spec/context.md` to reflect any current-state information made stale
  by the completed implementation.

## PLAN-002: Add Validation Configurations With Test Stubs

Source plan: [`PLAN-002`](plan.md#plan-002-add-validation-configurations-with-test-stubs)

- [x] Add private-value validation stubs.

  Add a test-only NixOS module under
  `tests/modules/stubs/private-values/default.nix`.

  Add placeholder age files under
  `tests/modules/stubs/private-values/secrets/` for the currently observed
  secret-dependent validation blockers.

  The stubs must use normal module interfaces, including
  `age.secrets.<name>.file`, and must contain only non-secret test data.

  Completion criteria: verify that the placeholder files are clearly test-only
  and contain no real credentials, private domains, private keys, or
  machine-local secret material.

  Progress:

  - Added `tests/modules/stubs/private-values/default.nix`.
  - Added test-only placeholder age files for `cloudflare` and
    `lastfm-navidrome`.
  - Added a narrow `.gitignore` exception so the test-only placeholder files
    under `tests/modules/stubs/private-values/secrets/` are tracked despite the
    repository-wide `secrets/` ignore rule.
  - Verified the stub module evaluates locally and the placeholder files contain
    only explicit non-secret validation stub text.

- [x] Expose and validate validation NixOS configurations.

  Update the extendable system-set implementation so it derives validation
  NixOS configurations from the same hosts and base modules, with the
  private-value validation stub module appended through validation-only module
  inputs.

  Expose the resulting NixOS configuration objects through the project-specific
  output `nixosValidationConfigurations`.

  Completion criteria: `nixosConfigurations`, `packages`, and `extend` keep
  their existing top-level behavior; validation configurations are not exposed
  as deployable production host configurations; `ShvedMedia` and `gerrit`
  validation configurations produce `config.system.build.toplevel.drvPath` and
  can be build-planned with `nix build --dry-run --no-link`; the validation
  output exposes the expected host names; and, in the public checkout without
  private values, the normal deployable outputs still fail for the same
  missing private-value reasons observed before this change.

  Progress:

  - Updated `lib/system.nix` so `mkExtendableSystems` accepts
    `validationModules`, defaults them to the private-value validation stub
    module, and derives `nixosValidationConfigurations` from the same extended
    system set as `nixosConfigurations`.
  - Verified `nixosValidationConfigurations` and `nixosConfigurations` expose
    the expected host names, and `packages` still exposes `x86_64-linux`.
  - Verified the documented `extend` usage with a synthetic `newHost`,
    including host extension, `aarch64-linux` host system selection, and
    `defaultHost` package-set behavior.
  - Verified validation `drvPath` evaluation and dry-run build planning for
    `ShvedMedia` and `gerrit`.
  - Verified normal deployable outputs still fail without private values:
    `ShvedMedia` on missing `age.secrets.cloudflare`, and `gerrit` on missing
    `services.vps.domain`.

- [ ] Update context after validation infrastructure implementation.

  Update `spec/context.md` if implementation changes make the current context
  stale, especially around test support layout, secret-dependent validation, or
  active-host validation workflow.
