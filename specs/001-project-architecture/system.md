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

### lib

The `lib` layer provides helper functions for assembling and transforming the
repository's flake outputs and NixOS system sets.

`lib` MAY define reusable Nix functions, output constructors, and extension
mechanisms. It MUST NOT encode host-specific policy that belongs in host or
configuration modules.

### pkgs

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

### modules

The `modules` layer defines reusable NixOS module interfaces and the behavior
owned by those interfaces.

Files under `modules` SHOULD introduce or own options and may implement
configuration derived from those options. They SHOULD NOT be used for broad
repository policy that merely consumes existing options.

### config

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

### Nixpkgs unstable

The `unstable` flake input supplies the additional nixpkgs package set
available to host modules as `pkgsUnstable`. Its revision is pinned by
`flake.lock`. Importing this source uses the host's selected system.

The public package interface exposes the same package set supplied to
the host modules, preserving its source revision and import settings.

## Public Package Interface

The flake exposes each host configuration's packages through
`packages.<system>.<host>`. Here `<system>` identifies the host package
platform, and `<host>` identifies the host configuration.

### Host package namespaces

Each host namespace contains:

- the host's `pkgs` attributes, preserving overlays and host-specific
  package variants, including `pkgs.pkgsUnstable` as the `pkgsUnstable`
  namespace;
- `images`, containing the host's configured image formats.

The repository overlay owns `pkgs.pkgsUnstable`, which references the
additional unstable package set supplied to the host's modules.
`images` is a reserved output namespace name and takes precedence over
an identically named attribute in the host's `pkgs`.

Packages from different sources remain separately addressable. Exposing
unstable packages does not replace the host's ordinary packages with
unstable versions.

A published package resolves to the same derivation as the corresponding
attribute in the selected host's package set. Publication preserves
host-specific overrides rather than importing a fresh default package
set for the host namespace.

### Default host aliases

The default host's public package namespace is also exposed directly
under `packages.<system>` for that host's platform. This includes its
`pkgsUnstable` namespace. The repository defaults to the `generic` host
and `x86_64-linux` system.

Selecting another default host selects that host's package aliases;
other host namespaces remain available on their respective platforms.

### Generic package-export host

`generic` is a synthetic NixOS configuration whose purpose is to provide
the default package set. Evaluating it applies the repository's modules
and overlays; its resulting `pkgs` supplies short installable paths
such as `.#hello` and `.#pkgsUnstable.hello`.

`generic` is not intended to be built, deployed, or booted as a NixOS
system. Its system, VM, and image builds are not supported targets.
Building and running individual packages exported from it is supported.

### Command interface

Installable paths have the following forms. `<package>` is an attribute
path within the selected package set, including nested attributes when
needed. Angle-bracket placeholders are replaced with actual names:

```text
.#<host>.<package>
.#<host>.pkgsUnstable.<package>
.#<package>
.#pkgsUnstable.<package>
```

For example, on `x86_64-linux` these commands build packages from a
named host or the default host:

```sh
nix build .#ShvedGaming.hello
nix build .#ShvedGaming.pkgsUnstable.hello
nix build .#hello
nix build .#pkgsUnstable.hello
```

For runnable packages, the same paths work with `nix run`:

```sh
nix run .#pkgsUnstable.hello
nix run .#ShvedGaming.hello
```

Paths omitting `<host>` select the default host's packages. Short paths
use the platform selected by the Nix command. To select another platform
explicitly, the full output path can be used, for example
`nix build .#packages.x86_64-linux.ShvedGaming.pkgsUnstable.hello`.
Building or executing for another platform still requires suitable
builders or a compatible execution environment, respectively.

These paths resolve package derivations without requiring user-written
expressions or changes to host configurations. Package support and
licensing restrictions still follow the selected package set's settings.

### Output construction

`flake.nix` supplies `pkgsUnstable` through NixOS `specialArgs`.
The module `pkgs/default.nix` receives that argument and publishes it
in the host package set through `nixpkgs.overlays`:

```nix
final: prev: { inherit pkgsUnstable; }
```

This reuses the supplied package set alongside the existing by-name
overlay. The existing `transformNixosPackages` in `lib/system.nix`
exports `host.pkgs`, so `pkgsUnstable` reaches host namespaces and
default-host aliases automatically, including configurations assembled
through `extend`. Publishing it does not select packages for installation.

Traceability: satisfies `REQ-004: Obtain host-available packages with a
simple command`, including access across package sources and selection
of host-specific variants.
