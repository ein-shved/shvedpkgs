let
  pkgs = import <nixpkgs> {};
in pkgs.mkShell {
  buildInputs = with pkgs; with pkgs.python3Packages; [
    pkgs.python3
    pkgs.python3Packages.requests
    pkgs.python3Packages.wheel
    setuptools
    wxPython_4_1
    cffi
    numpy
    weasyprint
    #<--pypackages-->
  ];
  shellHook = ''
    # Tells pip to put packages into $PIP_PREFIX instead of the usual locations.
    # See https://pip.pypa.io/en/stable/user_guide/#environment-variables.
    export PIP_PREFIX=$(pwd)/_build/pip_packages
    export PYTHONPATH="$PIP_PREFIX/${pkgs.python3.sitePackages}:$PYTHONPATH"
    export PATH="$PIP_PREFIX/bin:$PATH"
    unset SOURCE_DATE_EPOCH
  '';
}
