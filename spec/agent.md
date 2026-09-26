# Agent Guide

This file is the starting map for agents working in this repository. It
does not define the SDD process and does not replace the project
artifacts under `spec/`.

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
inventory and repository map is [`spec/context.md`](context.md).

## Process Entry Points

- [`spec/sdd-process.md`](sdd-process.md): authoritative SDD process.
- [`spec/sdd-process.ru.md`](sdd-process.ru.md): Russian translation of
  the process.
- [`spec/requirements.md`](requirements.md): accepted or working
  project needs.
- [`spec/system.md`](system.md): current normative system contract.
- [`spec/adr/`](adr/): significant decisions and their rationale.
- [`spec/plan.md`](plan.md): implementation transition plans.
- [`spec/task.md`](task.md): project Tasks derived from accepted Plans.
- [`spec/todo.md`](todo.md): known open questions, cleanup candidates,
  and suspicious areas.
- [`spec/context.md`](context.md): optional non-normative project
  inventory and orientation material.

If these artifacts disagree, follow the precedence and correction rules
in [`spec/sdd-process.md`](sdd-process.md). In short: find the earliest
affected artifact, correct it first, then reconsider downstream
artifacts.

## Process Authority

Follow [`spec/sdd-process.md`](sdd-process.md) strictly for SDD process
rules, artifact responsibilities, dependency flow, Discovery/Spike,
ADR handling, validation, and completion criteria.

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
- `spec/`: SDD artifacts and project context.

Layer rule summary:

- `modules/` defines reusable options and domain behavior behind those
  options.
- `config/` applies project policy and should consume options rather
  than define new ones.
- `hosts/` assembles concrete machines and profiles.
- `pkgs/` owns local packages and package overrides.

Use [`spec/context.md`](context.md) for more detailed current-state
orientation.

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
