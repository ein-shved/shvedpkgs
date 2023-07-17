{ pkgs, lib, ... }:
{
  mkHmExtra = section: value:  [ { inherit section value; } ];
}
