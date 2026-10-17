# System Concepts

## Primary User

`modules/home/user.nix` owns the optional primary account for each host.
User-facing guarantees apply to that account; other accounts are configured
independently.

References: [REQ-002](requirements.md#req-002-hosts-select-a-primary-user-for-user-facing-behavior).

### Selection and identity

`user.name` is a login string with no default. The module tests
`options.user.name.isDefined` to select account creation without evaluating
the login. No separate `user.enable` option exists.

A configured login creates `users.users.<login>` as a normal account with a
home directory and the fields below. An undefined login creates neither.
Reading an undefined login or a login-dependent default reports the standard
missing-option-value error. Defaults stay lazy until consumed; no placeholder
or additional dependency assertion replaces that error.

### Account fields

| Option under `user` | Type | Default and use |
| --- | --- | --- |
| `humanName` | string | Login; account description. |
| `home` | string | `/home/<login>`; account home directory. |
| `password` | nullable string | `null`; forwarded to the NixOS account password option with its store-visibility semantics. |
| `extraGroups` | list of strings | Empty; extends the default supplementary groups. |
| `mail` | nullable string | `null`; email metadata for consumers. |
| `domainName` | string | `user.domainNameMaker user.humanName`. |
| `domainNameMaker` | string → string | Lowercases the human name and selects its surname using repository name helpers. |

Default supplementary groups are `wheel`, `tty`, `dialout`, `keys`, `audio`,
`adbusers`, `docker`, `input` and `nixbld`. Creating the account does not enable
additional services.

## Primary User Home Manager Integration

`flake.nix` imports the pinned Home Manager NixOS module, whose input follows
the repository's nixpkgs input. `modules/home/homedir.nix` connects its per-user
interface to the primary account through `home.enable` and the `hm` alias.

References: [REQ-002](requirements.md#req-002-hosts-select-a-primary-user-for-user-facing-behavior),
[REQ-006](requirements.md#req-006-reusable-modules-are-optional-and-disabled-by-default).

### Module boundary and enablement

`home.enable` is a boolean defaulting to `false`. A NixOS assertion requires
`home.enable -> options.user.name.isDefined`. Profile creation and alias reads
use both conditions, so an undefined login cannot fail before that assertion.

| State | Integration contribution |
| --- | --- |
| Active: enabled with a login | `home-manager.users.<login>`, `home-manager.useGlobalPkgs = true`, and `home.stateVersion` defaulting to `system.stateVersion`. HM obtains username and home from the NixOS account. |
| Inactive | No primary HM entry, activation or global-package selection. Independently configured HM users remain available through the upstream interface. |

`home.refresh-profile.enable` defaults to `false`. When enabled in an active
environment, its activation runs before `installPackages` and initializes the
modern Nix profile only when `manifest.json` is absent. With the environment
inactive, this declaration and its profile dependencies remain unapplied.

### Alias contract

`hm` is a statically declared `types.deferredModule` with an empty declaration
default. It accepts attribute definitions, function modules and imports.
Writing it declares home configuration; enablement belongs to the integration.

| Operation | Active environment | Inactive environment |
| --- | --- | --- |
| Write `hm` | Forward raw definitions to `home-manager.users.<login>` for evaluation together with direct HM definitions. | Retain unapplied declarations without evaluating nested values or module bodies, validating HM options, or forwarding to any user. |
| Read `config.hm` | Project the final merged destination, including direct-only definitions. | Report the central inactive-primary-environment error. Independently configured HM entries, including one with the primary login, do not make the alias readable. |

Forwarding preserves definition priorities (`mkDefault`, `mkForce`), list order
and original source files. Type errors identify the declaring module; conflicts
identify both alias and direct sources, subject to normal Nix line-number
limitations. Forwarding MUST NOT use the evaluated `config.hm`; keeping the
read projection separate prevents a cycle through the destination.

Inactive declarations create no dummy or empty-name account, HM entry or
activation. Reads nested in unapplied declarations stay lazy; HM option
validation occurs when those declarations are applied. Destination construction
never forces an undefined login or substitutes an empty one.

`lib.hm` exposes HM library helpers independently of environment enablement.

### Consumers and repository policy

Consumers may write `hm.*` without account-presence or home-enablement
wrappers. Feature and role conditions still select their contributions when
active and may remain inside home declarations. Application and laziness
follow the alias contract above.

System-side reads of `config.hm` or `config.user.*` are dependencies of their
owning functionality and follow [module enablement](#modules). Missing enabled
dependencies report ordinary evaluation or option errors; consumers add no
dependency assertions or guards that silently omit enabled behavior. The
integration's login assertion is the explicit exception.

Mixed modules retain independently selected system packages, certificates and
services when home integration is off. System policy specifically providing a
primary-home workflow may follow `home.enable`.

Existing named hosts select `home.enable = true` in their own configurations
beside hardware role flags; boot and test profiles select it individually.
`hosts/default.nix` keeps shared primary-user defaults separate from that
selection. Its inline synthetic `generic` definition selects home integration
alongside its identity and role flags.

## Project Layers

Shared definitions and host policy are separated into the following layers.
Changes SHOULD preserve these boundaries unless the layer model is explicitly
revised.

References: [REQ-001](requirements.md#req-001-project-supports-multiple-personal-host-configurations),
[REQ-003](requirements.md#req-003-host-environments-are-selected-by-purpose-and-capability).

### lib

Reusable Nix helpers assemble and transform flake outputs and NixOS system
sets. They MUST NOT encode host-specific policy.

### pkgs

Package definitions and package-set extensions are exposed through a by-name
overlay. `pkgsOrigin` supplies the upstream package set before this overlay;
definitions SHOULD use it when extending or wrapping an upstream package.

Packages SHOULD remain ordinary package-set members. They may expose override
arguments but MUST NOT select user or host policy. User-facing configuration
belongs in modules or configuration policy, leaving the package usable by
unrelated consumers.

### modules

Reusable NixOS interfaces own options and their behavior. Files SHOULD own or
introduce options rather than apply broad repository policy. Imports and option
declarations remain independent of evaluated configuration.

Each optional functionality has an enablement condition that defaults off and
allows explicit disabling. It may be a flag or an explicitly supplied value,
such as the primary login; collection modules and fragments share their owning
functionality's condition.

Disabled functionality contributes no effects and does not evaluate its
feature-only dependencies. Enabled functionality retains its dependencies;
missing values fail ordinary evaluation or option validation. Deferred home
declarations follow the [alias contract](#alias-contract).

`config/` and host/profile modules select functionality through these
interfaces without changing reusable defaults. Host roles are defined in
[Host Classification](../002-host-classification/system.md).

Reference: [REQ-006](requirements.md#req-006-reusable-modules-are-optional-and-disabled-by-default).

### config

Repository policy consumes options from NixOS, Home Manager, nixpkgs modules
and this repository's `modules` layer. Files SHOULD NOT introduce reusable
options; a needed interface belongs in `modules` and is consumed here.

## Reusable Module Selection

Defaults and dependencies follow the [module boundary](#modules) and
[HM alias contract](#alias-contract). Repository policy in `config/default.nix`
and `config/services/default.nix` uses overrideable `lib.mkDefault` values.

### Power

Source: [modules/hardware/power/default.nix](../../modules/hardware/power/default.nix).

Purpose: TBD.

Selection: `hardware.power.wakeOnPowerButtonOnly.enable`.
Repository policy: `hardware.isDevelopment`; logind policy follows that role independently.

Reference: [REQ-006](requirements.md#req-006-reusable-modules-are-optional-and-disabled-by-default).

### CIFS/keyutils

Source: [modules/os-specific/linux/keyutils/default.nix](../../modules/os-specific/linux/keyutils/default.nix).

Purpose: TBD.

Selection: `services.cifsKeyutils.enable`.
Repository policy: `true` on every repository host; reusable default: `false`.

Reference: [REQ-006](requirements.md#req-006-reusable-modules-are-optional-and-disabled-by-default).

### AVR

Source: [modules/hardware/development/programmers/avr/default.nix](../../modules/hardware/development/programmers/avr/default.nix).

Purpose: TBD.

Selection: `hardware.programmers.avr.enable`.
Repository policy: `hardware.isDevelopment`.

Reference: [REQ-006](requirements.md#req-006-reusable-modules-are-optional-and-disabled-by-default).

### STM32

Source: [modules/hardware/development/programmers/stm32/default.nix](../../modules/hardware/development/programmers/stm32/default.nix).

Purpose: TBD.

Selection: `hardware.programmers.stm32.enable`.
Repository policy: `hardware.isDevelopment`.

Reference: [REQ-006](requirements.md#req-006-reusable-modules-are-optional-and-disabled-by-default).

### KL certificates and tokens

Source: [modules/security/ca.nix](../../modules/security/ca.nix).

Purpose: TBD.

Selection: `kl.trust.enable`, `kl.nss.certificates.enable`, `kl.nss.tokens.enable`.
Repository policy: Trust: `kl.enable`; NSS: `kl.enable && hardware.isGraphic`.

Reference: [REQ-006](requirements.md#req-006-reusable-modules-are-optional-and-disabled-by-default).

KL system trust is independent of Home Manager activation.

### Image formats

Source: [config/hardware/bootable/default.nix](../../config/hardware/bootable/default.nix).

Purpose: TBD.

Selection: `formatConfigs.<format>`.
Repository policy: Image customization is imported through `config/nixos.nix`.

Reference: [REQ-006](requirements.md#req-006-reusable-modules-are-optional-and-disabled-by-default).

### Gerrit

Source: [modules/services/gerrit/default.nix](../../modules/services/gerrit/default.nix).

Purpose: TBD.

Selection: Final `services.gerrit.enable`.
Repository policy: `hardware.isVps`.

Reference: [REQ-006](requirements.md#req-006-reusable-modules-are-optional-and-disabled-by-default).

### Drive standby

Source: [modules/hardware/hdparm/default.nix](../../modules/hardware/hdparm/default.nix).

Purpose: TBD.

Selection: `hardware.drives.<device>.standby.enable`.
Repository policy: Per-device selection.

Reference: [REQ-006](requirements.md#req-006-reusable-modules-are-optional-and-disabled-by-default).

### Gaming

Source: [modules/applications/misc/gaming/default.nix](../../modules/applications/misc/gaming/default.nix).

Purpose: TBD.

Selection: `environment.gaming.enable`; Steam additions also require final `programs.steam.enable`.
Repository policy: Selected by host policy.

Reference: [REQ-006](requirements.md#req-006-reusable-modules-are-optional-and-disabled-by-default).

## Packages sources

### Nixpkgs stable

The stable source uses a numeric stable branch of `NixOS/nixpkgs`. Its branch
selection policy remains unspecified.

### Nixpkgs unstable

The `unstable` flake input is pinned by `flake.lock` and imported for the host's
selected system. Host modules receive this package set as `pkgsUnstable`; the
public package interface exposes the same set with its revision and import
settings preserved.

Reference: [REQ-004](requirements.md#req-004-obtain-host-available-packages-with-a-simple-command).

## Public Package Interface

The flake exports host package sets through `packages.<system>.<host>`, where
`<system>` is the host package platform.

Reference: [REQ-004](requirements.md#req-004-obtain-host-available-packages-with-a-simple-command).

### Host package namespaces

Each namespace exports the host's `pkgs`, including overlays, host-specific
variants and the `pkgsUnstable` namespace. Every published package resolves to
the corresponding host package derivation. Stable and unstable packages remain
separately addressable.

`images` contains the host's configured image formats and takes precedence over
an identically named package-set attribute.

### Default host aliases

The default host's package namespace is also exposed directly under
`packages.<system>`, including `pkgsUnstable`. Defaults are `generic` and
`x86_64-linux`. Selecting another default host changes these aliases while
retaining other host namespaces on their platforms.

### Generic package-export host

`generic` is a synthetic NixOS configuration that applies repository modules
and overlays to obtain the default package set. Its exported packages support
individual builds and runs. Its system, VM and image builds, deployment and
boot are unsupported targets.

### Command interface

`<package>` may be a nested attribute path within the selected package set.

| Package source | Named host | Default host |
| --- | --- | --- |
| Host `pkgs` | `.#<host>.<package>` | `.#<package>` |
| Host `pkgsUnstable` | `.#<host>.pkgsUnstable.<package>` | `.#pkgsUnstable.<package>` |

Use these installables with `nix build`, or `nix run` for runnable packages:

```sh
nix build .#ShvedGaming.hello
nix run .#pkgsUnstable.hello
```

Short paths use the Nix command's selected platform. An explicit platform uses
the full output path, for example
`.#packages.x86_64-linux.ShvedGaming.pkgsUnstable.hello`. Builds and execution
still require suitable builders and compatible execution environments.
Package support and licensing follow the selected package set's settings.

### Output construction

`flake.nix` supplies `pkgsUnstable` through NixOS `specialArgs`.
`pkgs/default.nix` publishes it alongside the by-name overlay using:

```nix
final: prev: { inherit pkgsUnstable; }
```

`transformNixosPackages` in `lib/system.nix` exports `host.pkgs`, carrying this
namespace into host outputs and default aliases, including systems assembled
through `extend`. Exporting a package does not select it for installation.
