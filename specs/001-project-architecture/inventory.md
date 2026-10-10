# Inventory: Project Architecture

This inventory is a non-normative map for navigating the repository. It does
not define requirements, system guarantees, verification scenarios, or
architecture decisions.

## Orientation

This repository contains personal Nix/NixOS configuration for multiple
machines: workstations, laptops, a NAS/media server, a Gerrit VPS, bootable
profiles, and VM/test-oriented profiles.

The repository behaves more like an extended personal nixpkgs/NixOS
configuration set than a small application flake. Broad output enumeration can
be expensive or noisy; targeted evaluation and targeted builds are usually more
useful.

## Current Entry Points

- `flake.nix`: main flake entry point.
- `lib/`: helper functions for constructing flake outputs and NixOS system
  sets.
- `hosts/default.nix`: concrete host set assembly.
- `config/nixos.nix`: global project configuration imports.
- `modules/nixos.nix`: reusable module imports.
- `pkgs/default.nix`: local package overlay entry point.
- `tests/`: validation and test support.
- `spec/`: historical or transitional SDD planning material.
- `specs/`: indexed SpecD-owned SDD artifacts and process documents.

## Current Repository Areas

- `hosts/`: concrete host definitions, boot profiles, and VM/test profiles.
- `modules/`: reusable NixOS modules and custom option interfaces.
- `config/`: repository policy that consumes NixOS, Home Manager, nixpkgs, or
  repository module options.
- `pkgs/`: local by-name package definitions and package-set extensions.
- `lib/`: local library extensions and system assembly helpers.
- `tests/modules/`: test-only module support.
- `tests/pkgs/`: package-oriented test support.

## External And Private Boundaries

Some behavior depends on secrets, hardware tokens, network access, private
hosts, or separate personal repositories. Those boundaries should remain
explicit. Integrated external source trees should not be absorbed into this
repository merely because the flake references them.

Target machines may assemble final configuration from this repository plus
private extensions. Those private extensions can contain secrets and
machine-specific assembly code that is intentionally absent from this
repository.

## Validation Orientation

Use task-specific validation commands when they are available. When no
task-specific validation is defined, prefer targeted `nix eval` or dry-run
builds over broad flake enumeration.

Validation-only support lives under `tests/` and should stay separate from
deployable host configuration.

## Staleness Notes

When repository structure, entry points, host inventory, module
responsibilities, package inventory, validation support, or other orientation
material changes, refresh this inventory only for still-useful orientation.
Durable requirements, system contracts, validation scenarios, and decisions
belong in their owning SDD artifacts instead.
