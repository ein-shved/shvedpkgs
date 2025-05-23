{
  python3Packages,
}:
python3Packages.buildPythonApplication {
  name = "klvpn_cert_chooser";
  src = ./src;
}
