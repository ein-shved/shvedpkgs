{
  lib,
  callPackage,
  linkFarmFromDrvs,
}:
let
  cases = [
    ./modules/project-arguments.nix
    ./modules/codex-service.nix
    ./modules/cifs-keyutils.nix
    ./modules/avr.nix
    ./modules/stm32.nix
    ./modules/power-wakeup.nix
    ./modules/drive-standby.nix
    ./modules/home-manager.nix
    ./modules/home-manager-declarations.nix
    ./modules/home-manager-merge.nix
    ./modules/home-manager-force.nix
    ./modules/home-manager-default.nix
    ./modules/home-manager-inactive.nix
    ./modules/home-manager-independent.nix
    ./modules/home-manager-independent-primary.nix
    ./modules/home-manager-refresh.nix
    ./modules/primary-user-defaults.nix
    ./modules/primary-user-customization.nix
    ./modules/git-identity.nix
    ./modules/ssh-config.nix
    ./modules/kitty-config.nix
    ./modules/top-config.nix
    ./modules/pass.nix
    ./modules/kl-trust.nix
    ./modules/kl-nss-certificates.nix
    ./modules/browser-firefox.nix
    ./modules/browser-chromium.nix
    ./modules/gaming.nix
    ./modules/gaming-steam-disabled.nix
    ./modules/cntlm.nix
    ./modules/klvpn.nix
    ./modules/printing3d.nix
    ./modules/transmission.nix
    ./modules/transmission-disabled.nix
    ./pkgs/specd.nix
    ./pkgs/specd-bootstrap.nix
  ];
  tests = builtins.listToAttrs (
    map (file: {
      name = lib.removeSuffix ".nix" (builtins.baseNameOf file);
      value = callPackage file { };
    }) cases
  );
in
tests
// {
  allTests = linkFarmFromDrvs "all-tests" (builtins.attrValues tests);
}
