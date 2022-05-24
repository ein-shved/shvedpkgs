{ config, pkgs, lib, ... }:
{
  config = {
    local.extras = (pkgs.mkLocalExtra "programs" {
      git = lib.mkIf (config.local.user.mail != null) {
        enable = true;
        lfs.enable = true;
        package = pkgs.gitFull;
        userName = config.local.user.name;
        userEmail = config.local.user.mail;
        includes = [{
          contents = {
            pull = {
              rebase = true;
            };
            fetch = {
              prune = true;
            };
            diff = {
              colorMoved = "zebra";
            };
            http = {
              version = "HTTP/1.1";
            };
          };
        }];
      };
    });
    programs.git = {
      enable = true;
      lfs.enable = true;
    };
    environment.systemPackages = [
      pkgs.git-review
    ];
  };
}
