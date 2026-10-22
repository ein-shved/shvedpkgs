# Validation: Project Architecture

## Scope

Coverage: [primary user](system.md#primary-user),
[Home Manager integration](system.md#primary-user-home-manager-integration),
[user/HM consumer optionality](system.md#modules), and
[public package access](system.md#public-package-interface).
Other architecture contracts and module families remain outside this coverage.
Run commands from the repository root on `x86_64-linux`. Package checks evaluate
`generic` or build its exported packages; its system, VM and images are excluded.

## Automated Checks

### Primary user, Home Manager and host regression

- Covers: [REQ-002](requirements.md#req-002-hosts-select-a-primary-user-for-user-facing-behavior),
  [REQ-006](requirements.md#req-006-reusable-modules-are-optional-and-disabled-by-default).
- Method:

```sh
bash tests/modules/primary-user-hm.sh
```

Cases:

- Account selection and lazy missing-login defaults; identity and metadata
  overrides on different hosts; default groups, extra groups and secondary
  account independence.
- Home default-off, explicit disable and enabled states; missing-login
  assertion, account-derived identity, state-version defaults and overrides.
- Alias attribute, function and imported definitions; direct-only input,
  merging, priorities, list order, activation and diagnostic source files.
- Inactive declarations with and without a login; lazy values and module
  bodies, deferred type validation, nested conditions, rejected alias reads,
  independent HM users and available `lib.hm` helpers.
- Consumer declarations and actual system dependencies: browser/NSS,
  certificates, pass, printing, graphical tools, KL/VPN, media and account
  metadata. Disabled dependencies stay unused; enabled missing dependencies
  fail; independent system functionality remains available. Hyprland and
  wpaperd are fixture coverage, not supported deployment claims.
- Transmission default selection, explicit disable, account-only enable,
  missing-login errors, directory setup and managed-home activation ordering.
- Profile refresh default-off, explicit disable, step ordering and script
  generation; inactive refresh remains lazy.
- Account/HM snapshots, toplevel evaluation and build planning for
  `ShvedGaming`, `ShvedMedia`, `gerrit`, `testA`, `testB`, `testNas` and `testVps`.

- Evidence: The runner exits zero only when its assertions and expected-error
  checks pass. Fixtures use locked inputs, actual modules and the real HM type;
  case details are owned by
  [primary-user-hm.nix](../../tests/modules/primary-user-hm.nix) and
  [primary-user-hm-hosts.nix](../../tests/modules/primary-user-hm-hosts.nix).
- Notes: Private-value substitutes are confined to
  [validation configurations](../003-testing-infrastructure/system.md).

## Manual Checks

### Profile refresh guard and execution

- Covers: [profile refresh](system.md#module-boundary-and-enablement).
- Method: Inspect `refresh-enabled.sh` in the evidence directory printed by
  the runner. Check the condition surrounding `nix profile add/remove`.
  When activation logic changes, also render and execute the refresh step for
  a disposable home/profile, first without `manifest.json`, then with an
  existing initialized profile. The generated profile directory and Nix
  command destination must both refer to that disposable profile.
- Evidence: Both commands are guarded by the absence of `manifest.json`.
  Runtime execution initializes a missing profile and removes the temporary
  package; an existing profile's manifest and contents remain unchanged.

### Default package paths work

- Covers: [REQ-004](requirements.md#req-004-obtain-host-available-packages-with-a-simple-command),
  [command interface](system.md#command-interface).
- Method:

```sh
nix build --no-link --no-write-lock-file .#hello .#pkgsUnstable.hello
nix run --no-write-lock-file .#hello
nix run --no-write-lock-file .#pkgsUnstable.hello
```

- Evidence: Both builds succeed; both runs print the hello greeting.

### Package namespaces preserve the selected package set

- Covers: [host namespaces](system.md#host-package-namespaces),
  [default aliases](system.md#default-host-aliases),
  [unstable source](system.md#nixpkgs-unstable).
- Method: Run `nix eval --raw --no-write-lock-file <path>.drvPath` for each path
  below and compare the returned derivation paths within each row.

| Path | Compare with |
| --- | --- |
| `.#hello` | `.#generic.hello` |
| `.#pkgsUnstable.hello` | `.#generic.pkgsUnstable.hello` |
| `.#generic.pkgsUnstable.hello` | `.#nixosConfigurations.generic.pkgs.pkgsUnstable.hello` |
| `.#ShvedGaming.hello` | `.#nixosConfigurations.ShvedGaming.pkgs.hello` |
| `.#ShvedGaming.pkgsUnstable.hello` | `.#nixosConfigurations.ShvedGaming.pkgs.pkgsUnstable.hello` |

- Evidence: Each pair is equal. Stable and unstable packages need not differ
  from each other.

### Host overrides and default-host selection

- Covers: [default aliases](system.md#default-host-aliases),
  [output construction](system.md#output-construction).
- Method: Evaluate a temporary host with a distinct `hello` derivation:

```sh
nix eval --impure --json --expr '
let
  f = builtins.getFlake (toString ./.);
  e = f.extend {
    defaultHost = "packageProbe";
    hosts.packageProbe.modules = [{
      nixpkgs.overlays = [ (_: prev: {
        hello = prev.hello.overrideAttrs (_: { pname = "hello-package-probe"; });
      }) ];
    }];
  };
  p = e.packages.x86_64-linux;
  h = e.nixosConfigurations.packageProbe.pkgs;
in {
  named = p.packageProbe.hello.drvPath == h.hello.drvPath;
  default = p.hello.drvPath == h.hello.drvPath;
  distinct = p.hello.drvPath != p.generic.hello.drvPath;
  namedUnstable = p.packageProbe.pkgsUnstable.hello.drvPath == h.pkgsUnstable.hello.drvPath;
  defaultUnstable = p.pkgsUnstable.hello.drvPath == h.pkgsUnstable.hello.drvPath;
  generic = p.generic.hello.drvPath == f.packages.x86_64-linux.generic.hello.drvPath;
}'
```

- Evidence: All six JSON values are `true`. This evaluates packages only.

### Source wiring and host policy

- Covers: [primary user](system.md#primary-user),
  [output construction](system.md#output-construction),
  [consumer and host policy](system.md#consumers-and-repository-policy),
  [validation isolation](../003-testing-infrastructure/system.md).
- Method: Inspect `flake.nix`, `pkgs/default.nix`, `hosts/default.nix`, its named
  host and boot/test profile definitions, and the `modules/` and `config/`
  consumers of `hm`, `config.hm` and `config.user.*`. Compare the runner's
  `hosts.json` with the account/HM settings selected by each host/profile's
  policy, including independent secondary accounts.
- Evidence:
  - The unstable input is imported for the selected system and passed through
    `pkgsUnstable`; the overlay exports that same set.
  - Named hosts and boot/test profiles select home integration individually
    and keep shared user defaults separate.
    `generic` selects it in its inline definition. Include inactive profiles
    in this inspection without treating them as supported build targets.
  - Primary login, account fields, groups and HM state version match the owning
    host/profile policy; independent secondary accounts retain their configured
    settings.
  - HM availability alone requires no consumer wrapper. Actual system reads
    follow feature enablement; consumers add no dependency assertions. Mixed
    modules preserve independent system behavior.
  - Private-value substitutes enter through validation outputs only.
