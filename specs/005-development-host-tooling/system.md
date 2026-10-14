# System Specification

## Development Host Tooling

For every [development host](#development-host), the
[primary user](#primary-user) has these development tools available in
the command lookup path:

- `codex`
- `specd`

`codex` is provided from [nixpkgs unstable](#nixpkgs-unstable) through
`pkgsUnstable.codex`. The stable package is too old for the repository
workflow. The unstable revision is pinned by the repository flake lock.

Development-host policy selects this package through
`environment.developmentPackages`.

`specd` is provided by the repository package-set attribute
`pkgs.specd`, which packages the genuine SpecD CLI from the `@specd/cli`
project.

If a host is not a [development host](#development-host), or the user is
not the [primary user](#primary-user), these packages MAY NOT be available
in the command lookup path.

Traceability:

- Satisfies
  [`REQ-001: Development hosts expose required workflow tools`](requirements.md#req-001-development-hosts-expose-required-workflow-tools).

## SpecD CLI Package

The repository package set provides:

```nix
pkgs.specd
```

`pkgs.specd` is the package-set member for the genuine SpecD CLI from
the `@specd/cli` project. It MUST expose the `specd` command.

The package MAY carry repository patches for local SDD workflow integration,
such as local artifact names, local templates, or agent-instruction text.
Those patches MUST NOT turn `pkgs.specd` into a stub, placeholder, or
unrelated executable.

The package SHOULD behave like an ordinary package-set member under the
[`pkgs`](#pkgs) layer. It MUST NOT encode host-specific policy. Host
selection for installing `specd` belongs to [Development Host Tooling](#development-host-tooling).

The package contract is validated by a repository per-package NixOS test under
the `tests/pkgs/` test-support area. The test boots a minimal test machine with
`pkgs.specd` installed and verifies that invoking `specd` with valid inspection
arguments succeeds and reports behavior consistent with the genuine SpecD CLI.

## SpecD Bootstrap Support

The repository package set provides a supported SpecD bootstrap tool. The
tool exposes the user-facing command:

```text
specd-bootstrap
```

`specd-bootstrap` is implemented as a small Rust CLI. Rust is used because
the tool must safely inspect and update existing `specd.yaml` files instead
of relying on ad hoc shell text replacement. The CLI may invoke `specd init`
when a target project has no SpecD configuration yet, but it MUST NOT rely on
`specd init --force` as the normal update path for an existing project.

The Rust binary discovers external runtime inputs through its process
environment instead of embedding Nix store paths in the source code. It
invokes the `specd` command by name and relies on `PATH` resolution for the
SpecD CLI. It reads packaged schema assets and agent skill assets from
environment variables owned by the bootstrap package.

The Nix package for the bootstrap command wraps the Rust binary. The wrapper
adds the repository's `pkgs.specd` package to `PATH` and sets default values
for the bootstrap asset environment variables when the caller has not
already set them. This keeps the binary usable outside the Nix wrapper while
making the packaged command self-contained by default.

The command initializes or updates SpecD SDD setup in an existing target
project directory. The installed setup is sufficient for work to begin under
this repository's current SDD schema without extra setup actions.

The command-line interface is argument-driven and non-interactive, so
bootstrap and update operations can be used from tests, scripts, and CI. The
required invocation shape is:

```text
specd-bootstrap [--target <path>] --agent <agent> [--agent <agent> ...]
```

`--target` identifies the target project directory and defaults to the
current working directory (`.`). `--agent` is repeatable and selects one or
more agent skill packages to install or update, with supported values
including `codex`, `opencode`, and `kilocode`. The command provides
`--help` output describing supported agents, defaults, and options.

Bootstrap support is composed from these package-set contracts:

- a bootstrap command package exposing `specd-bootstrap`;
- a schema asset package containing this repository's current SDD schema
  file, artifact templates, and related schema assets;
- separate agent skill packages for `codex`, `opencode`, and `kilocode`.

The schema asset package exposes this layout:

```text
share/specd-bootstrap/schemas/sdd/schema.yaml
share/specd-bootstrap/schemas/sdd/templates/
```

The schema file references artifact templates with paths relative to the
schema file, such as `templates/requirements.md` and `templates/system.md`.
The bootstrap command therefore materializes the complete `schemas/sdd/`
tree into the target project, not only `schema.yaml`. In a bootstrapped
target project, `specd.yaml` points at `./schemas/sdd/schema.yaml`, and
SpecD resolves the schema's template references under
`./schemas/sdd/templates/`.

Each agent skill package exposes this layout at its package output root:

```text
manifest.yaml
skills/
```

`manifest.yaml` declares the agent name, the source skill payload directory,
and the destination target-project directory where that agent expects its
skills. The manifest uses these fields:

```yaml
agent: <agent>
sourceSkillsDir: skills
destinationSkillsDir: <target-project-relative path>
```

`sourceSkillsDir` may be absolute or relative to the manifest file.
`destinationSkillsDir` is relative to the target project and MUST NOT escape
that project. The `skills/` tree is the rendered skill payload copied into
the declared destination directory. Keeping source and destination metadata
in a manifest prevents the bootstrap command from inferring agent-specific
filesystem layout from package names or payload directory names.

Runtime asset discovery uses these environment variables:

```text
SPECD_BOOTSTRAP_SCHEMA_ROOT
SPECD_BOOTSTRAP_AGENT_MANIFESTS
```

`SPECD_BOOTSTRAP_SCHEMA_ROOT` points at the packaged `schemas/sdd/` tree.
`SPECD_BOOTSTRAP_AGENT_MANIFESTS` contains a semicolon-separated list of
agent package manifest files. The Nix wrapper derives this list from the
configured agent package list by using each package's `$out/manifest.yaml`.
A caller may set this environment variable explicitly to replace the
wrapper default.

The bootstrap command performs these actions for a target project:

- materializes or updates `schemas/sdd/` in the target project from the
  schema asset package;
- creates `specd.yaml` with `specd init --schema ./schemas/sdd/schema.yaml`
  when the target project has no SpecD configuration;
- when `specd.yaml` already exists, parses it as YAML and updates the
  schema reference to `./schemas/sdd/schema.yaml` while preserving unrelated
  project configuration fields, though YAML formatting may be normalized;
- for each selected agent, reads that agent package manifest and
  materializes or updates the manifest-declared source skill payload at the
  manifest-declared destination directory;
- refuses unsupported agent targets instead of installing a different
  target's skills.

The schema asset package is sourced from the same local SDD schema tree used
by this repository's `specd.yaml`. When that repository schema changes, the
installable schema setup used by the bootstrap tool changes with it.

Agent skill packages share the same SDD workflow semantics for this
repository's schema, but each package owns the invocation syntax and
integration details required by its target agent. For example, Codex skills
install under `.codex/skills/` and use `$specd-*` invocation, while agents
that require slash invocation use their slash-style equivalents.

Reusable skill source is owned by the skill packages, not by this root
project's local `.codex/skills/` runtime directory. The root project's local
skills may be generated or installed from those packages, but they are not
the source of truth for reusable skill packaging.

The bootstrap support packages are ordinary package-set members. They MUST
NOT decide which concrete hosts install the bootstrap tool for workflow
reasons. Host installation policy remains separate from package definitions.

Traceability:

- Satisfies
  [`REQ-002: Bootstrap projects with the repository SDD setup`](requirements.md#req-002-bootstrap-projects-with-the-repository-sdd-setup).
