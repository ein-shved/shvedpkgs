# System Specification

## Architecture Overview

The `nixos` command is implemented as a Rust CLI crate. Like other local
packages, its code lives in `pkgs by-name`. A Nix wrapper passes the path
to a host catalog JSON file to the executable through ENV;
the external `nixos-rebuild` performs the update.
Basis: [REQ-001](requirements.md#req-001-updating-the-local-or-a-named-remote-host).

### Modules and APIs

- **`cli`**
  - Composition and responsibility: defines the utility's own arguments,
    selects the target, and separates arguments forwarded to `nixos-rebuild`.
  - API: takes invocation arguments, including the program name, and host
    names; returns the `nixos-rebuild` argument list and the selected catalog
    name, or no name for the default local target.
  - Main crate: [clap](https://docs.rs/clap/latest/clap/).
  - Basis:
    [REQ-001](requirements.md#req-001-updating-the-local-or-a-named-remote-host),
    [REQ-002](requirements.md#req-002-compatibility-with-nixos-rebuild-arguments).

- **`config`**
  - Composition and responsibility: reads the host catalog from a JSON file,
    selects access and update settings, and adds the local name.
  - API: takes the file path from ENV, loads the catalog, and adds the
    [local name](#local-name-at-runtime). Returns names for the CLI and
    completion, and optional remote host settings when resolving a target.
    An absent selected name and an added local name both resolve to no
    remote settings.
  - Main crates: [serde](https://serde.rs/) and
    [serde_json](https://docs.rs/serde_json/latest/serde_json/).
  - Basis:
    [REQ-001](requirements.md#req-001-updating-the-local-or-a-named-remote-host).

- **`deployment`**
  - Composition and responsibility: adapts target settings into a
    `nixos-rebuild` invocation and starts the process.
  - API: takes optional host settings and upstream arguments;
    absent settings mean local execution. Builds the command and hands
    control to `nixos-rebuild` by replacing the process.
    Returns a launch error on failure.
  - Dependencies: process execution uses `std::process` from the Rust standard library.
  - Basis:
    [REQ-001](requirements.md#req-001-updating-the-local-or-a-named-remote-host),
    [REQ-002](requirements.md#req-002-compatibility-with-nixos-rebuild-arguments).

- **`completion`**
  - Composition and responsibility: provides host names, completes the
    utility's own arguments, and adapts completion for `nixos-rebuild` arguments.
  - API: `complete(words, cursor, catalog) → Candidates` provides suggestions
    for the current command line position. Uses the CLI definition from `cli`
    and the catalog from `config`.
  - Main crate:
    [clap_complete](https://docs.rs/clap_complete/latest/clap_complete/)
    for the utility's own arguments; a separate adapter handles upstream.
  - Basis:
    [REQ-001](requirements.md#req-001-updating-the-local-or-a-named-remote-host),
    [REQ-002](requirements.md#req-002-compatibility-with-nixos-rebuild-arguments).

The APIs describe operations and the data they exchange. The entry point connects
the modules into two flows: command execution and completion output.

### Nix Integration

For [REQ-001](requirements.md#req-001-updating-the-local-or-a-named-remote-host),
the Nix side consists of a dedicated NixOS module, catalog generation,
a regular Rust package, and a wrapper.

The module declares the `programs.nixos-cli` options regardless of their values:

- `enable`: boolean. When enabled, the module generates the catalog
  and installs the configured package in `environment.systemPackages`.
- `remoteAddress`: nullable nonempty string, default `null`.
  A configured address publishes the current host as a remote target under
  the [catalog generation rules](#remote-catalog-generation),
  independently of `enable` and the host's role.
- `useSudo`: boolean, default `true`. Use sudo when updating the host.
- `askSudoPassword`: boolean, defaults to the target host's
  `config.security.sudo.wheelNeedsPassword`.
  Request the sudo password.

`mkExtendableSystems` adds all configurations to
`extensions.nixosConfigurations`, and the module builds the catalog from them.

#### Remote Catalog Generation

For [REQ-001](requirements.md#req-001-updating-the-local-or-a-named-remote-host),
the NixOS module publishes only hosts with a configured
`config.programs.nixos-cli.remoteAddress`.

Each selected target uses two names:

- The host's key in `nixosConfigurations`.
- `config.networking.hostName`, if it differs from the key.

User settings come from the corresponding host's configuration under the
[catalog entry contract](#env-and-target-catalog).
`programs.nixos-cli.useSudo` and `programs.nixos-cli.askSudoPassword`
map to the `use_sudo` and `ask_sudo_password` fields, respectively.
Both names publish the same settings for one target.
Key names are overlaid on hostname aliases and take precedence.
Hostname alias collisions are resolved by the standard attrset merge
provided by `nixpkgs.lib`, without a separate collision check.

#### Package and Wrapper

For [REQ-001](requirements.md#req-001-updating-the-local-or-a-named-remote-host),
the module saves the [remote catalog](#remote-catalog-generation)
as a JSON file in the Nix store and installs
`pkgs.nixos-cli.override { catalog = <path to JSON>; }`.
The package is built with `rustPlatform.buildRustPackage`; `makeWrapper`
makes `nixos-rebuild` available and sets `NIXOS_CLI_CONFIG`
to that file's path. The [Rust `config` module](#env-and-target-catalog)
reads the file when the command starts.

The package remains a regular member of the package set under the
[`pkgs` boundary](../001-project-architecture/system.md#pkgs).
Command installation policy belongs to
[Development Host Tooling](../005-development-host-tooling/system.md#development-host-tooling)
([that section's REQ-001](../005-development-host-tooling/requirements.md#req-001-development-hosts-expose-required-workflow-tools)).
Policy in `config/` selects module enablement for development hosts.
The module supports explicit enablement and disablement independently of role;
update targets are determined by the catalog.

### Main Interactions

1. The wrapper passes the file path through ENV; `config` reads the catalog
   and adds the [local name](#local-name-at-runtime). The entry point passes
   its names and argv to `cli`, then passes the selected target to `config`
   to resolve settings for `deployment`
   ([REQ-001](requirements.md#req-001-updating-the-local-or-a-named-remote-host)).
2. `deployment` applies the [execution rules](#update-execution)
   to target settings and upstream arguments, then hands control to
   `nixos-rebuild` under the [CLI contract](#cli-and-argument-forwarding)
   ([REQ-001](requirements.md#req-001-updating-the-local-or-a-named-remote-host),
   [REQ-002](requirements.md#req-002-compatibility-with-nixos-rebuild-arguments)).
3. During completion, `completion` receives command line context from the shell,
   target names from `config`, the utility's own argument definitions from `cli`,
   and upstream suggestions through the `nixos-rebuild` adapter
   ([REQ-001](requirements.md#req-001-updating-the-local-or-a-named-remote-host),
   [REQ-002](requirements.md#req-002-compatibility-with-nixos-rebuild-arguments)).

## CLI and Argument Forwarding

`clap` parses arguments using a shared CLI definition with dynamically
added host subcommands
([REQ-001](requirements.md#req-001-updating-the-local-or-a-named-remote-host),
[REQ-002](requirements.md#req-002-compatibility-with-nixos-rebuild-arguments)).

```text
nixos [<host>] [--] [<nixos-rebuild arguments>...]
```

- The first argument selects a host on an exact name match and is removed
  from upstream. Otherwise, the target is local and the argument remains
  in upstream. This rule also applies to `help`
  ([REQ-001](requirements.md#req-001-updating-the-local-or-a-named-remote-host)).
- Wrapper options apply before the first upstream argument or `--`.
  A leading `--` disables host selection and is reserved as a separator.
  Only the boundary `--` is removed; subsequent separators and options
  remain in upstream
  ([REQ-001](requirements.md#req-001-updating-the-local-or-a-named-remote-host),
  [REQ-002](requirements.md#req-002-compatibility-with-nixos-rebuild-arguments)).
- `-h`/`--help` and `-V`/`--version` are also available after the host;
  empty upstream arguments show help. After successful catalog initialization,
  including [local name](#local-name-at-runtime) handling,
  these invocations exit with code 0.
  Help reflects the available hosts and generates valid examples for them
  ([REQ-001](requirements.md#req-001-updating-the-local-or-a-named-remote-host),
  [REQ-002](requirements.md#req-002-compatibility-with-nixos-rebuild-arguments)).
- Upstream arguments retain their order, values, and OS representation.
  Explicit arguments take precedence over catalog settings
  ([REQ-002](requirements.md#req-002-compatibility-with-nixos-rebuild-arguments)).

## ENV and Target Catalog

The remote catalog is stored in a JSON file whose path is set by
`NIXOS_CLI_CONFIG`: host names are keys in the root object,
and values are settings objects for the corresponding targets
([REQ-001](requirements.md#req-001-updating-the-local-or-a-named-remote-host)).

If no path is set in ENV, the remote catalog is empty. After loading it,
the [local name is added](#local-name-at-runtime).
If the specified file is inaccessible or does not match the catalog format,
the invocation fails
([REQ-001](requirements.md#req-001-updating-the-local-or-a-named-remote-host)).

A target entry contains:

- `target_host`: required target address obtained from `remoteAddress`.
  `user`: optional connection user;
  when absent, SSH settings apply
  ([REQ-001](requirements.md#req-001-updating-the-local-or-a-named-remote-host)).
- `use_sudo`: whether sudo is needed; defaults to yes
  ([REQ-001](requirements.md#req-001-updating-the-local-or-a-named-remote-host)).
- `ask_sudo_password`: whether to request the sudo password; defaults to yes
  when the field is absent. The password itself is not stored in the catalog
  ([REQ-001](requirements.md#req-001-updating-the-local-or-a-named-remote-host)).

`nixos-rebuild` selects the source configuration for the update
([REQ-002](requirements.md#req-002-compatibility-with-nixos-rebuild-arguments)).

### Local Name at Runtime

For [REQ-001](requirements.md#req-001-updating-the-local-or-a-named-remote-host),
`config` obtains the current OS hostname after loading the remote catalog.
If that name is absent from the catalog, it adds a local entry only in process
memory. If the name already exists, its settings are preserved.
Failure to obtain the hostname causes the invocation to fail.

The local entry participates in the shared name list for the CLI, help,
and completion. Resolving it returns no remote settings for `deployment`,
as does an unspecified target name. Thus,
`nixos <current-hostname> switch` with an added local entry
uses the [local execution rules](#update-execution).
This entry is not serialized to JSON and does not create a remote `HostConfig`.

## Update Execution

- For a named remote target, `deployment` adds `--target-host` with the address
  and user from the catalog; SSH determines an unspecified user.
  A local target does not add this argument. An explicit `--target-host`
  fully replaces catalog access settings; sudo for that target is specified
  explicitly. `nixos-rebuild` handles the SSH connection
  ([REQ-001](requirements.md#req-001-updating-the-local-or-a-named-remote-host),
  [REQ-002](requirements.md#req-002-compatibility-with-nixos-rebuild-arguments)).
- Building is local by default; an explicit `--build-host` moves it elsewhere.
  The `nixos-rebuild` operation determines whether the selected target is activated
  ([REQ-002](requirements.md#req-002-compatibility-with-nixos-rebuild-arguments)).
- If `--target-host` is not specified explicitly, a local target with UID ≠ 0
  receives `--sudo`. A named remote target with sudo enabled receives
  `--ask-sudo-password` when password prompting is enabled, otherwise `--sudo`;
  when sudo is disabled, neither argument is added automatically.
  `--ask-sudo-password` already implies sudo; `nixos-rebuild` handles the prompt.
  Explicit arguments take precedence; an explicit `--sudo` preserves the selected
  password prompting mode
  ([REQ-001](requirements.md#req-001-updating-the-local-or-a-named-remote-host),
  [REQ-002](requirements.md#req-002-compatibility-with-nixos-rebuild-arguments)).
- `nixos-rebuild` and its arguments control `flake.lock` handling;
  `nixos` does not delete the file before launch
  ([REQ-002](requirements.md#req-002-compatibility-with-nixos-rebuild-arguments)).
- `deployment` replaces the current process with `nixos-rebuild`, passing
  separate arguments while preserving the environment, working directory,
  and standard streams. The upstream exit code or signal becomes the result of `nixos`
  ([REQ-002](requirements.md#req-002-compatibility-with-nixos-rebuild-arguments)).

## Completion

For
[REQ-001](requirements.md#req-001-updating-the-local-or-a-named-remote-host),
[REQ-002](requirements.md#req-002-compatibility-with-nixos-rebuild-arguments),
completion supports every shell for which the selected `nixos-rebuild`
package supplies completions: Bash and Zsh.
The package installs scripts in `share/bash-completion/completions/nixos`
and `share/zsh/site-functions/_nixos` (with `#compdef nixos`); standard
Bash completion and Zsh `compinit` load them, respectively. The scripts invoke
the installed wrapper in a dedicated ENV completion mode, passing the shell,
words, and cursor position.
This mode returns candidates without running `deployment`.

`completion` obtains current names from `config`, including the
[local name](#local-name-at-runtime), and the utility's own options from the
shared `cli` definition through `clap_complete`. In the first position,
host names, the utility's own options, and upstream operations are combined;
after host selection, host names are no longer suggested. The boundary for
the utility's own arguments follows the [CLI rules](#cli-and-argument-forwarding).

For upstream, the corresponding shell adapter loads the completion script
from the same `nixos-rebuild` package used by the wrapper and calls its
completion function. The adapter replaces the command name with `nixos-rebuild`,
removes the selected host and boundary `--`, and recalculates words and the
cursor position. Bash uses `COMP_WORDS`/`COMP_CWORD` with results in `COMPREPLY`;
Zsh uses `words`/`CURRENT` with native Zsh completion output.
Other arguments and separators are preserved; upstream handles completion
of options and their context-dependent values.
