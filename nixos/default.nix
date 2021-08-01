{ pkgs, ... }:
let
    bashrc = pkgs.callPackage ./bashrc {};
in {
    imports = [
        ./user.nix
        ./desktop.nix
        ./packages.nix
        ./services.nix
        ./../kl
    ];
    config = {
        networking.hostName = "ShvedKLRemote";
        environment.etc = {
            inputrc = {
                text = ''
                    "\e[A": history-search-backward
                    "\e[B": history-search-forward

                    set bell-style none
                    set colored-stats On
                    set completion-ignore-case On
                    set completion-prefix-display-length 3
                    set mark-symlinked-directories On
                    set show-all-if-ambiguous On
                    set show-all-if-unmodified On
                    set visible-stats On
                '';
                mode = "0644";
            };
            "bashrc" = {
                source = bashrc;
                mode = "0755";
            };
        };
    };
}
