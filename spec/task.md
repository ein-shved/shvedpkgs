# Tasks

This document tracks implementation tasks derived from SDD plans. It is a work
queue, not a requirements or system specification document.

Each task is expected to leave the system in an agreed and validated state.
Validation is a completion criterion for the task, not a separate task.

If implementation work is committed, the execution artifact should be either
one atomic self-contained commit or a chain of atomic self-contained commits.

## PLAN-001: Align Host Classification And Provide Codex

Source plan: [`PLAN-001`](plan.md#plan-001-align-host-classification-and-provide-codex)

- [ ] Capture the pre-migration baseline for active hosts.

  Record OS build derivation paths for `ShvedGaming`, `ShvedMedia`, and
  `gerrit` before implementation changes. Use the validation commands from
  `PLAN-001`.

  Progress:

  - `ShvedGaming` baseline captured:
    `/nix/store/p24w3jhj5ysix9flygddis7wxqjw793j-nixos-system-ShvedGaming-26.05.20260806.445d861.drv`
  - `ShvedMedia` baseline is blocked in this repository state because
    evaluating `config.system.build.toplevel.drvPath` requires
    `config.age.secrets.cloudflare`.
  - `gerrit` baseline is blocked in this repository state because evaluating
    `config.system.build.toplevel.drvPath` requires `services.vps.domain`.

- [ ] Migrate host classification to the explicit model.

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

- [ ] Expose and validate validation NixOS configurations.

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

- [ ] Update context after validation infrastructure implementation.

  Update `spec/context.md` if implementation changes make the current context
  stale, especially around test support layout, secret-dependent validation, or
  active-host validation workflow.
