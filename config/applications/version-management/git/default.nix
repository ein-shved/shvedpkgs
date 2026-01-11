{
  pkgs,
  lib,
  config,
  ...
}:
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
    home.programs.git = {
      enable = true;
      lfs.enable = true;
      package = pkgs.gitFull;
      settings.user.name = lib.mkIf (config.user.humanName != null) config.user.humanName;
      settings.user.email = lib.mkIf (config.user.mail != null) config.user.mail;
      includes = [
        {
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
            alias = {
              lg = "log --color --graph --pretty=format:'%Cred%h%Creset -%C(yellow)%d%Creset %s %Cgreen(%cr) %C(bold blue)<%an>%Creset' --abbrev-commit";
              autosquash = "!git autofixup && git rebase --autosquash";
            };
          };
        }
      ];
    };
    environment.systemPackages = with pkgs; [
      gitaliases
      git-review
      git-autofixup

      libclang.python # For git format-patch
      clang-tools
    ];
  };
}
