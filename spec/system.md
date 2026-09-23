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

## Validation Configurations

A validation configuration is a NixOS configuration used to evaluate and plan
builds for repository validation when the corresponding deployable host
configuration requires private or machine-specific values that are not present
in the public checkout.

Validation configurations MUST be separate from deployable host configurations.
They MUST NOT be exposed through `nixosConfigurations`.

The flake exposes validation configurations through:

```nix
nixosValidationConfigurations.<host>
```

Each `nixosValidationConfigurations.<host>` entry is a NixOS configuration
object for the same host as `nixosConfigurations.<host>`, evaluated with the
same base modules and host modules plus repository-owned test-only validation
stub modules.

Validation stub modules live under the repository `tests/` tree, in the
test-only module support area. The initial private-value validation stubs live
under `tests/modules/stubs/private-values/`. They provide non-secret substitute
values only for evaluation and build-planning purposes. They MUST NOT contain
real credentials, private domains, private keys, or machine-local secret
material.

Validation stub modules MAY define ordinary NixOS module options when that is
the normal interface consumed by the system. They SHOULD use existing option
interfaces instead of bypassing module ownership. For example, an age secret
substitute is provided through `age.secrets.<name>.file`, not by assigning a
computed secret `path` directly.

The initial validation stub set covers the private dependencies currently
observed to block active-host toplevel evaluation in the public checkout:

- `age.secrets.cloudflare.file`
- `age.secrets.lastfm-navidrome.file`
- `services.vps.domain`

This list is not a complete inventory of every private, secret, or
machine-specific value that may exist in the repository or in downstream
private extensions. Additional validation substitutes may be added when a
validation target exposes another missing private dependency.

The validation configuration contract guarantees that these commands can be
used for secret-dependent active hosts:

```sh
nix eval --raw .#nixosValidationConfigurations.<Hostname>.config.system.build.toplevel.drvPath
nix build --dry-run --no-link .#nixosValidationConfigurations.<Hostname>.config.system.build.toplevel
```

The corresponding deployable host output remains:

```nix
nixosConfigurations.<host>
```

and it MUST NOT import validation stub modules implicitly.

Traceability:

- Satisfies
  [`REQ-002: Validate Secret-Dependent Hosts Without Private Material`](requirements.md#req-002-validate-secret-dependent-hosts-without-private-material).

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
