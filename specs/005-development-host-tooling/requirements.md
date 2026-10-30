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

### Scenario: Codex CLI stays current enough for repository workflow

- WHEN the primary user invokes `codex` on a development host
- THEN the command resolves to a supported OpenAI Codex CLI release from the maintained upstream release stream
- AND it is not pinned to a package source known to lag the upstream release stream enough to block the repository workflow

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

## REQ-002: Bootstrap projects with the repository SDD setup

The project must provide a supported bootstrap tool that installs or updates
enough SpecD SDD setup in a target project for work to begin under this
repository's current SDD schema after the tool completes.

The installed setup must include the schema assets and supported agent
skills needed to use that schema. The command must support at least the
`codex`, `opencode`, and `kilocode` agent targets.

Shared SDD process semantics must remain consistent across supported agent
targets, while each target may use the skill invocation syntax required by
that agent.

### Rationale

Reusing this repository's SpecD setup in another project should not require
manual copying, local patch recreation, or schema-specific skill editing.
The bootstrap tool should make the SDD setup reproducible while keeping
agent-specific calling conventions explicit.

### Scenario: Target project receives usable SDD setup

- WHEN a user runs the bootstrap tool for a target project and a supported agent target
- THEN the target project has the SpecD schema assets needed to start work under this repository's current SDD schema
- AND the target project has the skills needed by the selected agent target

### Scenario: Schema setup includes required schema assets

- WHEN the bootstrap tool installs schema setup into a target project
- THEN the installed setup includes the schema file, artifact templates, and related schema assets required by this repository's current SDD schema
- AND the target project does not need extra setup actions before starting work under that schema

### Scenario: Existing SDD setup can be updated

- WHEN a target project already has schema assets or supported agent skills installed by this bootstrap flow
- THEN a user can run the bootstrap tool again to update those installed assets
- AND the target project can continue work under the updated SDD setup

### Scenario: Bootstrap setup follows repository schema updates

- WHEN this repository's current SDD schema changes
- THEN the bootstrap tool's installable schema setup is updated to match that current schema
- AND a target project updated through the bootstrap tool receives the updated schema setup

### Scenario: Supported agents keep their invocation syntax

- WHEN the bootstrap tool installs skills for a supported agent target
- THEN the installed skills use the invocation syntax expected by that agent
- AND the shared SDD workflow meaning remains aligned with the installed schema

### Scenario: Unsupported agents are not silently treated as supported

- WHEN a user requests an agent target that the bootstrap tool does not support
- THEN the command makes that unsupported target visible to the user
- AND it does not silently install skills for a different agent target

## REQ-003: Persistent primary-user Codex remote control

Development hosts must make Codex remote control available automatically
from boot, before local login, and keep it available after local logout.
Remote work must use the primary user's Codex environment.

### Scenario: Remote control is available before local login

- GIVEN a development host with a primary user and the necessary Codex authentication configured
- AND required network connectivity and upstream services are available
- WHEN the host finishes booting before any local user logs in
- THEN the primary user can access Codex remotely without manually starting it on the host

### Scenario: Local logout preserves remote-control access

- GIVEN Codex remote control is available on a development host
- AND the necessary authentication, network connectivity and upstream services remain available
- WHEN the primary user logs out of their local session
- THEN Codex remote-control access remains available without a local logged-in session

### Scenario: Remote work shares the primary user's Codex environment

- GIVEN a development host with working Codex remote-control access
- AND the primary user has existing Codex configuration, authentication and persistent state
- WHEN the primary user works through Codex remote control
- THEN remote work uses the same Codex configuration, authentication and persistent state as their local Codex work
