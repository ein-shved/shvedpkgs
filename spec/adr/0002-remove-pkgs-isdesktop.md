# ADR-0002: Remove `pkgs.isDesktop`

Status: Accepted

## Context

The package set currently exposes a derived host flag named `pkgs.isDesktop`.
Its intended meaning is unclear in the current system design, and it appears to
be a remnant of older versions of the configuration.

The current host classification model is moving toward explicit, auditable host
role flags. Keeping an unclear derived desktop flag makes that model harder to
evolve because package expressions can depend on an implicit interpretation
that is not part of the intended classification vocabulary.

## Decision

Remove `pkgs.isDesktop` from the system specification and from the package set
interface.

New design work must use explicit host classification flags or introduce a
well-defined replacement through the SDD process.

## Consequences

The implementation in this repository must be reviewed and updated to remove
the `pkgs.isDesktop` overlay flag.

Other repositories and private extensions that depend on this package set must
also be reviewed for `pkgs.isDesktop` usage before or during migration.

Removing the flag may require replacing old package-level conditionals with
clearer configuration-level host classification rules.
