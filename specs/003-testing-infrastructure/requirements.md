# Requirements

## REQ-001: Validate Secret-Dependent Hosts Without Private Material

The repository must support evaluation and build-planning validation for host
configurations that normally depend on private secrets or downstream private
values, without requiring those private inputs to be present in the public
checkout.

Validation support must make it possible to identify the host system build in a
test context. It must not replace or weaken the final host configurations used
for deployment.

### Rationale

- SDD changes need reproducible validation commands that work from the public
  repository state.
- Some active hosts intentionally depend on private or machine-specific values.
- Missing private values should not prevent validating unrelated structural
  changes when safe test substitutes are sufficient.
- Test substitutes must remain clearly separated from deployable host
  configurations.

### Acceptance criteria

- For a host whose normal configuration depends on private values, a validation
  command can identify the host system build without requiring the real private
  values.
- Validation substitutes do not implicitly affect final deployable host
  configurations.
- Validation substitutes are stored in repository test support files rather
  than embedded in production host configuration.
- Validation substitutes are explicitly identifiable as test-only values.
