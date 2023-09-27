{ pkgs, nvchad, ... }:
{
  imports = nvchad.modules;
  config = {
    programs.neovim = {
      viAlias = true;
      vimAlias = true;
      defaultEditor = true;
      nvchad = {
        enable = true;
        custom = ./custom;
        runtimeInputs = with pkgs; [
          ctags
          cscope
          clang-tools
          rnix-lsp
          nixpkgs-fmt
          lua-language-server
          stylua
          # TODO(Shvedov) use neocmakelsp after 23.11
          #neocmakelsp
          cmake-language-server
          nodePackages.bash-language-server
          shfmt
          shellcheck
        ];
        # TODO (Shvedov) Then nix-develop.nvim package does not affects the
        # environment of lspconfig module. So apply devshell automatically on
        # startup. Remove this upon fixing the nix-develop.nvim and lspconfig
        # co-existance.
        # TODO (Shvedov) UPD. This leads to unexpected behaviour. Run devshell
        # manually for awhile.
        #extraMakeWrapperArgs =
        #  let
        #    loadDevshell = pkgs.writeShellScript "loadDevshell" ''
        #      nix print-dev-env 2>/dev/null || echo -n
        #    '';
        #  in
        #  ''--run 'eval "$(${loadDevshell})"' '';
      };
    };
    environment.systemPackages = with pkgs; [
      neovide
    ];
  };
}
