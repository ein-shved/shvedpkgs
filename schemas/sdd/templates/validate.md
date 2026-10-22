<!-- AI guidance: describe technical validation, not acceptance scenarios.
     Acceptance scenarios belong in requirements.md. This artifact may use
     system-level concepts, implementation-facing checks, commands, tests,
     inspections, fixtures, and validation support described by this or other
     system specs. Do not include purpose or motivation prose. -->

# Validation: {{spec.name}}

## Validation Scope

<!-- List only coverage references to owning requirements/scenarios and system
     headings. Do not add purpose or motivation prose. Delete when unnecessary. -->

## Automated Checks

### Check: {{automated check name}}

- Covers: {{Markdown link to owning requirement or relevant system heading}}
- Method: {{actual runner/test and the cases its executable assertions cover}}
- Evidence: {{expected result of that runner}}

<!-- Inspect execution and assertions before claiming coverage; fixture/snapshot
     presence is insufficient. Keep assertion detail in tests. Delete empty groups. -->

## Manual Checks

### Check: {{check name}}

- Covers: {{Markdown link to owning requirement or relevant system heading}}
- Method: {{concrete action: test, command, inspection, build, evaluation, etc.}}
- Evidence: {{expected result of that action}}
- Notes: {{only needed setup, prerequisites, or execution limits; omit if unused}}

<!-- Use resolvable links, e.g. [REQ-001](requirements.md#req-001-title) or
     [Contract](system.md#contract). Cross-spec links include the owning spec's
     relative path. References identify owners without copying their content.
     Retain manual actions and expected results for uncovered conditional runtime
     duties. Checks work without change history; migration and before/after
     comparisons belong in plan. -->
