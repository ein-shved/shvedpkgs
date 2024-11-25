{ ... }:
{
  imports = [
    #   Disable vim as it not used
    #    ./vim
    #   Disable self-written neovim configuration as it not used
    #    ./neovim
    ./nixvim
  ];
}
