{ config, ... }:
{
  config.programs.starship = {
    enable = config.hardware.isGraphic;
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
      python = {
        format = "[\${symbol}]($style)";
        symbol = "";
      };
      cmake = {
        format = "[$symbol]($style)";
      };
    };
  };
}
