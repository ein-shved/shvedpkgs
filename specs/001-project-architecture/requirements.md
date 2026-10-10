# Requirements

## REQ-001: Project supports multiple personal host configurations

The repository must support more than one concrete host configuration owned by
the same primary human user.

Each host may have a different purpose, hardware profile, deployment context,
and practical capability set. The project must not require every host to expose
the same user environment merely because the hosts are managed by the same
repository.

## REQ-002: User-facing behavior is scoped to the host primary user

When a requirement refers to tools, packages, or environment visible to "the
user", the repository must have a stable way to identify the primary user for
the evaluated host.

User-facing guarantees apply to that primary user on that host. They must not
implicitly require the same environment for unrelated users or for every host in
the repository.

## REQ-003: Host environments are selected by purpose and capability

The repository must let host environments differ according to the host's
intended role and physical or operational capabilities.

Packages and services needed only for a particular class of host must be
selectable without forcing that environment onto hosts where it is unnecessary,
unsupported, or outside the host's purpose.
