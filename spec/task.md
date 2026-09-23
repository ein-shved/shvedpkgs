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
