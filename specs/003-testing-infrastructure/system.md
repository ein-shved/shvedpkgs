# Validation Configurations

A validation configuration is a NixOS configuration used to evaluate and plan
builds for repository validation when the corresponding deployable host
configuration requires private or machine-specific values that are not present
in the public checkout.

Validation configurations MUST be separate from deployable host configurations.
They MUST NOT be exposed through `nixosConfigurations`.

The flake exposes validation configurations through:

```nix
nixosValidationConfigurations.<host>
```

Each `nixosValidationConfigurations.<host>` entry is a NixOS configuration
object for the same host as `nixosConfigurations.<host>`, evaluated with the
same base modules and host modules plus repository-owned test-only validation
stub modules.

Validation stub modules live under the repository `tests/` tree, in the
test-only module support area. The initial private-value validation stubs live
under `tests/modules/stubs/private-values/`. They provide non-secret substitute
values only for evaluation and build-planning purposes. They MUST NOT contain
real credentials, private domains, private keys, or machine-local secret
material.

Validation stub modules MAY define ordinary NixOS module options when that is
the normal interface consumed by the system. They SHOULD use existing option
interfaces instead of bypassing module ownership. For example, an age secret
substitute is provided through `age.secrets.<name>.file`, not by assigning a
computed secret `path` directly.

The initial validation stub set covers the private dependencies currently
observed to block active-host toplevel evaluation in the public checkout:

- `age.secrets.cloudflare.file`
- `age.secrets.lastfm-navidrome.file`
- `services.vps.domain`

This list is not a complete inventory of every private, secret, or
machine-specific value that may exist in the repository or in downstream
private extensions. Additional validation substitutes may be added when a
validation target exposes another missing private dependency.

The validation configuration contract guarantees that these commands can be
used for secret-dependent active hosts:

```sh
nix eval --raw .#nixosValidationConfigurations.<Hostname>.config.system.build.toplevel.drvPath
nix build --dry-run --no-link .#nixosValidationConfigurations.<Hostname>.config.system.build.toplevel
```

The corresponding deployable host output remains:

```nix
nixosConfigurations.<host>
```

and it MUST NOT import validation stub modules implicitly.

Traceability:

- Satisfies
  [`REQ-001: Validate Secret-Dependent Hosts Without Private Material`](requirements.md#req-001-validate-secret-dependent-hosts-without-private-material).
