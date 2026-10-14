# Proposal: Project-aware NixOS tests

## Motivation

NixOS tests should be able to exercise the same project capabilities that are
available when assembling shvedpkgs systems. Today a test author cannot use the
project's options through the existing test runner without arranging module
imports and their evaluation context separately. This makes project tests harder
to write and risks testing a different module environment from the actual project.

Extend the existing `default:003-testing-infrastructure` specification. This
change addresses project module availability in NixOS tests;
the broader specification name leaves room for later testing capabilities.

## Current behaviour

The flake assembles project configuration, reusable modules, local packages,
external NixOS modules, and overlays. System assembly also supplies project
`lib`, `flake-inputs`, and `pkgsUnstable`. The `extend` interface can add shared
modules and arguments to that assembly.

The package-set function `testers.runNixOSTest` uses the upstream NixOS test
framework. It supplies packages to test nodes but does not automatically supply
the project's module assembly and arguments. A minimal test evaluated through
the current project package set has neither the project `user` configuration
nor `hardware.isVps`.

The repository already uses this runner in `tests/pkgs/specd.nix`, exposed through
`pkgs.specd.tests.vm`. Changes to a shared runner can therefore affect existing
package tests, including tests that do not need project-specific behavior.

## Proposed solution

Provide a NixOS testing entry point that makes project modules usable in test
nodes with the context needed to evaluate them. The reusable module source should stay
aligned with the project rather than become a separately maintained copy.

The preferred direction is to extend the existing `runNixOSTest` in the project
package set, provided existing packages and their tests remain compatible. If
that cannot be achieved, provide a distinct project-aware function based on the
upstream runner. A new function's name and exact interface are not selected by
this proposal.

The user has resolved the module boundary: exclude `config/` and defer `extend`
support until a concrete need appears. Investigate the behavior of
`modules/nixos.nix` and only the dependencies needed to use its capabilities;
do not inherit concrete host modules or validation stubs automatically.

Discovery is needed before stabilizing the system contract because importing
`modules/` already enables behavior. The investigation below establishes the
current default footprint and tests ways to make module availability independent
of automatic activation. These prototypes are evidence for design, not adopted
production implementation.

The user clarified that Home Manager use, including its per-host disablement,
is a design choice for the primary user's environment, not a separate
requirement. The existing project architecture requirements already allow
different user environments on different hosts. The enable option, conditional
alias, per-host selection, and initial rollout below remain design decisions.

## Specs affected

### New specs

None. The indexed specifications pulled on 2026-10-12 supply the owning sections.

### Modified specs

- `default:003-testing-infrastructure`: add project module availability in
  NixOS tests, minimal-node isolation, and compatibility with existing package
  tests. Preserve the existing validation-configuration and private-value-stub
  contracts unchanged.
  - Depends on: `default:001-project-architecture` for primary-user/HM design,
    and `default:002-host-classification` for the existing host-role model.
- `default:001-project-architecture`: extend the primary-user environment
  design with optional Home Manager use and record the two requested ADRs.
  Its existing REQ-001 through REQ-003 cover host-specific environments,
  primary-user scope, and capability selection; its requirements stay unchanged
  through a no-op delta.

`default:002-host-classification` remains context only. This change does not
modify its requirements or design.

### Ownership of the Home Manager design

The owning section is `default:001-project-architecture`, which already
defines the primary user. The standalone HM requirement introduced as REQ-012
during migration is withdrawn. Home Manager is a mechanism for managing that
user's environment; using it and allowing each host to disable it belong in
system design and ADRs. Host assignments and migration steps belong in the
plan and concrete host configuration.

### SDD artifacts affected

Use deltas against the existing requirements and system artifacts of
`default:003-testing-infrastructure` for the already drafted test contracts.
Extend the primary-user design in `default:001-project-architecture` and review
it separately, without adding HM requirements. Technical validation design in
`validate.md` and a change-scoped implementation plan still follow system
design. Acceptance scenarios remain inside their owning requirements. Two ADRs
are explicitly requested in
`default:001-project-architecture` for the Home Manager design:

- Gate project Home Manager profile materialization with
  `services.home-manager.enable`, preserving the evaluated `hm` interface when
  enabled through a conditional alias rather than replacing it with deferred
  module configuration.
- Select Home Manager per host as a host trait, alongside development and other
  host capabilities, instead of enabling it through global `config/` policy.
  Initially keep it enabled for every existing host, with individual hosts able
  to opt out later.

Record the alternatives, evidence, compatibility implications, and rationale in
those ADRs during design. A significant runner/interface choice may warrant an
additional ADR. Do not turn these design decisions into requirements merely
because they are recorded in this proposal.

`inventory.md` is no longer a SpecD schema artifact. The remaining file under
`001-project-architecture` is a temporary non-normative migration aid, not a
delta target or completion dependency for this change. Do not add unrelated
testing features solely because the specification has a general name.

## Impact

Likely affected areas are shared module assembly in `flake.nix` and `lib/`, the
project package-set integration, and test support under `tests/`. Existing
`tests/pkgs/specd.nix` is a concrete compatibility case. Exact implementation
files and sequencing belong in the plan. Home Manager gating also affects
`modules/home/homedir.nix`, host traits and host definitions, and consumers that
read evaluated `config.hm` values.

The main risks are a broader configuration being imposed on previously minimal
tests, incompatibility with the test framework's package-set handling, and
recursive dependencies between project packages and their tests. Compatibility
assessment must cover both project-aware tests and ordinary package tests.

This work includes a compatibility-preserving host-trait migration for Home
Manager, initially enabled on all existing hosts. It does not propose deployment
to any host, changes to development-host tool selection, or a migration of the
historical `hosts/tests/` layout.

## Technical context

Upstream provides `extraBaseModules`, `defaults`, `node.specialArgs`, and the
result's `extendNixOS` interface. These are candidate integration points; their
existence does not establish that injecting the full project assembly is safe.

The upstream runner sets `node.pkgs` to an existing package set and normally
makes `nixpkgs.*` configuration read-only. Project assembly includes modules that
configure overlays. Their interaction requires investigation before selecting
the integration contract. The project's `pkgsOrigin` reference is another
existing mechanism worth inspecting when considering compatibility and recursion.

Shared `extend` additions are deferred by the user. Concrete host modules and
validation-only modules are distinct assembly inputs. The public validation
stubs under `tests/modules/stubs/private-values/` are not real private inputs;
this proposal does not authorize silently injecting them into every test.

The current SpecD code graph indexes specifications but discovers no Nix files.
Its empty symbol/impact results are not evidence of low implementation risk;
Nix code inspection and targeted evaluation supply the discovery evidence.

Cloud evaluation and representative package builds work. Full VM execution has
not been verified, and `/dev/kvm` is absent. The local PRoot failure when building
the SpecD Nix package is an environment limitation under investigation, not an
established repository defect. Verification planning must distinguish evaluation,
package builds, and actual VM test results.

## Discovery: default footprint of modules/

### Method and scope

On commit `d19b600e95d0d9802db6f58c548b046cbf7df375`, compare a minimal
upstream `testers.runNixOSTest` node against the same node importing
`modules/nixos.nix`. Both use the locked x86_64-linux nixpkgs, a node named
`machine`, and `system.stateVersion = "26.05"`. No `config/`, host modules,
`extend`, or private-value stubs are imported.

The module case adds the local package overlay, project library/flake arguments,
Home Manager and nixos-generators support. It supplies `user.name = "tester"`
because the current modules cannot evaluate without it. All project role and
feature flags remain at their defaults. For that case, `node.pkgsReadOnly` is
turned off to allow the modules' overlays.

Evidence consists of evaluated configuration snapshots, successful system
`toplevel.drvPath` evaluation, and recursive derivation graphs. No VM was built
or booted. Derivation counts measure build dependencies, not installed package
counts or runtime bytes.

The reproducible discovery harness and raw snapshots currently live outside the
checkout at `/workspace/.setup/discovery/`. Example:

```sh
/workspace/.setup/bin/nix eval --impure --json --expr \
  '(import /workspace/.setup/discovery/modules.nix { variant = "modules"; }).snapshot'
```

### Behavior added with default feature flags

| Source under modules/ | Effect in the minimal node |
| --- | --- |
| `hardware/development/programmers/stm32` | Installs `stlink` and `st-gpio`, adds a package overlay and ST-LINK/BluePill USB udev rules. |
| `hardware/development/programmers/avr` | Adds USBasp udev rules. |
| `os-specific/linux/keyutils` | Installs `cifs-utils` and `keyutils`, writes `request-key.conf`, adds an activation script linking `/sbin/request-key`. |
| `security/ca.nix` | Adds a corporate CA bundle to system trust and sets `CURL_CA_BUNDLE`; the source archive is fetched from `vpnhelp.kaspersky.com`. This is unconditional even with `kl.enable = false`. |
| `hardware/power` | Changes logind power/lid behavior and adds `wakeOnPowerButtonOnly`, wanted by `multi-user.target`. |
| `home/user.nix` | Requires a username and creates a normal user with wheel and other extra groups. It also adds a duplicate shell package entry through upstream user handling. |
| `home/homedir.nix` | Creates the named Home Manager profile and a boot activation service. |
| `services/gerrit` | Defines a Gerrit service unit and pre-start script even when `services.gerrit.enable = false`. It has no boot target in the disabled case; this is not a running Gerrit server. |

The environment package list grows from 120 to 125 entries: four additional
unique packages (`cifs-utils`, `keyutils`, `stlink`, `st-gpio`) plus a duplicate
Bash entry. Home Manager adds its own activation/profile dependencies outside
that list. The system's recursive derivation graph changes from 3380 to 3453
entries, with 95 new identities and 22 replaced/removed identities. New
build dependencies include Samba-related components for CIFS, the corporate
certificate archive, Home Manager activation/documentation, and STM32 tools.
This does not mean Samba services or 95 extra packages run inside the guest.

Gaming/Steam, 3D printing, KL VPN, CNTLM, and Gerrit itself remain disabled at
default flags. Merely importing nixos-generators support does not put all image
formats into the minimal node's system build dependency graph.

### Evaluation prerequisites and failure cases

- Without a username, evaluation fails on unset `user.name`. It is forced even
  before tests explicitly request user functionality through the dynamic `hm`
  alias and other module configuration.
- Omitting Home Manager fails on undeclared `home-manager` configuration.
- Omitting nixos-generators support fails on undeclared `formatConfigs` from
  `hardware/bootable`. Image-specific policy in that module is another layer
  boundary to examine; it adds no observed default guest payload in this probe.
- Keeping upstream `node.pkgsReadOnly = true` fails on multiple definitions of
  `nixpkgs.overlays` from `hardware/hosts`, STM32, and the local package overlay.
  Simply adding imports to the stock runner is therefore insufficient.

No agenix, Niri, Vim, nix-index database, or disko NixOS module was needed for
these disabled-feature evaluations. That is a result for this probe, not a
claim about every future enabled-feature test.

### Cleanup experiments

1. Excluding the five option-free modules for CA, keyutils, AVR, STM32, and power
   removes their extra packages, certificates, activation files, USB rules, and
   power policy. It retains the custom options declared by the remaining
   modules. The user, Home Manager profile, and Gerrit unit remain.
2. Test-only overrides that disable the named user, clear Home Manager users,
   and disable the Gerrit unit remove observed additional boot services and
   the four unique package additions. They still leave a disabled unit and a
   duplicate shell entry and do not reproduce the baseline system derivation.
   Blanket-forcing all OS users to an empty set is invalid: it removes required
   system users such as `messagebus`. Blanket overrides are not recommended as
   the production design.
3. A first gate-only Home Manager prototype, retaining an unconditional username-dependent
   alias, either requires a username or creates a phantom profile lacking
   `home.stateVersion`. Gating profile settings alone does not solve the alias
   coupling.
4. A refined external prototype gates user/profile materialization, keeps `hm`
   configuration as a deferred module until explicitly applied, and gates the
   Gerrit systemd contribution on service enablement. Together with exclusion
   of the five option-free modules, this evaluates without a username and
   produces exactly the baseline `toplevel.drvPath`:

   ```text
   /nix/store/qvmkm1gdflrp288fl22hxm2l87hf5lwj-nixos-system-machine-test.drv
   ```

   The evaluated packages, services, users, certificates, environment, udev,
   logind, activation entries, and etc entries match the baseline. Project
   `user` declarations, hardware role flags, KL VPN options and nginx proxy
   options remain present. Explicitly enabling the prototype's user/profile
   capability recreates `tester` and its Home Manager profile.

The refined prototype changes `hm` from an evaluated alias to deferred module
configuration. `config/desktop/dm/default.nix` currently reads
`config.hm.home.pointerCursor` and `config.hm.gtk`. That interface is not
preserved by the prototype. Its matching minimal derivation proves the clean
baseline is attainable, not that the prototype preserves deployable hosts or
all package tests. This deferred-module approach is superseded by the following
conditional-alias experiment.

5. A subsequent external prototype introduces `services.home-manager.enable`
   and retains an evaluated `hm` alias using nixpkgs `lib.doRename` with a
   conditional forwarding definition. Both profile configuration and alias
   forwarding are gated. The disabled branch avoids forcing `user.name` and
   does not create a phantom Home Manager user. Together with the other cleanup
   gates from the preceding experiment, it again produces the exact baseline
   `toplevel.drvPath`, while `hm` remains declared and `home-manager.users` is
   empty. With the user and HM explicitly enabled, evaluation produces the
   `tester` profile and supports reads of `config.hm.home.username`,
   `config.hm.home.stateVersion`, and `config.hm.gtk.enable`.

   This preserves the evaluated-alias approach when enabled; it does not make
   `config.hm` profile values readable while HM is disabled. The experiment
   does not prove all host configurations or package tests remain compatible.
   Its harness is `/workspace/.setup/discovery/hm-enable.nix`, with wrappers in
   `/workspace/.setup/discovery/gates-hm-enable.nix`.

### Agreed Home Manager design direction

Use `services.home-manager.enable` to control materialization of the project's
Home Manager profile and activation service. Preserve the existing evaluated
`hm` interface when enabled, using conditional alias forwarding so importing
the module does not create a profile when disabled. This gate concerns the
project-managed profile; its treatment of independently configured
`home-manager.users` belongs in the system contract. It does not automatically
disable OS user creation from `home/user.nix`.

Represent the choice as a host trait, as the project already does for
development and other host capabilities. Do not add global HM enablement to
`config/`. Initially set the trait to true for every existing host to preserve
current behavior; the owner can disable it for individual hosts later. New
minimal test nodes do not inherit concrete host definitions or this initial
host rollout. The concrete trait option path and its mapping to the profile
enable option belong in the system design.

Design must account for consumers of evaluated `config.hm`, including
`config/desktop/dm/default.nix`, on hosts that opt out. An enable flag is not
evidence that such consumers remain valid. Preserve enabled-host behavior and
define how disabled-host consumers are gated before adopting the prototype.

Home Manager use and per-host disablement are design decisions under the
existing primary-user and host-environment requirements of
`default:001-project-architecture`. No separate HM requirement is added.
The enable-option API, alias mechanism, per-host model, initial all-enabled
rollout, and cleanup techniques feed system design, the two requested ADRs,
technical validation design, and planning.

### Recommendation from discovery

Prefer removing activation policy from automatic module availability rather
than maintaining a long test-specific blacklist and forced override set:

- Move the five option-free contributions to the configuration layer, or turn
  them into explicitly enabled capabilities. Keep their existing deployment
  behavior through `config/` so hosts do not silently lose it.
- Treat OS user creation separately from Home Manager profile activation.
  Follow the agreed HM gate and per-host trait direction above, preserving
  the evaluated `hm` interface when enabled and checking disabled-host consumers.
  Do not move HM enablement into global `config/` policy.
- Define Gerrit unit customization only when its service is active; separately
  consider moving role-to-service enablement policy to `config/`.
- Design the test runner's package/overlay handling explicitly, retaining the
  user's preference for the existing function only if compatibility evidence
  supports it.

The HM direction is agreed for design; the remaining cleanup recommendations
are candidates for system review and planning. These implementation techniques
are not requirement-level needs or approved implementation tasks. A test-only
isolation mechanism remains an alternative for other module side effects if
cleaning their boundary would require disproportionate API changes. Compatibility
checks against existing tests and deployable configuration are still needed.

## Open questions

After the user's ownership correction, the HM design belongs in
`default:001-project-architecture` beside the primary-user contract. Its
requirements remain unchanged; the system delta and two requested ADRs still
need separate design and review. The standalone HM requirement is removed.
Do not mark the design changes no-op merely because the existing requirements
cover the underlying needs. The runner's existing draft is migrated without
selecting a new API. Existing validation contracts in
`default:003-testing-infrastructure` remain intact.

The scope questions are resolved by the user: exclude `config/`; ignore
`extend` until a concrete need arises; investigate and remove unrelated
activation caused by importing `modules/`.

Discovery has established the default footprint and an existence proof for a
clean node. The HM direction is now resolved: conditional activation preserving
the evaluated alias, selected per host through a host trait, initially enabled
for all existing hosts. Record both decisions in ADRs. The deferred-module
prototype is not the selected replacement. Remaining interface details and
disabled-host consumer handling belong in system design and technical validation.

The runner preference remains settled: extend the existing function if package
compatibility is preserved; a separate function on its basis is acceptable
otherwise. Actual package-test compatibility, enabled-feature runtime tests,
and runtime byte measurements have not been established by this discovery.
