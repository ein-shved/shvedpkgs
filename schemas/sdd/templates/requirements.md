# Requirements

<!-- Check existing needs and authoritative process rules first. A defect in
     their realization may need a system or plan change with a no-op requirements
     delta. Patch constraints, defect descriptions, and proposed fixes do not
     become requirements merely because the user mentioned them. -->

<!-- Consume the accepted proposal's numbered allocation without another intent
     checkpoint. An absent obligation or dismissed capability creates no need.
     Genuine negative constraints retain an observable violation and scenarios. -->

## Requirement: {{first requirement}}

<!-- Describe the need or obligation. Keep implementation details out unless
     they are part of the external contract. Keep this prose concise: explain
     the core need first and put nuance, examples, boundary cases, and
     clarifications in scenarios. Treat an overly long body as a warning sign.
     If a proposed requirement mostly refines this one, convert it into a
     scenario instead of making a separate requirement. Acceptance scenarios are
     mandatory, belong to this requirement, and must use requirement-level
     concepts, not internal implementation or design mechanisms. -->

### Scenario: {{acceptance scenario}}

<!-- Describe observable satisfaction using requirement language.
     GIVEN is optional. WHEN and THEN are required. Use AND after any clause
     for additional preconditions, actions, conditions, or expected outcomes.
     Good: a development host user can invoke codex and see the expected
     OpenAI TUI.
     Bad: hardware.development=true causes pkgs.codex to appear in
     environment.systemPackages. -->

- GIVEN {{requirement-level precondition}} <!-- optional -->
- WHEN {{observable action or condition}}
- AND {{additional action or condition}} <!-- optional -->
- THEN {{observable expected outcome}}
- AND {{additional expected outcome}} <!-- optional -->
