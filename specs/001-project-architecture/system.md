# System Concepts

## Primary User

The optional primary account is owned by `modules/home/user.nix`.
Properties referring to "the primary user" apply to this account on
the evaluated host. Other accounts remain independently configurable.

### Selection and identity

`user.name` is a login string with no default. Leaving the option
undefined means that no primary account is selected. Reading its value
without a definition produces the standard missing-option-value error.

Account creation is conditional on `options.user.name.isDefined`,
without reading `config.user.name` to test presence. No separate
`user.enable` option is exposed. Imports remain independent of the
evaluated login and enablement.

When enabled, the module defines `users.users.${config.user.name}` as
a normal account, creates its home directory and applies its configured
identity, password and supplementary groups. When disabled, the module
contributes no account or home-directory creation.

### Account fields

- `user.humanName`: string; defaults to the selected login.
  It supplies the account description when the account is enabled.
- `user.home`: string; defaults to `/home/<login>` and supplies
  the account's home directory.
- `user.password`: nullable string; defaults to `null` and is forwarded
  to the account password option. A supplied clear-text password has
  the underlying NixOS option's store-visibility semantics.
- `user.extraGroups`: list of strings, defaulting to an empty list;
  extends the account's default supplementary groups.
- `user.mail`: nullable string, defaulting to `null`; personal metadata
  for consumers that use an email address.
- `user.domainName`: string; defaults to
  `user.domainNameMaker user.humanName`.
- `user.domainNameMaker`: function from a string to a string. Its
  default lowercases the human name and selects its surname using
  the repository's name helpers.

Derived defaults remain lazy. Disabled functionality MUST NOT force
them. Reading a login-dependent default without a configured login
produces the standard missing-option-value error rather than a null
result or a placeholder. No separate dependency assertions are added.

Default supplementary groups are `wheel`, `tty`, `dialout`, `keys`,
`audio`, `adbusers`, `docker`, `input` and `nixbld`. Account optionality
does not change these defaults or introduce new service enablement.

Traceability: satisfies `REQ-002`, including selection, configurable
account details, established default access and the absent-login case.

## Primary User Home Manager Integration

### Module boundary and enablement

`flake.nix` imports the pinned Home Manager NixOS module as part of
the common module collection. The Home Manager input follows the
repository's nixpkgs input. Import makes its interfaces available;
it does not by itself select a managed primary-user environment.

`modules/home/homedir.nix` owns `home.enable`, a boolean defaulting to
`false`. Enabling it requires `options.user.name.isDefined`. A NixOS
assertion enforces `home.enable -> options.user.name.isDefined`.
Enabling the environment without a configured primary login is invalid.

Profile creation and evaluated alias reads require both `home.enable`
and a defined login. This guard avoids forcing an undefined login
before the assertion can report the invalid configuration. It does
not silently accept an enabled environment without its account.

When active, the integration creates the primary entry under
`home-manager.users.<login>`, selects `home-manager.useGlobalPkgs`
and defaults its `home.stateVersion` to `system.stateVersion`.
Home Manager obtains the account username and home directory from
the corresponding NixOS account through its NixOS integration.

When inactive, this integration contributes no primary Home Manager
entry, activation or global-package selection. Other explicitly
configured Home Manager users remain governed by the upstream interface.

`home.refresh-profile.enable` remains a separate boolean defaulting to
`false`. It requests primary-user activation before `installPackages`
that initializes the modern Nix profile when `manifest.json` is absent.
This activation is a home declaration. When the primary environment
is inactive, it is not applied and its profile dependencies are not
evaluated, even if the refresh flag is true.

### Alias contract

Writes through `hm` declare the desired primary home environment.
They do not themselves enable that environment. The integration owns
the single condition deciding whether to apply these declarations.

The `hm` option is declared statically with `types.deferredModule`
and an empty declaration default. Its input is kept as module
definitions, separate from its evaluated read value. Attribute-based
declarations such as `hm.programs.git.enable = true` remain valid.
Function modules and module imports use the same deferred input path.

When active, definitions through `hm` and direct definitions under
`home-manager.users.<primary-login>` participate in the same HM module
evaluation. The destination receives raw alias definitions through
module-system definition forwarding, preserving priorities such as
`mkDefault` and `mkForce`, and list ordering.
It MUST NOT receive the already evaluated `config.hm` value.

Forwarding retains each definition's original source file. HM option
type errors identify the declaring module; conflicts identify both
alias and direct definition sources. Normal Nix diagnostic limitations
for exact line numbers continue to apply.

Reads through `config.hm` expose the final merged destination,
including direct definitions. The option's read projection is separate
from the raw definitions used for forwarding, preventing a cycle
between reading the destination and constructing it.

When inactive, writes are accepted as unapplied declarations. The
integration does not instantiate or validate them as an HM user,
forward them to any user, or force their nested values or module
bodies. They create no dummy account, primary HM entry or activation.
This remains true with no login, with an account but HM disabled,
and when unrelated HM users exist. HM option validation takes place
when declarations are applied to an active primary environment.

An evaluated read of `config.hm` while inactive fails with a central
evaluation error identifying that the primary HM environment is not
active. It does not expose raw declarations, an empty configuration,
an unrelated user or an independently defined primary-name HM entry.
Reads contained only in unused declaration values remain unevaluated.

The integration MUST NOT make its imports or option names conditional
on `config`, force an undefined login to construct a destination, or
use an empty login as a fallback. Conditional application and the
evaluated read projection belong in `modules/home/homedir.nix`.

`lib.hm` exposes Home Manager library helpers. It is independent of
the configuration alias and remains available when `home.enable` is
false. Its presence does not establish that `config.hm` can be read.

### Consumers and repository policy

A consumer may write `hm.*` without checking primary-account presence
or `home.enable`. Existing feature and role conditions still select
its contributions when the home environment is active; these
conditions may remain on nested HM options. No condition around the
complete alias assignment is required solely for alias availability.

Settings and reads used only inside an unapplied home declaration do
not require the primary account or an evaluated HM environment. A
disabled home integration retaining these declarations satisfies
REQ-006: retaining configuration input does not enable functionality.

System-side reads of `config.hm` or `config.user.*` remain actual
dependencies of the selected system behavior. Disabled behavior does
not evaluate those reads. Enabled behavior requiring missing values
fails through ordinary evaluation or option errors, without a guard
that silently drops it or a consumer-specific dependency assertion.
The integration-level login assertion remains the explicit exception.

Mixed modules preserve system packages, certificates and services that
can operate independently of the managed environment. System policy
specifically providing a primary-home workflow may follow the home
integration's enablement; this does not require wrapping every HM
declaration in that same condition.

Host and profile policy explicitly enables `home.enable` for existing
hosts to select their intended environment. Each named host selects it
beside its hardware role flags in its own configuration; the shared
primary-user defaults in `hosts/default.nix` do not select it. Boot and
test profiles select it in their individual definitions. The synthetic
generic host keeps its selection in its existing inline definition in
`hosts/default.nix`, alongside its identity and hardware role flags.

Other explicitly configured accounts and HM users remain independent.
Library helper `lib.hm` remains usable regardless of primary integration
enablement.

Traceability: realizes primary-user environment selection under
`REQ-002` and the optional-module and dependency contracts of `REQ-006`.

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

The `modules` layer defines reusable NixOS module interfaces and the
behavior owned by those interfaces.

Files under `modules` SHOULD introduce or own options. They SHOULD NOT
implement broad repository policy that merely consumes existing options.

Importing this layer makes interfaces available without enabling their
optional functionality. Each module's behavior has an enablement
condition that is false by default and can be disabled. Selection may
use a boolean flag or an explicitly supplied value, such as the primary
login; a separate boolean per source file is not required. Collection
modules and fragments use the enablement of their owning functionality.

Disabled behavior contributes no feature configuration and does not
evaluate dependencies needed only by that behavior. Enabled behavior
retains its dependency obligations; missing dependencies are reported
by ordinary configuration evaluation and option validation.

Deferred home declarations are inputs to the home integration. Keeping
them while that integration is disabled does not apply home behavior
or require their unused dependencies. Their application and evaluated
reads follow the Primary User Home Manager Integration contract.

Host roles remain governed by `default:002-host-classification`.
`config/` and host/profile modules select reusable functionality through
its public interfaces. Their selections do not change module defaults.

Traceability: satisfies `REQ-006`; host-purpose selection continues
to be governed by `REQ-003` and the host-classification specification.

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
