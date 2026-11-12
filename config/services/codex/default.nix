{
  config,
  lib,
  pkgs,
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
    (lib.mkIf (config.services.codex.enable && config.environment.printing3d.enable) {
      settings.mcp_servers.freecad = {
        command = lib.mkDefault (lib.getExe pkgs.freecad-mcp);
        args = lib.mkDefault [
          "--host"
          "127.0.0.1"
        ];
      };
      settings.mcp_servers.prusaslicer = {
        command = lib.mkDefault (lib.getExe pkgs.mcp-3d-printer-server);
        env = {
          MCP_TRANSPORT = lib.mkDefault "stdio";
          SLICER_TYPE = lib.mkDefault "prusaslicer";
          SLICER_PATH = lib.mkDefault (lib.getExe' pkgs.prusa-slicer "prusa-slicer");
        };
      };
    })
    (lib.mkIf config.hardware.isDevelopment {
      enable = true;
      remoteControl.enable = true;
      user = config.user.name;
      package = pkgs.codex;
    })
  ];
}
