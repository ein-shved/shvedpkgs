# Plan: project-aware-nixos-tests

- [x] 1. Extend `testers.runNixOSTest` in `pkgs/by-name/te/testers/` and publish its `extensions` context through `pkgs/default.nix`. See [runner design][system] and [boundary validation][validation].
- [x] 2. Add focused `tests/modules/` cases, reuse `tests/pkgs/` and fix the missing `pkcs11` group in `modules/services/networking/klvpn/default.nix` found during execution. See [capability validation][validation].
- [ ] 3. Separate `modules`/`configs` and merge external checks in `lib/system.nix`; publish `tests/default.nix` through `projectTests`/`allTests`, wire `flake.nix` and confirm the final integration. See [suite design][system] and [validation approach][validation].

[system]: deltas/default/003-testing-infrastructure/system.md.delta.yaml
[validation]: deltas/default/003-testing-infrastructure/validate.md.delta.yaml
