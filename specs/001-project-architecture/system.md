# System Concepts

## Primary User

For each host configuration, the primary user is the user identified by:

```nix
config.user.name
```

System properties that refer to "the primary user" apply to that account on
the evaluated host configuration.

## Project Layers

The repository is organized into layers with distinct roles. Changes SHOULD
respect these boundaries unless a specification explicitly changes the layer
model.

### `lib`

The `lib` layer provides helper functions for assembling and transforming the
repository's flake outputs and NixOS system sets.

`lib` MAY define reusable Nix functions, output constructors, and extension
mechanisms. It MUST NOT encode host-specific policy that belongs in host or
configuration modules.

### `pkgs`

The `pkgs` layer provides package definitions and package-set extensions.

The `pkgs` layer is built as a by-name overlay following the nixpkgs by-name
overlay pattern. Package definitions are exposed as package-set attributes by
their by-name path.

Package definitions in this repository receive `pkgsOrigin`, which is the
original package set from nixpkgs before this repository's by-name overlay is
applied. Package definitions SHOULD use `pkgsOrigin` when they need to refer to
the upstream package that they extend or wrap.

Package definitions under `pkgs` SHOULD behave like ordinary package-set
members. They may expose package-specific override arguments, but they MUST NOT
encode user or host policy that should instead be applied by a NixOS module.

When repository-specific user behavior needs a configured command-line tool,
the package-set member SHOULD remain usable by unrelated package consumers, and
the user-facing configuration SHOULD be applied in the appropriate module or
configuration layer.

### `modules`

The `modules` layer defines reusable NixOS module interfaces and the behavior
owned by those interfaces.

Files under `modules` SHOULD introduce or own options and may implement
configuration derived from those options. They SHOULD NOT be used for broad
repository policy that merely consumes existing options.

### `config`

The `config` layer applies repository policy across hosts by consuming existing
options from NixOS, Home Manager, nixpkgs modules, or this repository's
`modules` layer.

Files under `config` SHOULD NOT introduce new reusable options. When a
configuration needs a new reusable interface, that interface belongs in
`modules`, and `config` should consume it.
## Packages sources

This system is based on several inputs, some of them may be part of
specification agreements, some of them - part of implementation details.

### Nixpkgs stable

The actual numeric stable branch of a `NixOS/nixpkgs` project.

> Which branch is actual and how it should be selected will be defined later in
> this document or other part of project
