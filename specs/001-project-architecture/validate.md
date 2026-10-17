# Validation: Project Architecture

## Artifact Status

Technical validation of the remaining project architecture is still
being developed. These sections cover public package access under
`REQ-004`, primary-user behavior under `REQ-002`, and reusable-module
optionality under `REQ-006` for user/HM and their consumers. Other
module families need separate validation tasks. These sections do not
establish conformance of the entire system specification.

## Validation: Public Package Access

Covers `REQ-004` and the Public Package Interface, Nixpkgs unstable,
and generic package-export host contracts. Checks use targeted package
evaluation, builds, and execution on `x86_64-linux`. They do not build
or boot `generic` as a system or enumerate all nixpkgs attributes.

### Check: Default package paths work

Covers "Obtain a package by name" and "Packages from different sources
are accessible". Run:

```sh
nix build --no-link --no-write-lock-file .#hello .#pkgsUnstable.hello
nix run --no-write-lock-file .#hello
nix run --no-write-lock-file .#pkgsUnstable.hello
```

Both builds succeed and both runs print the hello greeting. No host
configuration or user-written expression is needed for these commands.

### Check: Exported unstable packages match the supplied source

Covers the unstable source and overlay contracts. Inspect
`pkgs/default.nix`: its overlay captures the `pkgsUnstable` module
argument through `inherit pkgsUnstable`. Inspect `flake.nix` to confirm
that this argument imports the locked unstable input for the selected
system. Confirm `flake.lock` is unchanged by the implementation.

Evaluate `hello.drvPath` through these three paths using
`nix eval --raw --no-write-lock-file`:

```text
.#pkgsUnstable.hello.drvPath
.#generic.pkgsUnstable.hello.drvPath
.#nixosConfigurations.generic.pkgs.pkgsUnstable.hello.drvPath
```

All three return the same derivation path. Also compare
`.#hello.drvPath` with `.#generic.hello.drvPath` to verify the existing
default alias. Stable and unstable packages need not have different
versions or derivation paths from one another.

### Check: Named host paths preserve its packages

Covers "Select a host-specific package variant". Compare the derivation
paths at `.#ShvedGaming.hello.drvPath` and
`.#nixosConfigurations.ShvedGaming.pkgs.hello.drvPath`; repeat for
`pkgsUnstable.hello`. Each public path must equal its host package path.

To distinguish correct host selection from all paths accidentally
returning the same package, use a temporary evaluation fixture through
`extend`: add a host with an overlay that gives `hello` a distinct
derivation, and select it as `defaultHost`. Assert its named and default
paths equal that host's `pkgs.hello.drvPath`, differ from the base
generic package, and that the base generic namespace remains available.
Also assert the new host's named and default unstable paths match its
`pkgs.pkgsUnstable.hello.drvPath`. This fixture only evaluates packages;
it does not build a system or modify a deployable host configuration.

## Validation: Primary User and Optional Modules

### Validation support and evidence

Use repository-owned evaluation fixtures under `tests/modules/`, with
a test runner at `tests/modules/primary-user-hm.sh`. The runner executes
targeted `nix eval` calls using the repository's locked inputs and
actual implementation modules.

```sh
bash tests/modules/primary-user-hm.sh
```

Exercise the real Home Manager NixOS module and its per-user type.
Do not substitute a minimal fake submodule for alias integration tests.
Use isolated module fixtures for interface checks and full repository
configurations for consumer and host regression checks.

The runner must return nonzero for an unmet expectation and identify
each failing case. For expected errors, run a separate evaluation
process, verify its failure status and check a stable diagnostic
fragment identifying the relevant option or assertion. Do not accept
any arbitrary failure as proof of the intended rejection, or rely on
`builtins.tryEval` to catch every evaluator error.

Force the result relevant to each check: account definitions, HM
users, generated activation, or the system toplevel derivation.
Evaluating an unrelated boolean does not establish that a lazy
dependency or applied HM definition has been checked. Avoid
recursively forcing an entire NixOS configuration attribute set.

Record commands, exit status and expected-versus-observed values for
each check. Keep test-only private-value substitutes in the support
area specified by `default:003-testing-infrastructure`.

### Check: Account selection and lazy defaults

Covers `REQ-002` scenarios for configured login and absent login,
and the Primary User selection and account-field contracts.

Evaluate the user module without a `user.name` definition. Confirm
`options.user.name.isDefined` is false, no primary account is emitted,
and an independently declared secondary account remains intact.
Separately force `config.user.name`, then each login-dependent default
without an override: each fails with the standard missing-value error
identifying `user.name`, not recursion or an invalid interpolation.

Repeat with a configured login. Confirm normal-account status,
`createHome`, matching account name, the default home and display name,
and the documented domain-name derivation. Check that `user.enable`
is not a declared option. An unused undefined login must not fail
evaluation of independent system configuration.

### Check: Account overrides and established access

Covers `REQ-002` scenarios for account details and default privileges.

Evaluate two hosts with different primary logins and personal details,
plus a secondary account with distinct settings. Override the primary
display name, home, test-only password, email, domain name and extra
groups. Inspect the actual account and selected metadata consumers;
confirm each host uses its own values and leaves the secondary account
unchanged. Test the domain-name factory separately from an explicit
domain-name override.

Compare default supplementary group membership against `wheel`, `tty`,
`dialout`, `keys`, `audio`, `adbusers`, `docker`, `input` and `nixbld`.
An additional test group must extend this set. Check membership rather
than list ordering. Confirm password omission remains `null`.

### Check: Home enablement and account dependency

Covers `REQ-006` default-off and dependency scenarios, and the Home
Manager module boundary and enablement contract.

Evaluate these cases with unrelated user-dependent features disabled:

- No login and default home settings: no primary account or HM entry.
- Login with `home.enable` unspecified: account exists, no HM entry.
- Login with `home.enable = false`: same account-only result.
- Login with `home.enable = true`: one primary HM entry, matching
  username and home directory, global packages selected, and home
  state version defaulting to the system state version.
- No login with `home.enable = true`: toplevel evaluation reports the
  integration's missing-login assertion. It must not fail first while
  constructing the account or alias destination from an undefined login.

Override the primary HM state version and confirm it wins over the
default. With the primary integration off, independently define another
valid NixOS account and its HM entry. Confirm that entry works and the
primary integration does not enable global packages on its behalf.

### Check: Alias declarations, merge and evaluated reads

Covers the Alias contract and `REQ-006` dependency behavior.

In an enabled primary environment, contribute distinct valid HM
settings through `hm` and directly through the matching
`home-manager.users.<login>`. Confirm both occur in the final profile
and reads through `config.hm` equal the destination values.

Cover attribute-based input, a function module using actual HM
arguments, and an imported module. Confirm the option is declared as
a deferred module and input is forwarded without reading `config.hm`.
Include a direct-only HM definition so alias reads work without an
explicit alias assignment. Force actual HM options and activation.

Exercise `mkDefault` and a higher-priority direct definition, then
reverse the two paths. Check conflicting ordinary scalar definitions
fail normally. For a list-valued HM option, verify `mkBefore` and
`mkAfter` ordering across both paths. Force an activation derivation
to detect recursion hidden by inspecting a single scalar value.

Use distinct source modules for an invalid alias option value and
conflicting alias/direct definitions. The type error must name the
alias declaration file; the conflict must name both original files.
The runner checks diagnostic source paths using
`tests/modules/fixtures/primary-user-hm/alias-errors.nix` and
`tests/modules/fixtures/primary-user-hm/direct-conflict.nix`.
Reporting the forwarding module as the source does not pass.

With HM inactive, alias assignments must succeed while evaluating HM
users and the system toplevel. Check both no-login and account-only
cases, including explicit `home.enable = false`. Confirm no primary
or empty-name HM entry, account or activation is created by the writes.

Prove laziness using nested declaration values that throw, read an
undefined `user.name`, or read `config.hm`. Separately provide a
function module whose body throws. Unused values and module bodies
must remain unevaluated. Activating the same declarations must expose
the expected value or diagnostic, proving they are not always dropped.

Put an invalid HM option value inside a deferred declaration. It
remains unused when inactive and fails the normal HM option check
when applied. Test nested `mkIf` conditions, including a false branch
containing a throwing value, with the primary environment active.

Separately force `config.hm` when inactive: it must report the central
inactive-primary-environment diagnostic. Repeat without a login,
with a login, with an unrelated HM user and with an independently
configured HM entry bearing the primary login. Confirm declarations
do not leak into those independent entries, and neither entry makes
the primary alias readable. `lib.hm` helpers remain usable.

### Check: Consumer declarations and actual system dependencies

Covers `REQ-006` disabled-dependency, explicit-disable, missing-enabled-
dependency and independent-functionality scenarios.

Inventory assignments through `hm` and reads through `config.hm`, plus
primary-account consumers, in `modules/` and `config/`. For each
consumer, distinguish unused declaration values from evaluated system
reads and identify its owning feature or role. No complete-assignment
condition is required solely because the primary HM integration may
be off. Existing feature conditions may remain inside declarations.

Evaluate each independently selectable consumer disabled with its
primary-account or HM dependency absent. Then select its declaration
with HM off and confirm no home behavior is applied or evaluated.
Turn HM on and confirm its intended contribution appears. Browser NSS
activation and certificate declarations with HM off must not fail
merely because the browser or graphical role is selected.

For actual system reads, test disabled behavior with missing values,
enabled behavior with missing values and enabled behavior with values
supplied. Missing required reads must fail with the intended ordinary
error. Include LightDM's cursor/theme read, KL services, media storage
and 3D-printing's system-side Gitwatch user/home settings. For printing,
an account-only configuration supports the system part while keeping
the Prusa activation unapplied; no-login fails the actual account read.

Include browser NSS activation, certificate setup, pass, 3D-printing
activation, and graphical consumers that read HM values. Include
dormant Hyprland and wpaperd definitions as evaluation fixtures without
claiming supported deployment. Reads used only inside unused HM
declarations, such as Niri settings, must not need extra conditions.
In mixed modules, check independently selected packages, certificates
or services remain present when the HM-specific behavior is disabled.
Source inspection also confirms no consumer-specific dependency
assertions were added.

Full repository no-login and account-only fixtures must still evaluate
their toplevel with actual system dependencies disabled. Compare the
final consumer diff to the initial implementation and explain each
retained change; remove availability wrappers with no remaining role.

For Transmission, check automatic selection through its enable default,
explicit disable and explicit account-only enable. Disabled service
settings may retain unused account references without forcing them.
Its system additions follow service enablement; HM ordering and the
activation replacement additionally require managed home. Explicit
account-only enable retains upstream directory setup and has no HM
activation. Explicit enable without a login fails its actual user read.

### Check: Profile refresh activation

Covers the `home.refresh-profile.enable` system contract.

With the primary environment active, inspect the merged activation
DAG and generated script. The refresh step is absent by default and
when explicitly disabled. When enabled, it precedes `installPackages`
and guards profile initialization by the absence of `manifest.json`.
Enable refresh without the managed environment, with and without a
login. Confirm successful HM-users and toplevel evaluation, no primary
activation and no evaluation of its profile-directory dependencies.
This check establishes generated activation configuration;
execution on a live home directory needs separate
runtime evidence if activation logic itself changes.

### Check: Existing host user and HM regression

Covers `REQ-002` host scoping, preservation of selected environments,
and the Home Manager host-policy contract.

Inventory all host and profile definitions from `hosts/default.nix`,
including boot profiles, VM profiles and named host definitions.
Confirm each existing host selects `home.enable = true` through
explicit host/profile policy and retains its intended primary login.
Inspect each named host's own configuration beside its hardware role
flags; shared primary-user defaults must not select home management.
Boot and test definitions make their own selection. Generic remains
the explicit inline exception in `hosts/default.nix`.
This inspection includes inactive hosts; it does not claim they are
supported build targets.

For `ShvedGaming`, `ShvedMedia`, `gerrit`, `testA`, `testB`, `testNas`
and `testVps`, evaluate selected primary account and HM settings and
the validation-only system toplevel derivation. Use:

```sh
target=".#nixosValidationConfigurations.$host.config.system.build"
nix eval --raw --no-write-lock-file "$target.toplevel.drvPath"
nix build --dry-run --no-link --no-write-lock-file "$target.toplevel"
```

Run once for each listed `$host`. Confirm independent secondary
accounts remain intact. Use validation stubs only through the
validation configurations; deployable outputs must not import them.
For boot profiles inspect selected account and HM values without
adding image builds as an acceptance gate.

For `generic`, evaluate account/HM selection. Do not build its system,
VM or images: the Generic package-export host contract excludes those
targets. Existing Public Package Access checks remain a separate
validation section and are not gates for this user/HM change.
