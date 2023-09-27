{ pkgs, lib, config, ... }:
let
  programmers = [
    {
      name = "usbasp";
      vid = "16c0";
      pid = "05dc";
    }
  ];
  formUdevRule = prog: ''
    SUBSYSTEM=="usb", \
    ATTRS{idVendor}=="${prog.vid}", \
    ATTRS{idProduct}=="${prog.pid}", \
    GROUP="dialout"
  '';
  collectRules = progs:
    builtins.foldl' (all: prog: all + formUdevRule prog) "" progs;
in
{
  config = {
    services.udev.extraRules = collectRules programmers;
  };
}

