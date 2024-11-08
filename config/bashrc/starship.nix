{ ... }:
{
  config.programs.starship = {
    enable = true;
    settings = {
      shlvl = {
        disabled = false;
        format = "[$shlvl]($style) ";
      };
      git_status = {
        format = "([$ahead_behind]($style) )";
        ahead = ">";
        behind = "<";
        diverged = "<>";
        up_to_date = "=";
      };
    };
  };
}
