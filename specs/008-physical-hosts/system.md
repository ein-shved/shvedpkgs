# System Specification

## Gerrit

`nixosConfigurations.gerrit` is a headless Gerrit host.
It selects `hardware.isVps = true` and disables Home Manager
(`home.enable = false`).

Reference: [REQ-001](requirements.md#req-001-minimal-system-footprint-on-gerrit).
