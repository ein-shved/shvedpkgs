# Requirements

## REQ-001: Updating the local or a named remote host

The project's `nixos` utility must let users update an installed NixOS system
through `nixos-rebuild`. The local host is the default target; a remote host
is selected by name without repeating connection and update settings.

### Scenario: Local target by default

- GIVEN NixOS is installed on the local host
- WHEN the user invokes `nixos` to update without selecting another target
- THEN the local host is updated

### Scenario: Remote target by name

- GIVEN access and updates are configured for a remote host running NixOS
- AND the remote host is reachable
- WHEN the user selects that host by name when invoking `nixos` to update
- THEN the selected remote host is updated
- AND the user does not need to supply additional connection or update flags

### Scenario: Remote update with a sudo password

- GIVEN a reachable remote host is configured to update using sudo with a password
- WHEN the user selects that host by name when invoking `nixos` to update
- THEN the sudo password is requested when needed
- AND the selected host is updated after the correct password is entered
- AND the user does not need to supply additional connection or update flags

## REQ-002: Compatibility with nixos-rebuild arguments

The `nixos` utility must support all `nixos-rebuild` arguments, preserving
their meaning, and allow them to be used together with its own arguments.
Exceptions for `switch` and `test` on hosts that require a reboot are defined
in [REQ-003](#req-003-updating-hosts-that-require-a-reboot).

### Scenario: Preserving the meaning of nixos-rebuild arguments

- GIVEN the user has selected a valid `nixos-rebuild` operation and arguments
- WHEN the user passes them through `nixos`
- THEN the operation and arguments retain their `nixos-rebuild` meaning, subject to the exceptions in REQ-003

### Scenario: Combining arguments

- WHEN the user invokes `nixos` with the utility's own arguments and `nixos-rebuild` arguments
- THEN the utility's own arguments apply as intended
- AND the `nixos-rebuild` arguments retain their meaning, subject to the exceptions in REQ-003

## REQ-003: Updating hosts that require a reboot

The `nixos` utility must support hosts that, because of memory constraints,
can apply a new configuration only after a reboot.

### Scenario: Switch applies the configuration through a reboot

- GIVEN the selected host is configured to apply configurations only after a reboot
- WHEN the user invokes `nixos <host> switch`
- THEN the new configuration is prepared for the next boot
- AND the host reboots after successful preparation
- AND the new configuration is applied only after the reboot

### Scenario: Preparation failure does not trigger a reboot

- GIVEN the selected host is configured to apply configurations only after a reboot
- WHEN the user invokes `nixos <host> switch`, but preparing the configuration for boot fails
- THEN the invocation fails
- AND the host does not reboot

### Scenario: Test is unavailable for a host that requires a reboot

- GIVEN the selected host is configured to apply configurations only after a reboot
- WHEN the user invokes `nixos <host> test`
- THEN the invocation fails
- AND the new configuration is not activated and the host does not reboot

### Scenario: Other operations retain their meaning

- GIVEN the selected host is configured to apply configurations only after a reboot
- WHEN the user selects an operation other than `switch` or `test`
- THEN the operation retains its `nixos-rebuild` meaning
- AND an explicit `boot` only prepares the configuration for the next boot without rebooting
