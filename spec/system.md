# System Specification

This document describes the intended behavior of the NixOS configuration
system maintained in this repository.

## System Concepts

### Primary User

For each host configuration, the primary user is the user identified by:

```nix
config.user.name
```

System properties that refer to "the primary user" apply to that account on
the evaluated host configuration.

## Host Classification

Host classification is the part of an evaluated NixOS configuration that
identifies what kind of machine or profile is being configured. Classification
values are system-level inputs for conditional configuration, package
selection, and package build-time behavior.

Concrete host and profile configurations SHOULD set host classification
explicitly. Classification-sensitive behavior MUST NOT depend on an accidental
option default when the host's intended role is known.

### Host Role Flags

Host role flags are configuration values under `hardware.*`.

#### Laptop Host

A laptop host is a portable personal computer with integrated display, battery,
and input devices.

In this system, a laptop host is a NixOS configuration whose evaluated
configuration has:

```nix
hardware.isLaptop = true;
```

#### NAS Host

A NAS host is a home media server and storage machine.

In this system, a NAS host is a NixOS configuration whose evaluated
configuration has:

```nix
hardware.isNas = true;
```

#### VPS Host

A VPS host is a machine running in a cloud or virtual private server
environment.

In this system, a VPS host is a NixOS configuration whose evaluated
configuration has:

```nix
hardware.isVps = true;
```

#### VPS Client Host

A VPS client host uses services provided by a VPS host.

In this system, a VPS client host is a NixOS configuration whose evaluated
configuration has:

```nix
hardware.isVpsClient = true;
```

#### Graphical Host

A graphical host provides a graphical shell for interactive use.

In this system, a graphical host is a NixOS configuration whose evaluated
configuration has:

```nix
hardware.needGraphic = true;
```

Graphical-host behavior applies only when this flag is true.

#### Development Host

A development host needs software development tools.

In this system, a development host is a NixOS configuration whose evaluated
configuration has:

```nix
hardware.development = true;
```

Development-host behavior applies only when this flag is true.

### Host Package Buckets

Host package buckets are configuration values under `environment.*Packages`
that collect packages for host classes before they are merged into the
evaluated system package set.

The system defines these host package buckets:

* `environment.graphicPackages`
* `environment.developmentPackages`
* `environment.nasPackages`
* `environment.vpsPackages`

Each host package bucket applies to the host class named by the bucket. For
example, `environment.developmentPackages` applies to
[development hosts](#development-host), and `environment.vpsPackages` applies
to [VPS hosts](#vps-host).

### Package Set Host Flags

The package set exposes host classification flags for package expressions that
need to vary by evaluated host. These flags are derived from the evaluated host
configuration; they MUST NOT define host classification independently.

The package set exposes these host flags:

* `pkgs.isLaptop`
* `pkgs.isNas`
* `pkgs.isVps`
* `pkgs.isVpsClient`

These flags correspond directly to `hardware.isLaptop`, `hardware.isNas`,
`hardware.isVps`, and `hardware.isVpsClient`.

### Packages sources

This system is based on several inputs, some of them may be part of
specification agreements, some of them - part of implementation details.

#### Nixpkgs stable

The actual numeric stable branch of a `NixOS/nixpkgs` project.

> Which branch is actual and how it should be selected will be defined later in
> this document or other part of project

## Development Host Tooling

For every [development host](#development-host), the
[primary user](#primary-user) has next packages form [nixpkgs
stable](#nixpkgs-stable) available in lookup path:

* `codex`

If host is not [development host](#development-host) or user is not [primary user](#primary-user),
this packages MAY NOT be available in lookup path.

Traceability:

- Satisfies
  [`REQ-001: Development Hosts Provide Codex`](requirements.md#req-001-development-hosts-provide-codex).
