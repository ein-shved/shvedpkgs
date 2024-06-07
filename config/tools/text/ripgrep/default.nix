{ pkgs, ... }:
{
  config = {
    environment.systemPackages = with pkgs; [
      (ripgrep.override {
        config = ''
          --type-add=cin:Config.in
          --type-add=cc:*.[chH], *.[chH].in, *.cats
        '';
      })
    ];
  };
}


