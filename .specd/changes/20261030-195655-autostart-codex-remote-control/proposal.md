# Proposal: autostart-codex-remote-control

## Motivation

Development hosts should make their local Codex sessions available through the
shared remote-control daemon without requiring the user to start it manually.
Installing the CLI alone does not provide this availability.

## Current behaviour

Hosts with `hardware.development = true` receive `pkgs.codex` through
`environment.developmentPackages`. The repository configures no Codex daemon
autostart. Starting the shared daemon and enabling remote control remain manual
operations.

The locked package is Codex 0.133.0. Its CLI supports `remote-control start`,
`remote-control stop`, and managed app-server daemon commands. These capabilities
were checked using the repository package, rather than the newer CLI supplied
by the cloud container.

## Proposed solution

Integrate automatic startup of the shared Codex app-server daemon, with remote
control enabled, into development-host configuration for the primary user.
Reuse that user's normal Codex state so local and remote clients can work with
the same daemon-managed sessions.

The implementation should follow the existing `hardware.development`
classification and start the daemon at computer boot, before the primary user
logs in, keeping it available after logout. Remote clients can create new
sessions and resume saved ones without a locally running interactive Codex
session. The exact service mechanism remains an implementation choice.
Remote authentication remains in the user's Codex environment.

## Specs affected

### New specs

None. The existing development-host tooling spec owns this behaviour.

### Modified specs

- `default:development-host-tooling`: extend the tooling contract to cover
  automatic startup and remote-control availability of the primary user's shared
  Codex daemon, with corresponding system contracts and verification scenarios.
  - Depends on (added): none.

### Existing specs included for maintenance

- `default:project-inventory`: refresh the optional inventory with the daemon's
  configuration and management entrypoints. Its requirements, system, and
  verification contracts are expected to remain unchanged and use no-op deltas.
  - Depends on (added): none.

## Impact

Development-host configuration, primary-user service lifecycle, and tooling
verification are affected. Existing integration points include
`config/applications/default.nix`, `config/default.nix`, the host classification
in `modules/hardware/hosts/default.nix`, and the primary-user options in
`modules/home/user.nix`.

The optional inventory needs to reflect whichever integration is selected.
Non-development hosts should retain their current behaviour. The existing
package exposes the necessary commands, so discovery has not established a
need to upgrade Codex.

## Technical context

The shared daemon serves multiple sessions in a user's Codex environment;
execution and working files stay on the host running it. It is not a separate
daemon for each repository. Sessions explicitly started without the daemon
are outside this shared-session model.

The pinned Codex app-server documentation describes `thread/start` for creating
new sessions and `thread/resume` for reopening stored sessions, followed by
`turn/start` to submit work. A local `codex resume` process is therefore not a
prerequisite. This satisfies the user's criterion for startup before login.
Source: https://github.com/openai/codex/blob/rust-v0.133.0/codex-rs/app-server/README.md

The repository already has systemd user-service conventions and primary-user
name/home options. A user service is a candidate integration, but its precise
configuration is not yet selected. The user has chosen to proceed with
autostart and defer questions about daemon supervision, duplicate prevention,
and unavailable authentication to implementation or subsequent work if they
arise. These are not additional user decision gates for this change.

The SpecD graph discovers the relevant specs but indexes no code files in the
current workspace configuration. Its empty dependency results do not establish
that these Nix configuration changes have no impact.

## Open questions

None blocking proposal progression. The startup decision is resolved: start at
boot and remain available after logout. Questions about the exact daemon
integration and recovery when authentication is unavailable are deferred at
the user's request; investigate concrete problems when needed without adding
new prerequisites to this proposal.
