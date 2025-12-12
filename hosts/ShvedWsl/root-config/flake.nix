{
  inputs = {
    shvedpkgs.url = "git+file:///home/shved/Projects/nix/shvedpkgs";
  };
  outputs = { shvedpkgs, ... }: shvedpkgs;
}
