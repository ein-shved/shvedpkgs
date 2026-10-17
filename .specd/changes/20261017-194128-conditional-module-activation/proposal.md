# Proposal: conditional-module-activation

## Motivation

Project-aware NixOS tests need to make repository modules available while
selecting only the functionality relevant to each test node. Importing the
reusable collection currently brings unrelated behavior and dependencies into
that configuration.

Architecture REQ-006 already requires optional, disabled-by-default reusable
functionality. Its five acceptance scenarios cover default inactivity, explicit
disablement, unused dependencies, required dependencies of enabled behavior,
and independence of other selected functionality. Those requirements are
sufficient for this change. The work completes their implementation and
extends the system and validation artifacts to cover the remaining modules.

## Current behaviour

Primary-account and Home Manager selection already follow the intended model:
an explicitly configured login selects the account, `home.enable` defaults to
false, and unused home declarations remain deferred. Several other modules
already select behavior through feature flags or nonempty collections.

Source inspection nevertheless found these remaining areas:

- Power handling, KL certificate installation, CIFS/keyutils integration, and
  AVR/STM32 programmer support contribute configuration unconditionally.
- Bootable-format configuration applies repository image customizations without
  an explicit owning selection.
- Gerrit selects itself from the VPS role in the reusable layer and contributes
  service configuration even when the final service selection is disabled.
- Drive standby creates service definitions for disabled entries and can force
  their missing timeout values.
- Gaming and browser NSS integration need review of their owning selections and
  opt-out behavior. Unconditional settings alone do not establish that upstream
  modules apply live effects; that distinction needs verification.

The architecture validation artifact explicitly limits current optionality
coverage to primary-user/HM behavior and its consumers. It does not establish
conformance of the rest of the reusable module collection.

## Proposed solution

Audit the reusable collection and complete conditional application of each
feature's effects. Keep interfaces available through static imports. Reuse an
existing flag or explicitly supplied value where it expresses the feature's
selection; introduce an interface where the behavior has no suitable owner.
Fragments follow their owning feature rather than acquiring a flag merely
because they occupy a separate file.

Keep reusable interfaces and their behavior in `modules/`. Express repository
policy through those interfaces in `config/` and host/profile definitions.
Review intentional host selections when moving existing policy; current
unconditional installation is not sufficient evidence that every host needs a
feature. Make intended migration differences visible during design review.

CIFS/keyutils retains its existing selection for every repository host through
shared configuration policy, with an explicit opt-out.

Extend technical validation to exercise default-off, explicit-off, enabled,
missing-dependency, and independent-feature cases. Preserve the existing
primary-user/HM contracts, including deferred declarations and ordinary errors
for missing dependencies of selected system behavior.

## Specs affected

### New specs

None.

### Existing specs

- `default:001-project-architecture` remains the owning spec.
  - Requirements: reuse REQ-006 unchanged through a no-op delta. REQ-002 and
    REQ-003 remain compatibility context for account and host-purpose behavior.
  - System: describe feature ownership, selection interfaces, and conditional
    effects for the remaining reusable behavior.
  - Validate: extend coverage beyond the existing user/HM checks.
  - ADRs: add durable rationale only if system design makes a significant
    architectural choice that needs its own record.
  - Added spec dependencies: none proposed.

The change-scoped plan will define implementation units, migration order, and
the validation that completes each unit. This proposal does not prescribe
their execution sequence.

## Impact

Implementation can affect `modules/`, their policy consumers in `config/` and
`hosts/`, and repository-owned evaluation fixtures under `tests/modules/`.
Shared assembly and package publication need regression inspection where
feature selection interacts with them. All targets are within the owned
`default` workspace.

This work prepares selectable modules for `project-aware-nixos-tests`. That
change's test assembly and package-compatibility work remain separate. Both
changes target the architecture spec; the overlap was explicitly accepted.
Their merged architecture content needs review and revalidation against the
latest base before archive. The checks for this change can use existing
evaluation fixtures without depending on unfinished test infrastructure.

Scope excludes a general redesign of repository defaults, deployment,
expansion of inactive-host support, and repair of unrelated dormant collectors.
The synthetic `generic` host remains a package-export configuration; its
system, VM, and image builds are not validation targets.

## Technical context

- `modules/nixos.nix` imports the reusable collection statically. Conditional
  application concerns evaluated behavior, not config-dependent imports.
- `flake.nix` also assembles the opinionated `config/` layer and external
  modules. Tests of reusable defaults need the required option interfaces
  without accidentally importing repository policy as their baseline.
- Inspect feature-owned effects: services, packages, activation, trust,
  firewall settings, udev rules, generated files, and image customization.
  Another independently selected feature may legitimately contribute the same
  package or setting.
- Deferred `hm` declarations remain valid with the primary environment off.
  Actual system-side reads retain their dependency obligations. No placeholder
  users or guards that silently omit selected functionality are intended.
- Existing primary-user/HM fixtures provide regression coverage. Some currently
  expect unconditional certificates; new trust selection needs explicit
  fixture policy rather than retaining that behavior solely to pass old tests.
- Validation-only private substitutes stay in the test-support boundary defined
  by `default:003-testing-infrastructure` and do not enter deployable outputs.
- The fresh SpecD graph indexes six specs but no Nix files or symbols, even
  after an indexing attempt. Source inspection provides implementation context;
  empty graph impact or hotspot results cannot establish low implementation
  risk.

## Open questions

The requirement coverage and owning spec are settled. The following choices
need resolution before proceeding to downstream design artifacts:

1. Which remaining behaviors should expose reusable selection interfaces, and
   which are solely policy that should move to `config/`? In particular, settle
   power behavior and image-format customization.
2. Should KL trust follow employment selection, or have an independent switch?
   `ShvedGaming` explicitly disables KL employment while currently receiving
   its system trust. Graphical classification alone does not establish a need
   for that trust or token setup.
3. Which hosts intentionally need programmer support and
   the other newly selectable behavior? Do not preserve accidental global
   selection by enabling them everywhere.
4. Do browser NSS integration and LUKS helper installation need independent
   opt-outs beyond their existing browser/device selections? Resolve this
   against REQ-006 without mechanically adding one flag per file.
5. Establish overrideable Gerrit selection consistent with final
   feature enablement, and coordinate architecture archive order with
   `project-aware-nixos-tests` before either change is archived.

These questions belong to system and policy design; they do not require new
requirements for module optionality. Review of this proposal is the checkpoint
for resolving them before work continues downstream.
