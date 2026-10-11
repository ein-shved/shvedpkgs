# Requirements

## Requirement: {{first requirement}}

<!-- Describe the need or obligation. Keep implementation details out unless
     they are part of the external contract. Keep this prose concise: explain
     the core need first and put nuance, examples, boundary cases, and
     clarifications in scenarios. If a proposed requirement mostly refines this
     one, convert it into a scenario instead of making a separate requirement.
     Acceptance scenarios are mandatory and must use requirement-level
     concepts, not internal implementation or design mechanisms. -->

### Scenario: {{acceptance scenario}}

<!-- Optional. Describe observable satisfaction using requirement language.
     Good: a development host user can invoke codex and see the expected
     OpenAI TUI.
     Bad: hardware.development=true causes pkgs.codex to appear in
     environment.systemPackages. -->

- GIVEN {{requirement-level precondition}} <!-- optional -->
- WHEN {{observable action or condition}}
- THEN {{observable expected outcome}}
