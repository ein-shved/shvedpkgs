# System Specification

## Host Classification Model

Host classification identifies what kind of machine or profile is being
configured. Classification values are evaluated NixOS configuration values
used by configuration modules, package bucket merging, and selected package
expressions.

Concrete host and reusable profile configurations set the positive role flags
for their intended roles. Classification-sensitive behavior is disabled unless
the corresponding flag is true.

## Host Role Flags

The host role flags are:

```nix
hardware.isGraphic
hardware.isLaptop
hardware.isDevelopment
hardware.isNas
hardware.isVps
hardware.isVpsClient
```

Their meanings are:

- `hardware.isGraphic = true`: graphical behavior applies.
- `hardware.isLaptop = true`: laptop host behavior applies.
- `hardware.isDevelopment = true`: development-host behavior applies.
- `hardware.isNas = true`: NAS host behavior applies.
- `hardware.isVps = true`: VPS host behavior applies.
- `hardware.isVpsClient = true`: VPS-client behavior applies.

## Host Package Buckets

Host package buckets are evaluated configuration values under
`environment.*Packages`. They collect role-specific packages before those
packages are merged into `environment.systemPackages`.

The current buckets are:

```nix
environment.graphicPackages
environment.laptopPackages
environment.developmentPackages
environment.nasPackages
environment.vpsPackages
environment.vpsClientPackages
```

`modules/hardware/hosts/default.nix` adds each bucket to
`environment.systemPackages` when the corresponding host classification flag is
enabled.

## Package-Set Host Flags

The package set exposes derived host flags for package expressions that need
host-specific variation:

```nix
pkgs.isGraphic
pkgs.isLaptop
pkgs.isDevelopment
pkgs.isNas
pkgs.isVps
pkgs.isVpsClient
```

The repository package-set overlay introduces these flags into `pkgs` for the
evaluated host package set.

These values correspond directly to evaluated host configuration flags:

- `pkgs.isGraphic` derives from `hardware.isGraphic`.
- `pkgs.isLaptop` derives from `hardware.isLaptop`.
- `pkgs.isDevelopment` derives from `hardware.isDevelopment`.
- `pkgs.isNas` derives from `hardware.isNas`.
- `pkgs.isVps` derives from `hardware.isVps`.
- `pkgs.isVpsClient` derives from `hardware.isVpsClient`.

The package set does not define host roles independently.

## Constraints

- Host classification flags default to disabled unless explicitly set by a
  concrete host or reusable profile.
- Role-sensitive behavior applies only when the corresponding flag is true.
- `pkgs.isDesktop` is not part of the host classification interface.
- New host-derived package flags require a clear system contract before use.
