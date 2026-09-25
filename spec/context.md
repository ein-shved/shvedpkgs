# Project Context

This repository contains personal Nix/NixOS configuration for several machines:
workstations, laptops, a NAS/media server, a VPS for Gerrit, bootable profiles,
and VM-oriented test configurations.

The existing `Readme.md` is intentionally not treated as a source of truth.
This document captures the current context discovered from the flake and Nix
entry points, and should be updated as the repository moves toward an SDD
process.

## Current Entry Points

- `flake.nix` is the main entry point.
- `flake.nix` imports local helper library from `./lib`.
- Global NixOS modules are assembled in `flake.nix` from:
  - `./config/nixos.nix`
  - `./modules/nixos.nix`
  - `./pkgs`
  - external flake modules: `agenix`, `vim`, `home-manager`, `niri-flake`,
    `nix-index-database`, `nixos-generators`, `disko`
- Hosts are imported from `hosts/default.nix`.
- `lib.mkExtendableSystems` builds `nixosConfigurations` and exposes an
  `extend` function for downstream extension.
- `lib.mkExtendableSystems` also derives `nixosValidationConfigurations` from
  the same host set plus validation-only modules for repository validation.

The flake is based on:

- `nixpkgs`: `github:NixOS/nixpkgs/nixos-26.05`
- `home-manager`: `release-26.05`
- `unstable`: `nixos-unstable`
- personal inputs from GitHub account `ein-shved`:
  - `vim`: `github:ein-shved/vim`
    - Personal IDE configuration based on nixvim.
    - Imported as `vim.nixosModules.default`.
  - `niri`: `github:ein-shved/niri/view_offset`
    - Personal fork/branch of Niri.
    - Imported as an overlay through `niri.overlays.default`.
- other external inputs for `agenix`, `niri-flake`, `nix-index-database`,
  `nixos-generators`, and `disko`

Some personal flake inputs have local working copies on this host and may later
be brought into the same SDD process. They should remain separate repositories;
this repository should document integration points and expectations, not absorb
their source trees.

## NixOS Hosts

`hosts/default.nix` currently exposes these configurations:

- Real or primary hosts:
  - `ShvedGaming`
  - `ShvedMedia`
  - `gerrit`
- Generic profile:
  - `generic`
- Boot profiles from `hosts/boots/default.nix`:
  - `bootWork`
  - `bootGaming`
  - `bootServer`
- VM/test profiles from `hosts/tests/default.nix`:
  - `testA`
  - `testB`
  - `testNas`
  - `testVps`

The flake extends nixpkgs with personal packages and configurations. It is
expected to behave more like an extended nixpkgs than a small application
flake; broad output enumeration may be less useful than targeted evaluation.

### Inactive Hosts

These host configurations are currently considered inactive and should not be
used as examples for new work without revalidation. They are still generated
through `hosts/default.nix`.

- `Shvedov`
- `Shvedov-NB`
- `ShvedLaptop`

## Architecture Layers

The repository currently has several overlapping historical layers.

### `hosts/`

Contains concrete host configuration and hardware configuration. Most real
hosts import their local `hardware-configuration.nix`; graphical machines also
import a local `desktop/` module.

Current host roles:

- `ShvedGaming`
  - desktop/gaming machine
  - VPS client
  - gaming and 3D printing enabled
  - NVIDIA enabled
  - `system.stateVersion = "24.11"`
- `ShvedMedia`
  - NAS/media server
  - VPS client
  - media store at `/media`
  - drive standby via custom `hardware.drives`
  - Transmission night seeding throttling
  - distributed builds via `ShvedGaming`
  - `system.stateVersion = "24.11"`
- `gerrit`
  - VPS
  - user `gerrit-admin`
  - Gerrit service enabled via `hardware.isVps`
  - password SSH disabled
  - passwordless sudo for wheel
  - `system.stateVersion = "25.11"`

### `modules/`

This is the reusable module layer. Its purpose is to add custom NixOS options
and domain-specific behavior behind those options.

Layer rule: files under `modules/` should define options. A module file that
only applies configuration and does not introduce options is a candidate for
moving to `config/`, unless there is a deliberate reason to keep it near its
option-owning module family.

Important modules:

- `modules/home/user.nix`
  - Defines custom `user.*` options.
  - Creates the normal user account.
  - Default user values are usually injected from `hosts/default.nix`.
- `modules/home/homedir.nix`
  - Configures Home Manager with global pkgs.
  - Adds `hm` alias for `home-manager.users.${config.user.name}`.
  - Defines `home.refresh-profile.enable`.
- `modules/hardware/hosts/default.nix`
  - Defines role flags:
    - `hardware.isLaptop`
    - `hardware.isNas`
    - `hardware.isVps`
    - `hardware.isVpsClient`
    - `hardware.needGraphic`
    - `hardware.development`
  - Defines package buckets:
    - `environment.graphicPackages`
    - `environment.developmentPackages`
    - `environment.nasPackages`
    - `environment.vpsPackages`
  - Host classification flags default to `false`; hosts and reusable profiles
    set only the positive role flags they need.
  - Merges package buckets into `environment.systemPackages` according to the
    matching role flag:
    - `graphicPackages` when `hardware.needGraphic` is true
    - `developmentPackages` when `hardware.development` is true
    - `nasPackages` when `hardware.isNas` is true
    - `vpsPackages` when `hardware.isVps` is true
  - Adds overlay flags into `pkgs`: `isLaptop`, `isNas`, `isVps`, and
    `isVpsClient`.
- `modules/hardware/monitors/default.nix`
  - Defines monitor metadata used by desktop modules.
- `modules/hardware/hdparm/default.nix`
  - Defines `hardware.drives` and emits hdparm-related services for drive
    standby.
- `modules/employment/kl/*`
  - Defines KL employment/domain/remote VPN options.
  - `kl.remote.enable` implies `kl.enable` and `services.klvpn.enable`.
  - `kl.domain.enable` implies `kl.enable`.
- `modules/services/networking/klvpn/default.nix`
  - Installs KL VPN tooling and smart-card support.
  - Enables pcscd and PKCS#11 modules.
  - Grants polkit access to the configured user.
- `modules/services/networking/cntlm-gss/default.nix`
  - Defines and runs a local `cntlm-gss` proxy.
- `modules/security/ca.nix`
  - Installs KL CA bundle system-wide.
  - For graphical systems, populates user NSS DB and PKCS#11 modules.
- `modules/services/gerrit/default.nix`
  - Enables Gerrit on `hardware.isVps`.
  - Adds Gerrit OAuth/admin plugins.
  - Allows extra config files via systemd credentials.
- `modules/services/nginx/proxies/default.nix`
  - Defines `services.nginx.proxies`, a small abstraction over nginx virtual
    hosts and proxied locations.
- `modules/services/navidrome/default.nix`
  - Extends Navidrome with smart playlist file generation.

### `config/`

This is the opinionated configuration layer that turns modules into actual
behavior across all systems.

Layer rule: files under `config/` should not add new options. New option
definitions belong under `modules/`; `config/` should consume existing options
and apply policy.

`config/nixos.nix` imports most of `config/`. Some imported modules may still
be historical, but as of this context pass they are included globally unless
commented out there.

Important active areas:

- `config/default.nix`
  - Enables OpenSSH, NetworkManager, tmpfs `/tmp`, Plymouth for graphical
    hosts, NTFS support for graphical hosts.
  - Enables NixOS documentation and nix-daemon tmp dir setup for development
    hosts.
  - Adds aarch64 binfmt emulation for development hosts.
- `config/nix/default.nix`
  - Enables flakes and nix-command.
  - Enables `nix.sshServe`.
  - Generates a binary cache key at `/etc/nix/private-key` and
    `/etc/nix/public-key` if absent.
  - Enables distributed builds globally; concrete builders are configured per
    host where needed.
- `config/applications/default.nix`
  - Adds baseline system packages.
  - Adds graphical package bucket.
  - Adds development package bucket, including `codex` from stable nixpkgs.
- `config/desktop/*`
  - Defines graphical desktop behavior around Niri, LightDM, Waybar, Kitty,
    AnyRun, XDG, wallpapers, swaylock/wpaperd/awww, and theme settings.
  - Most behavior is guarded by `hardware.needGraphic`.
- `config/media/*`
  - PipeWire/PulseAudio/MPV/camera related configuration.
- `config/services/navidrome/default.nix`
  - Enables Navidrome on NAS hosts.
  - Uses `services.mediaStore`.
  - Configures ACME/nginx for `navidrome.shved.org`.
- `config/services/nas/ftp/default.nix`
  - Enables vsftpd on NAS hosts.
- `config/services/nas/upnp/default.nix`
  - Enables minidlna on NAS hosts.
- `config/applications/editors/nixvim/default.nix`
  - Current active editor path, using external `vim` flake packages.
  - Older self-written Neovim and Vim configs are commented out in
    `config/nixos.nix`.

### `pkgs/`

`pkgs/default.nix` installs a by-name overlay using nixpkgs'
`pkgs/top-level/by-name-overlay.nix`.

Local packages currently present under `pkgs/by-name` include:

- Niri helpers: `niri-single-output`, `niri-launch-terminal`,
  `niri-integration`, `niri-lightdm-wa`
- System helpers: `nixos-script`, `dhcps`, `dowork`, `gitaliases`,
  `ripgrep`, `mkblur`
- KL/work tooling: `klcacerts`, `klvpn`, `klvpn_cert_chooser`,
  `cntlm-gss`, `pcsc-safenet-legacy`, `rtpkcs11ecp`
- Gerrit tooling/plugins: `gerrit-commit-msg-hook`,
  `gerrit-admin-console-plugin`, `gerrit-oauth-plugin`
- Other packages: `all-themes`, `aff4`, `esp-config`

### `lib/`

Custom library extensions:

- `lib/default.nix` extends nixpkgs lib with local helpers.
- `lib/modules.nix`
  - `hm`
  - `mkHmExtra`
  - overlay helpers
  - name parsing helpers
  - `mkBynameOverlayModule`
- `lib/system.nix`
  - `mkExtendableSystems`
  - `transformNixosPackages`

`mkExtendableSystems` is central: it merges host definitions, global modules,
special args and prefixes, then produces `nixosConfigurations`,
`nixosValidationConfigurations`, `packages`, and recursive `extend`.

Target machines may assemble the final configuration from this repository plus
private extensions through `extend`. Those private extensions can include
secrets and machine-specific assembly code that is intentionally not available
in this repository.

Open questions, suspected legacy areas, and cleanup candidates are tracked in
`spec/todo.md`.

## Secrets And External State

The repository uses secret-dependent configuration:

- `agenix` module is imported globally.
- Some service configs reference `config.age.secrets.*`, including:
  - `lastfm-navidrome`
  - `cloudflare`
- KL-related modules depend on local/company artifacts and smart-card tooling.
- Some hosts depend on reachable build machines over SSH.

Specs and tests should separate pure evaluation/build behavior from behavior
that requires secrets, hardware tokens, network access, or private hosts.

## Validation Workflow

The repository exposes validation-only NixOS configurations through:

```nix
nixosValidationConfigurations.<host>
```

These outputs are derived from the same hosts and base modules as
`nixosConfigurations`, with validation-only modules appended through
`lib.mkExtendableSystems`'s `validationModules` input. They are intended for
repository validation and build planning in a public checkout, not for
deployment.

Use validation configurations when an active deployable host requires private
values that are intentionally absent from the public checkout. Current active
examples are:

- `ShvedMedia`, whose deployable output requires `age.secrets.cloudflare`.
- `gerrit`, whose deployable output requires `services.vps.domain`.

The default validation modules live under
`tests/modules/stubs/private-values/`. They currently provide:

- non-secret placeholder age files for `cloudflare` and `lastfm-navidrome`;
- `services.vps.domain = "validation.invalid"` through `lib.mkDefault`.

Normal deployable outputs should still fail in the public checkout when they
need private values. Validation configurations only replace those missing
private inputs for evaluation and dry-run build planning.

## Test Support Direction

The repository is expected to move toward a shared top-level `tests/`
structure for test and validation support:

- `tests/hosts/` for host-oriented test profiles;
- `tests/modules/` for test-only NixOS modules and module fixtures;
- `tests/pkgs/` for package-oriented test support.

The existing `hosts/tests/` directory currently contains VM/test host profiles.
It should be migrated to `tests/hosts/` as a separate cleanup after the test
infrastructure layout is specified. New validation stubs should use the future
test-support shape, for example `tests/modules/stubs/private-values/`, rather
than adding another root-level test namespace.

Current validation stubs already use this layout under
`tests/modules/stubs/private-values/`.

## SDD Notes For Future Work

- Treat this file as context, not as a requirements spec.
- New behavior should be introduced through small specs under `spec/`.
- Specs should name:
  - affected host classes or concrete hosts
  - intended module layer: `modules/`, `config/`, `hosts/`, or `pkgs/`
  - validation command
  - known dependencies on secrets, hardware, or external services
- Before deleting or moving historical code, first add a spec describing the
  intended architecture boundary and a validation plan for the active hosts.
