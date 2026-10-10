# Agent Guide

This file is the starting map for agents working in this repository. It
does not define the SDD process and does not replace the project
artifacts under `specs/`.

Use Russian when talking with the user unless they ask otherwise.

## Project Summary

This repository contains personal Nix/NixOS configuration for multiple
machines: workstations, laptops, a NAS/media server, a Gerrit VPS,
bootable profiles, and VM/test-oriented profiles.

The repository behaves more like an extended personal nixpkgs/NixOS
configuration set than a small application flake. Broad output
enumeration can be expensive or noisy; prefer targeted evaluation and
targeted builds.

The main entry point is [`flake.nix`](../flake.nix). The current project
specification set is organized as indexed SpecD sections under
[`specs/`](../specs).
The non-normative repository map is
[`specs/001-project-architecture/inventory.md`](../specs/001-project-architecture/inventory.md).

## Process Entry Points

- [`specs/000-sdd-process/rules.md`](../specs/000-sdd-process/rules.md):
  authoritative SDD process.
- [`specs/000-sdd-process/rules.ru.md`](../specs/000-sdd-process/rules.ru.md):
  Russian translation of
  the process.
- [`specs/000-sdd-process/`](../specs/000-sdd-process/):
  SpecD integration and process-facing contracts.
- [`specs/001-project-architecture/`](../specs/001-project-architecture/):
  repository layer boundaries, primary-user semantics, package-source
  handling, document-order ADRs, and non-normative repository inventory.
- [`specs/002-host-classification/`](../specs/002-host-classification/):
  host role flags, package buckets, derived package-set flags, and migrated
  host-classification ADRs.
- [`specs/003-testing-infrastructure/`](../specs/003-testing-infrastructure/):
  validation-only configurations and test-only private-value stubs.
- [`specs/004-generic-host-tooling/`](../specs/004-generic-host-tooling/):
  configured generic host tools such as the user-facing `rg` wrapper.
- [`specs/005-development-host-tooling/`](../specs/005-development-host-tooling/):
  development-host workflow tooling such as `codex` and `specd`.
- [`spec/plan.md`](plan.md), [`spec/task.md`](task.md), and
  [`spec/todo.md`](todo.md): historical or transitional planning material.

If these artifacts disagree, follow the precedence and correction rules
in [`specs/000-sdd-process/rules.md`](../specs/000-sdd-process/rules.md). In short: find the earliest
affected artifact, correct it first, then reconsider downstream
artifacts.

## Process Authority

Follow [`specs/000-sdd-process/rules.md`](../specs/000-sdd-process/rules.md)
strictly for SDD process rules, artifact responsibilities, dependency flow,
Discovery/Spike, ADR handling, validation, and completion criteria.

This file is only a navigation aid. Do not use it as a source of
requirements, system guarantees, process rules, or implementation
decisions.

## Repository Shape

Important top-level areas:

- `flake.nix`: flake entry point.
- `lib/`: local library extensions and system assembly helpers.
- `hosts/`: concrete host definitions, boot profiles, and test/VM
  profiles.
- `modules/`: reusable NixOS modules and custom options.
- `config/`: opinionated global configuration consuming those options.
- `pkgs/`: local package overlay using nixpkgs by-name layout.
- `tests/`: validation and test support.
- `spec/`: historical and transitional SDD planning artifacts.
- `specs/`: indexed SpecD-owned requirements, system specifications,
  verification scenarios, optional inventory, ADRs, and process documents.

Layer rule summary:

- `modules/` defines reusable options and domain behavior behind those
  options.
- `config/` applies project policy and should consume options rather
  than define new ones.
- `hosts/` assembles concrete machines and profiles.
- `pkgs/` owns local packages and package overrides.

Use [`specs/001-project-architecture/inventory.md`](../specs/001-project-architecture/inventory.md)
for non-normative current-state orientation. Use the indexed SpecD
requirements, system, verification, and ADR artifacts for contracts.

## Validation Orientation

The flake exposes normal deployable NixOS configurations and
validation-only configurations:

```nix
nixosConfigurations.<host>
nixosValidationConfigurations.<host>
```

Validation configurations exist for repository validation and build
planning when deployable hosts require private values absent from the
public checkout.

Use validation commands from the relevant Plan or Task when available.
When no task-specific validation is defined, prefer targeted `nix eval`
or dry-run builds over broad flake enumeration.

## Private And External Boundaries

Some behavior depends on secrets, hardware tokens, network access,
private hosts, or separate personal repositories. Keep those boundaries
explicit. Do not absorb external source trees into this repository just
because they are integrated by the flake.

When public validation needs private values, use validation stubs rather
than weakening the deployable configuration.
