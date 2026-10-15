# Validation: Project Architecture

## Artifact Status

TBD: technical validation of the remaining project architecture is still
being developed. The checks below cover only `REQ-004` and its package
access contracts; they do not validate the whole system specification.

## Validation: Public Package Access

Covers `REQ-004` and the Public Package Interface, Nixpkgs unstable,
and generic package-export host contracts. Checks use targeted package
evaluation, builds, and execution on `x86_64-linux`. They do not build
or boot `generic` as a system or enumerate all nixpkgs attributes.

### Check: Default package paths work

Covers "Obtain a package by name" and "Packages from different sources
are accessible". Run:

```sh
nix build --no-link --no-write-lock-file .#hello .#pkgsUnstable.hello
nix run --no-write-lock-file .#hello
nix run --no-write-lock-file .#pkgsUnstable.hello
```

Both builds succeed and both runs print the hello greeting. No host
configuration or user-written expression is needed for these commands.

### Check: Exported unstable packages match the supplied source

Covers the unstable source and overlay contracts. Inspect
`pkgs/default.nix`: its overlay captures the `pkgsUnstable` module
argument through `inherit pkgsUnstable`. Inspect `flake.nix` to confirm
that this argument imports the locked unstable input for the selected
system. Confirm `flake.lock` is unchanged by the implementation.

Evaluate `hello.drvPath` through these three paths using
`nix eval --raw --no-write-lock-file`:

```text
.#pkgsUnstable.hello.drvPath
.#generic.pkgsUnstable.hello.drvPath
.#nixosConfigurations.generic.pkgs.pkgsUnstable.hello.drvPath
```

All three return the same derivation path. Also compare
`.#hello.drvPath` with `.#generic.hello.drvPath` to verify the existing
default alias. Stable and unstable packages need not have different
versions or derivation paths from one another.

### Check: Named host paths preserve its packages

Covers "Select a host-specific package variant". Compare the derivation
paths at `.#ShvedGaming.hello.drvPath` and
`.#nixosConfigurations.ShvedGaming.pkgs.hello.drvPath`; repeat for
`pkgsUnstable.hello`. Each public path must equal its host package path.

To distinguish correct host selection from all paths accidentally
returning the same package, use a temporary evaluation fixture through
`extend`: add a host with an overlay that gives `hello` a distinct
derivation, and select it as `defaultHost`. Assert its named and default
paths equal that host's `pkgs.hello.drvPath`, differ from the base
generic package, and that the base generic namespace remains available.
Also assert the new host's named and default unstable paths match its
`pkgs.pkgsUnstable.hello.drvPath`. This fixture only evaluates packages;
it does not build a system or modify a deployable host configuration.
