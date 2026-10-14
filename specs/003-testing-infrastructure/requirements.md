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

### Scenario: Secret-dependent host build is identifiable in validation

- WHEN a host normally depends on private secrets or downstream private values
- THEN validation can identify the host system build without requiring the real private inputs to be present in the public checkout
- AND the validation path remains suitable for reproducible SDD checks from public repository state

### Scenario: Validation substitutes do not affect deployment configuration

- WHEN validation uses substitutes for private or machine-specific values
- THEN those substitutes do not implicitly affect final deployable host configurations
- AND deployment configurations remain separate from validation-only support

### Scenario: Validation substitutes are stored as test support

- WHEN substitutes are needed to evaluate or build-plan a secret-dependent host in a test context
- THEN the substitutes are stored in repository test support files
- AND they are not embedded in production host configuration

### Scenario: Validation substitutes are visibly test-only

- WHEN a developer or agent inspects validation substitutes
- THEN the substitutes are explicitly identifiable as test-only values
- AND they cannot be mistaken for real private material required for deployment
