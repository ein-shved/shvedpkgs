# Project TODO

This file tracks open questions, cleanup candidates, and SDD preparation tasks.
Items here are not requirements yet; turn them into focused specs before making
behavioral changes.

## Architecture Questions

- Investigate what the `bootWork`, `bootGaming`, and `bootServer` profiles are
  for.
  - Current source: `hosts/boots/default.nix`.
  - Initial observation: they define bootable/system profiles with user
    `nixos`, hardware role flags, and optional gaming/Gerrit settings.
  - Need to clarify whether they are installer images, rescue images, generic
    boot media, or an older experiment.
- Expand and document the `generic` profile.
  - Current source: `hosts/default.nix`.
  - Initial observation: it only sets `user.name = "NixOS"` and receives all
    global modules.
  - Need to clarify whether it is a default package context, a minimal system
    profile, a nixpkgs-like compatibility target, or legacy scaffolding.
- Document how final target-machine configurations are assembled with
  `extend`.
  - Public source: `lib/system.nix`.
  - Missing context: private extensions and secrets are intentionally outside
  this repository.
  - Need to capture the user-provided deployment workflow later.
- Bring personal flake inputs into the SDD process as separate repositories.
  - Current known inputs from GitHub account `ein-shved`:
    - `vim`: `github:ein-shved/vim`
    - `niri`: `github:ein-shved/niri/view_offset`
  - Local working copies exist on this host for at least some of these
    repositories.
  - They should keep their own repository boundaries and their own specs.
  - This repository should document integration contracts, consumed modules,
    overlays, compatibility expectations, and validation points.

## Validation Strategy

- Add a formatter output to the flake.
  - `nix fmt` currently fails because the flake does not expose
    `formatter.x86_64-linux`.
  - The repository should define its canonical formatter through the flake so
    agents and contributors can format changes consistently.
- Design the correct validation commands for this repository.
  - Do not treat `nix flake show --all-systems --no-write-lock-file` failure
    as a bug by itself: the project intentionally extends nixpkgs-like package
    sets, so broad package enumeration can evaluate failing nixpkgs members.
  - Candidate targeted checks to validate later:

    ```sh
    nix eval .#nixosConfigurations.<host>.config.system.build.toplevel.drvPath
    nix build .#nixosConfigurations.<host>.config.system.build.toplevel
    nixos-rebuild build --flake .#<host>
    nixos-rebuild build-vm --flake .#testA
    ```

  - Need to decide which checks work without private secrets and which require
    target-machine private extensions.
- Define runtime validation, not only build validation.
  - For host-level changes, specs should identify how to verify that the
    resulting machine actually works.
  - Examples to consider later: service health, network reachability, desktop
    session startup, GPU acceleration, NAS media sharing, Gerrit availability,
    VPN/smart-card workflow, distributed builds.
- Define validation scope per host class.
  - Active hosts: `ShvedGaming`, `ShvedMedia`, `gerrit`.
  - Inactive hosts: `Shvedov`, `Shvedov-NB`, `ShvedLaptop`.
  - Test profiles: `testA`, `testB`, `testNas`, `testVps`.
  - Boot profiles: `bootWork`, `bootGaming`, `bootServer`.

## Layer Rule Audit

Rule summary:

- `modules/` should introduce options.
- `config/` should consume options and apply concrete configuration.
- New option definitions should not be added under `config/`.
- Pure concrete configuration should not live under `modules/` unless there is
  a deliberate module-family reason.

Known `config/` files that define options and should be audited:

- `config/bashrc/bashrc.nix`
  - Defines `programs.bash.extraCompletions`.
  - This file is currently imported from `config/nixos.nix`, so it is an active
    rule violation candidate.
- `config/desktop/hyprland/default.nix`
  - Defines `programs.hyprland.hyprconfig`.
  - Hyprland config appears inactive because `config/nixos.nix` currently
    imports Niri-related modules instead.
- `config/applications/editors/vim/default.nix`
  - Defines `programs.vim.*` options.
  - Vim config appears inactive because it is commented out in
    `config/nixos.nix`.

Known `modules/` files that appear to apply only concrete configuration and
should be audited:

- `modules/security/ca.nix`
- `modules/applications/networking/default.nix`
- `modules/os-specific/linux/keyutils/default.nix`
- `modules/hardware/power/default.nix`
- `modules/hardware/crypto/default.nix`
- `modules/hardware/bootable/default.nix`
- `modules/hardware/development/programmers/avr/default.nix`
- `modules/hardware/development/programmers/stm32/default.nix`
- `modules/applications/misc/printing3d/freecad/default.nix`

This list is heuristic. Before moving files, inspect whether each one belongs
near an option-owning module family or should become a `config/` policy module.

## Legacy Or Suspicious Areas

- Review root `default.nix`.
  - It appears to reference older layout names like `./nixos`, `local.*`,
    `gnupass`, and optional `secrets`/`nda`.
  - It does not match the current flake-oriented structure.
- Review root `config.nix`.
  - It references `./vim` and `shvedsPackages`.
  - It does not match the current active editor path through
    `config/applications/editors/nixvim`.
- Review old editor configuration.
  - `config/applications/editors/neovim` exists but is commented out in
    `config/nixos.nix`.
  - `config/applications/editors/vim` exists but is commented out in
    `config/nixos.nix`.
- Review `config/desktop/hyprland`.
  - The directory exists, but current global imports use Niri-related modules.
- Review generated NixOS comments and old host comments.
  - Host files still contain large generated comment blocks and stale comments.
- Review package bucket aggregation in `modules/hardware/hosts/default.nix`.
  - `environment.developmentPackages` is currently included when
    `hardware.needGraphic` is true, not when `hardware.development` is true.
  - `environment.vpsPackages` is currently included when `hardware.isNas` is
    true, not when `hardware.isVps` is true.
  - Need to determine whether these are intentional or bugs.

## Inactive Hosts

- Keep `Shvedov`, `Shvedov-NB`, and `ShvedLaptop` out of active-host specs
  unless a task explicitly reactivates or validates them.
- Decide later whether inactive hosts should be removed, archived, or kept as
  historical references.
