# Requirements

## REQ-001: Development hosts expose required workflow tools

Development hosts must make the required repository workflow tools available
in the primary user's command lookup path.

The required tools are:

- `codex`
- `specd`

Each listed command must resolve to the widely recognized developer tool
identified by that command name at the time the command is added to this
list. For example, `codex` means the genuine Codex CLI originated by
OpenAI, and `git` means the distributed version control system originally
created by Linus Torvalds. Listed commands must not resolve to stubs,
placeholders, or unrelated executables unless this document explicitly says
otherwise.

### Rationale

Development hosts support the repository SDD workflow and related project
maintenance. Providing the tools through host configuration keeps the workflow
reproducible across development machines.

### Scenario: Development host primary user can invoke required tools

- WHEN the primary user works on a host classified as a development host
- THEN the primary user's command lookup path includes every required repository workflow tool
- AND the user can invoke each tool listed by this requirement

### Scenario: Required tool commands resolve to the expected tools

- WHEN the primary user invokes a listed workflow-tool command on a development host
- THEN the command resolves to the widely recognized developer tool identified by that command name
- AND it does not resolve to a stub, placeholder, or unrelated executable unless this requirement explicitly allows it

### Scenario: Non-development hosts are outside the requirement

- WHEN a host is not classified as a development host
- THEN this requirement does not require that host to expose the listed workflow tools
- AND the host may remain valid for its own purpose without those tools

### Scenario: Required workflow tools are selected by development host policy

- WHEN a package is required only because a host is a development host
- THEN that package is selected through development-host configuration policy
- AND the selection is not encoded as host-specific installation policy in the package definition

### Scenario: Package definitions remain host-policy neutral

- WHEN a package can be used by multiple host purposes
- THEN the package definition does not decide which concrete hosts install it for development workflow reasons
- AND development-host configuration policy owns that installation decision
