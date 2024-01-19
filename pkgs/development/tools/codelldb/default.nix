{ lib, ... }:
lib.mkOverlay (
  { linkFarm, vscode-extensions, ... }:
  {
    codelldb = linkFarm "codelldb" [{
      name = "bin/codelldb";
      path = "${vscode-extensions.vadimcn.vscode-lldb}/share/vscode/extensions/vadimcn.vscode-lldb/adapter/codelldb";
    }];
  }
)

