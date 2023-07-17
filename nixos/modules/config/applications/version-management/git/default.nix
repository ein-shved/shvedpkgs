{ pkgs, lib, config, ... }:
let
  gitignore = pkgs.writeText "gitignore" ''
    .Session.vim
    compile_commands.json
    result
    .cache
    .fuse_hidden*
    cscope.out
    tags
  '';
in
{
  config = {
    home.extras = (lib.mkHmExtra "programs" {
      git = lib.mkIf (config.user.mail != null) {
        enable = true;
        lfs.enable = true;
        package = pkgs.gitFull;
        userName = config.user.humanName;
        userEmail = config.user.mail;
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
            core = {
              excludesFile = "${gitignore}";
            };
          };
        }];
      };
    });
    programs.git = {
      enable = true;
      lfs.enable = true;
    };
  };
}
