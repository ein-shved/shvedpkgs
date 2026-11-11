{
  config,
  lib,
  pkgsUnstable,
  ...
}:
{
  services.codex = lib.mkMerge [
    {
      settings = {
        model_reasoning_effort = "xhigh";
        tui.vim_mode_default = true;
        tui.status_line = [
          "thread-name"
          "project-name"
          "git-branch"
          "five-hour-limit"
          "weekly-limit"
          "used-tokens"
          "model-with-reasoning"
        ];
      };
    }
    (lib.mkIf config.hardware.isDevelopment {
      enable = true;
      remoteControl.enable = true;
      user = config.user.name;
      package = pkgsUnstable.codex;
    })
  ];
}
