# Plan: conditional-module-activation

## Goal and scope

Complete REQ-006 using the selectors in Reusable Module Selection.
Preserve existing enabled behavior except the agreed development/KL policy.
Requirements remain unchanged; module purposes remain explicitly TBD.

Scope: the nine module paths listed in `system.md.delta.yaml`, their static
collector `modules/nixos.nix`, policy in `config/default.nix` and
`config/services/default.nix`, image policy and fixtures described below.
All implementation paths belong to the owned default workspace.

## Approach and constraints

Current gaps are unconditional effects and partially guarded service/drive
configuration. Add default-off interfaces where specified, use final feature
selectors elsewhere, and keep imports static. Apply policy and tests in the
same item as each module change. Preserve lazy HM declarations and ordinary
errors for missing dependencies of enabled system behavior.

Create `tests/modules/conditional-module-activation.nix` and its `.sh` runner
incrementally. Allow focused hardware, KL, service, format and collection
checks; running without a group executes all checks. Use actual modules and
locked support inputs, without depending on project-aware test assembly.

## Plan items

- [x] 1. Make hardware functionality selectable.
  Gate power wake behavior, CIFS/keyutils, AVR and STM32; generate standby
  units only for enabled drives. In `config/default.nix`, select power
  and programmers by development role and move logind policy there.
  Select keyutils for every repository host with `lib.mkDefault true`,
  preserving existing behavior while allowing an explicit disable.
  Add focused hardware fixtures and affected host-setting snapshots.
  Validation: default/explicit off, enabled effects, role overrides, mixed
  drives and missing enabled timeout; verify independent `pkgs.st-gpio`
  access. Run the focused fixtures and existing user/HM focused checks.

- [x] 2. Separate KL trust and NSS selection.
  Gate system trust, NSS certificates and tokens in `modules/security/ca.nix`.
  Add overrideable KL/graphical defaults in `config/default.nix`. Update
  certificate expectations in `tests/modules/primary-user-hm.nix` and host
  snapshots without weakening account/HM independence checks.
  Validation: each switch, employment/graphical combinations, overrides,
  inactive HM laziness and independent system trust. Confirm ShvedGaming
  has no policy-selected KL trust. Run KL and existing user/HM checks.

- [x] 3. Respect final service selections.
  Guard Gerrit and gaming effects by their final selectors.
  Define enable defaults separately from guards that read them; move the
  overrideable VPS-to-Gerrit default to `config/services/default.nix`.
  Add focused fixtures for service settings, units, credentials, firewall
  effects and missing required values, including independent upstream Steam.
  Validation: service fixtures, ordinary explicit disables and missing
  Gerrit inputs; evaluate affected host configurations.

- [x] 4. Finish reusable-collection isolation and regression coverage.
  Move image customization to `config/hardware/bootable/default.nix`;
  import it from `config/nixos.nix` and remove the reusable collector entry.
  Add format comparisons and whole-collection fixtures, including unchanged
  browser/LUKS selectors. Extend `tests/modules/primary-user-hm-hosts.nix`
  with affected policy snapshots. Inspect all remaining imported modules
  for effects lacking an owning selection; correct any REQ-006 violations
  within the existing selectors and add focused regression coverage.
  Validation: run both full runners below, compare policy snapshots and
  generated format settings, and inspect static imports. No item is complete
  until its required checks pass; failures remain within the open item.

## Validation and coverage

```sh
bash tests/modules/conditional-module-activation.sh
bash tests/modules/primary-user-hm.sh
```

The new runner implements all checks in Conditional Module Activation.
Items 1–3 cover individual selectors and their policy; item 4 proves bare
collection inactivity and independence. Together they cover all five
REQ-006 scenarios. Existing user/HM checks preserve REQ-002; host snapshots
check REQ-003 policy. Package probes preserve the affected REQ-004 interface.

Use the existing active-host validation-only toplevel evaluation and build
planning from validate.md. Compare development/KL/VPS changes explicitly;
do not require absence of packages independently selected by other policy.
Record commands, expected/observed results and named error diagnostics.

## Limits and coordination

No deployment, inactive-host expansion, generic system/VM/image builds,
image builds, browser/LUKS flags, broad policy redesign or sibling test-runner
implementation. Private substitutes remain in validation-only test support.

Graph impact for the planned paths reports no symbols and LOW; the graph
indexes no Nix code and cannot establish implementation risk. Source review
and real evaluations provide evidence. Recheck impact if target paths change.

Archive this change before `project-aware-nixos-tests`, then refresh and
revalidate that change's architecture deltas against the updated base.
