# Plan: autostart-codex-remote-control

## Goal

Implement the reviewed Codex service contract and enable remote control at boot
for the primary user on development hosts.

## Assumptions

- The selected `pkgs.codex` supports foreground `app-server`, remote control,
  and Unix listeners as established during discovery.
- The configured account and writable home already exist. Authentication and
  saved sessions are supplied by the user outside Nix configuration.
- Authenticated remote checks require a suitable NixOS host and remote client.
  The current cloud container is Debian and has no `/dev/kvm`.

## Constraints

Keep reusable options and service construction in `modules/`, and host policy
in `config/`. Remove Codex from the development package bucket: the enabled
service module owns its installation. Preserve the other development packages.
Do not upgrade
flake inputs, install an upstream managed daemon, create accounts, or place
credentials in the Nix store. All implementation targets are within the owned
`default` workspace.

## Current Implementation Observations

`modules/nixos.nix` and `config/nixos.nix` explicitly import their module trees.
`config/applications/default.nix` already selects Codex and SpecD through the
development package bucket. `modules/home/user.nix` supplies the primary-user
name and home. No Codex service currently exists.

The SpecD graph has no indexed code symbols. Its impact query for the planned
files returned LOW with no symbols; direct inspection of imports and callers
is required because that result does not establish absence of code impact.

## Implementation Approach

Add `modules/services/codex/default.nix` with the reviewed `services.codex`
interface and import it from `modules/nixos.nix`. Use `lib.mkEnableOption`,
`lib.mkOption`, option types, assertions, and `lib.mkIf` for conditional service
and package contributions. Derive default home from the selected account and
default Codex home from that home. Validate enabled-account and absolute-path
settings without evaluating nonexistent account attributes prematurely.

Construct `ExecStart` from the selected package with `lib.escapeShellArgs`.
Use the reviewed foreground command, conditional remote-control flag, listener,
boot dependencies, identity, environment, restart policy, and journal logging.
Provide installed host commands in PATH without introducing recursive package
or service dependencies. Custom socket parent ownership remains a deployment
precondition; the module does not invent directory ownership policy.

Add `config/services/codex/default.nix` and import it from `config/nixos.nix`.
Apply overridable development-host enablement with `lib.mkDefault` and pass
`config.user.name` and `config.user.home` through the public service interface.
The reusable module must evaluate without those repository options.

Remove the explicit `codex` entry from
`config/applications/default.nix`'s `environment.developmentPackages`.
The enabled module supplies the selected CLI through `environment.systemPackages`.
Disabling the service no longer leaves Codex installed through that bucket;
explicit independent package selection remains possible.

Add focused module evaluation checks in `tests/modules/codex/default.nix`. Keep them
invocable through a targeted `nix eval --file` expression using the repository's
locked nixpkgs input; no broad flake-output restructuring is needed.

Add `tests/modules/codex/vm.nix` using `testers.runNixOSTest`, with the real
selected Codex package and the reusable module. Provide an existing normal user,
an empty writable Codex home, and no authentication credentials. Run the VM
without external network access. Use the NixOS Python test driver to inspect
the unit and launch the installed `codex --remote unix://` console client as
that user in a pseudo-terminal. Drive it with a bounded expect-style harness
and verify successful app-server initialization from server/client evidence;
an auth prompt is acceptable, but a socket file or CLI help output alone is not.
Ensure the client does not launch a second local app-server.

Expose the test through a targeted `nix-build` expression invoking
`pkgs.callPackage ./tests/modules/codex/vm.nix { }` with the repository's locked
package set. Keep VM testing separate from evaluation fixtures.

## Minimal Change Set

- `modules/services/codex/default.nix`: reusable service and options.
- `modules/nixos.nix`: reusable-module import.
- `config/services/codex/default.nix`: development-host policy.
- `config/nixos.nix`: policy import.
- `config/applications/default.nix`: remove Codex from the development bucket.
- `tests/modules/codex/default.nix`: focused evaluation assertions.
- `tests/modules/codex/vm.nix`: NixOS framework VM integration test.

## Validation Plan

Evaluate isolated module fixtures for disabled, enabled, custom-package,
custom-environment, default/custom-socket, and remote-control-disabled cases.
Inspect generated unit values, package membership, and failed assertions for
invalid user/home settings. Include a socket path with spaces to check argument
escaping. Import the module without repository role or primary-user modules.

Evaluate policy fixtures with development classification on and off and with
explicit enablement overrides. Inspect representative repository validation
configurations with `nix eval` and dry-run their system build to catch import,
assertion, and dependency errors. Use validation outputs where private host
inputs are absent, rather than changing deployable configurations for testing.

Build and run the NixOS VM test with no external network routes and no Codex
credentials. Inspect `systemctl cat codex.service` and its enabled/active state;
wait for the Unix listener and exercise the real console client against it.
Check the service remains active after client exit, over a bounded observation
interval, without restart churn. Inspect journal diagnostics and remote-control
status to distinguish unavailable remote registration from local service failure.

Discovery with an empty existing `CODEX_HOME` and no auth kept the real
app-server running until the probe timeout. Upstream starts remote control in
a separate task with reconnection handling. The expected VM result is therefore
a live locally connectable app-server despite missing auth and internet.
If implementation-time investigation establishes an intentional upstream exit
instead, document its exact diagnostic and exit status before changing the test
expectation; do not accept arbitrary failures or restart loops. Test local CLI
connectivity separately with `remoteControl.enable = false` if that documented
exit prevents an offline remote-control-enabled process from serving clients.

On an available NixOS host or VM, perform the runtime scenarios from `verify`:
boot before login, inspect the supervised process and environment, connect over
the configured Unix socket, and confirm survival after logout. Authenticated
remote verification must create a new session, resume a saved one, and complete
work as the primary user without a local interactive client. Compare existing
configuration and history before and after startup.

Record evaluation, build planning, service runtime, and authenticated remote
results separately. If the environment cannot execute a scenario, record it as
unverified with its missing prerequisite; structural validation or a mock
process does not prove the real remote-control behavior.

## Top-Level Plan Items

- [x] 1. Implement the reusable Codex service module and register its import.
      Scope: `modules/services/codex/default.nix`, `modules/nixos.nix`, and
      isolated checks in `tests/modules/codex/default.nix`.
      Validation: evaluate enabled/disabled fixtures, package consistency,
      command arguments, identity/environment, boot/restart settings, option
      overrides, and invalid-configuration assertions. Confirm standalone use
      without development-host or primary-user options.

- [x] 2. Integrate development-host policy and validate repository configurations.
      Scope: `config/services/codex/default.nix`, `config/nixos.nix`,
      `config/applications/default.nix`, and policy
      fixtures in `tests/modules/codex/default.nix`.
      Validation: development/non-development and explicit-override fixtures;
      targeted repository validation-output evaluation and dry-run builds;
      confirm Codex is absent from the development bucket, installed through
      the enabled module, and absent when disabled unless independently selected;
      confirm SpecD and other development package selections are preserved.

- [x] 3. Implement and run the offline unauthenticated NixOS VM test.
      Scope: `tests/modules/codex/vm.nix` and its targeted invocation.
      Validation: the real unit exists and is enabled, its offline/no-auth
      lifecycle matches the established upstream behavior, and the installed
      console client connects to the supervised app-server. Retain driver logs
      and journal evidence. Building the test derivation alone is not execution.

- [ ] 4. Verify the real service and authenticated remote session workflow.
      Scope: runtime checks on a suitable NixOS host or VM using the reviewed
      `verify` scenarios.
      Validation: before-login availability, survival after logout, correct
      account/state, default/custom Unix connection, and successful remote new
      and resumed sessions. Record actual evidence and unresolved prerequisites;
      do not mark this item complete while required runtime checks are unverified.

## Out Of Scope

Authentication provisioning/recovery, managed daemon installation/updating,
duplicate-daemon policy, public network listeners, package upgrades, and SpecD
schema changes. Inventory remains unchanged because this new capability is
introduced through SDD and does not touch existing inventory material. No ADR
is needed for following the existing module and configuration conventions.

## Review Notes

Implementation begins only after plan review. The cloud container lacks KVM;
attempt VM execution with supported software emulation if feasible, otherwise
record the VM run as unverified. Authenticated runtime verification may require
the user's authenticated host; the cloud environment can provide evaluation
and build evidence but cannot substitute for that host's remote-session checks.
