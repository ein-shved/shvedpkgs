# Validation: Development Host Tooling

## Validation: Required Development Tools

Validation detail for `REQ-001: Development hosts expose required workflow
tools` remains TBD.

This section intentionally does not describe bootstrap-tool validation.

## Validation: Codex Version

Covers the `REQ-001` scenario "Codex CLI stays current enough for repository
workflow" and the Codex source contract in
[Development Host Tooling](system.md#development-host-tooling).

### Check: Installed Codex version

On a development host with the updated configuration activated, run this
command as the primary user in their normal shell:

```bash
codex --version
```

The command must succeed and print:

```text
codex-cli 0.162.1
```

Expected release: [OpenAI Codex 0.162.1](https://github.com/openai/codex/releases/tag/rust-v0.162.1),
checked on 2026-10-14. This check exercises the installed command through
the user's PATH.

## Validation: SpecD Bootstrap Support

This section validates `REQ-002: Bootstrap projects with the repository SDD
setup` and the system contracts for the bootstrap command, schema asset
package, agent skill packages, and Nix wrapper.

Validation focuses on package-level and integration-level evidence. It does
not define acceptance scenarios; those remain in `requirements.md`.

The concrete bootstrap checks below should run inside one NixOS test
invocation. The test may create multiple temporary target projects, but it
should avoid splitting these checks into separate VM boots or unrelated test
runs unless a future constraint requires that separation.

### Check: Bootstrap command package exposes the CLI contract

- Covers: `REQ-002`; `SpecD Bootstrap Support`
- Method: In the bootstrap NixOS test, invoke the packaged bootstrap command.
- Evidence: `specd-bootstrap --help` succeeds and documents `--target`, repeatable `--agent`, supported agents, and the default target directory.
- Notes: The test must run through the packaged command so the Nix wrapper is exercised.

### Check: Nix wrapper provides runtime inputs by default

- Covers: `SpecD Bootstrap Support` runtime environment contract
- Method: In the bootstrap NixOS test, run the packaged `specd-bootstrap` command in a clean shell environment that does not predefine bootstrap asset variables.
- Evidence: The command can invoke `specd` through `PATH` and can locate packaged schema and agent assets through wrapper-provided `SPECD_BOOTSTRAP_SCHEMA_ROOT` and `SPECD_BOOTSTRAP_AGENT_MANIFESTS` defaults.
- Notes: The same NixOS test also sets `SPECD_BOOTSTRAP_AGENT_MANIFESTS` explicitly to a synthetic agent manifest and verifies that wrapper defaults are not used when callers provide an override.

### Check: Bootstrap initializes a new target project

- Covers: `REQ-002` scenarios for usable SDD setup and required schema assets; `SpecD Bootstrap Support`
- Method: In the bootstrap NixOS test, create a temporary git repository without `specd.yaml`, then run `specd-bootstrap --target <tmpdir> --agent codex`.
- Evidence: The target project contains `specd.yaml`, `schemas/sdd/schema.yaml`, `schemas/sdd/templates/`, and the Codex skill payload at the manifest-declared target directory. Running `specd changes list --format text` or another non-mutating SpecD inspection command in the target project succeeds.
- Notes: The check proves that `specd init --schema ./schemas/sdd/schema.yaml` is used only after the schema tree is materialized.

### Check: Bootstrap updates an existing target project

- Covers: `REQ-002` existing-setup update scenario; `SpecD Bootstrap Support`
- Method: In the bootstrap NixOS test, create a temporary project with an existing `specd.yaml` containing unrelated configuration, then run `specd-bootstrap --target <tmpdir> --agent codex`.
- Evidence: The resulting `specd.yaml` uses `schema: ./schemas/sdd/schema.yaml`, preserves unrelated configuration fields after YAML serialization, and the updated schema and Codex skill payload are present.
- Notes: The test must fail if the update path discards unrelated configuration fields or overwrites the whole configuration through `specd init --force`.

### Check: Bootstrap installs multiple agent skill packages

- Covers: `REQ-002` supported-agent scenarios; repeatable `--agent` CLI contract
- Method: In the bootstrap NixOS test, run `specd-bootstrap --target <tmpdir> --agent codex --agent kilocode` in a temporary target project.
- Evidence: Both selected agent skill payloads are materialized at their manifest-declared target directories, and each payload uses the invocation syntax expected by its agent.
- Notes: The check should inspect representative skill files for Codex `$specd-*` invocation and slash-style invocation where the selected agent requires it.

### Check: Agent manifest overrides replace wrapper defaults

- Covers: `SpecD Bootstrap Support` runtime environment contract
- Method: In the bootstrap NixOS test, create a synthetic agent package fixture with `$out/manifest.yaml` and `$out/skills/`, then run the packaged `specd-bootstrap` command with `SPECD_BOOTSTRAP_AGENT_MANIFESTS` set to that manifest file.
- Evidence: `specd-bootstrap --help` lists the synthetic agent and does not list the wrapper-default agents. Running the command with the synthetic agent installs the synthetic payload at the manifest-declared destination directory.
- Notes: This validates `--set-default` wrapper behavior without depending on a raw wrapped binary path.

### Check: Agent CLIs can discover installed skills when supported

- Covers: `REQ-002` supported-agent scenarios; agent skill package contracts
- Method: In the bootstrap NixOS test, include the console packages for supported agent CLIs when those packages are available in the test package set. After bootstrap installs each selected agent's skills, run that agent's non-agentic skill discovery or debug command when the CLI provides one.
- Evidence: For opencode-compatible packages, `opencode debug skill` can list the installed skills in the target project. For kilocode-compatible packages, `kilo debug skill` or the packaged equivalent can list the installed skills in the target project. The listed skills include representative SpecD skills from the installed payload.
- Notes: This check must not require direct access to the interactive agent runtime or model service. If a supported agent package is not available in the test package set, or if the CLI does not expose a non-agentic skill discovery command, leave a TODO in the implementation/test source for that agent until the package or CLI support exists. Codex currently has no confirmed `debug skill`-style command from local help output, so Codex skill discovery may need to remain a TODO unless implementation research finds a supported non-agentic inspection path.

### Check: Unsupported agents are rejected visibly

- Covers: `REQ-002` unsupported-agent scenario
- Method: In the bootstrap NixOS test, run `specd-bootstrap --target <tmpdir> --agent unsupported-agent` in a temporary target project.
- Evidence: The command exits non-zero, reports the unsupported agent target, and does not install another agent's skills as a fallback.
- Notes: This check should also confirm that partial writes are either absent or clearly limited to safe preflight state.

### Check: Schema package follows repository schema updates

- Covers: `REQ-002` schema-update scenario; schema asset package contract
- Method: In the bootstrap NixOS test, inspect the schema asset package output used by the bootstrap command and compare it with this repository's local `schemas/sdd/` source tree.
- Evidence: Package build output contains the current `schema.yaml` and every current template file from `schemas/sdd/templates/`.
- Notes: This may compare file presence and selected content hashes between source assets and package output inside the same test run.
