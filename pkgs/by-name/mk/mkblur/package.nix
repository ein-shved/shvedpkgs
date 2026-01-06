{
  runCommand,
  imagemagick,
}:
{
  src,
  name ? "blur-${blur}-${builtins.baseNameOf src}",
  blur ? "0x5",
}:
runCommand name
  {
    buildInputs = [ imagemagick ];
  }
  ''
    convert ${src} -blur ${toString blur} $out
  ''
