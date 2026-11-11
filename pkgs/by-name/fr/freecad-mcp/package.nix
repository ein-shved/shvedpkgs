{
  fetchFromGitHub,
  lib,
  pkgsUnstable,
  runCommand,
}:
let
  ps = pkgsUnstable.python3Packages;

in
ps.buildPythonApplication (finalAttrs: {
  pname = "freecad-mcp";
  version = "0.1.30";
  pyproject = true;

  src = fetchFromGitHub {
    owner = "neka-nat";
    repo = "freecad-mcp";
    rev = "ec8abf21fb9e9ed4bbcbba497515e088423ad251";
    hash = "sha256-PkRT0avZ9Wh2dEUN5+YAfp0I5eI8cfEpcEjv94YQu7U=";
  };

  patches = [
    ./auto-start.patch
    ./test-pythonpath.patch
  ];

  # Local stdio does not use SDK JWT authentication; Nix certifi uses system CAs.
  pythonRelaxDeps = [
    "pyjwt"
    "certifi"
  ];

  build-system = [ ps.hatchling ];
  dependencies = [
    ps.anyio
    ps.certifi
    ps.mcp
    ps.pyjwt
    ps.validators
  ]
  ++ ps.mcp.optional-dependencies.cli;

  postInstall = ''
    mkdir -p "$out/share/freecad/Mod"
    cp -r addon/FreeCADMCP "$out/share/freecad/Mod/FreeCADMCP"
  '';

  nativeCheckInputs = [
    ps.pytestCheckHook
    pkgsUnstable.writableTmpDirAsHomeHook
  ];
  pythonImportsCheck = [ "freecad_mcp.server" ];
  preCheck = ''
    python -c 'import importlib.metadata as m; print({name: m.version(name) for name in ["mcp", "anyio", "PyJWT", "certifi"]})'
  '';

  passthru.addon = runCommand "freecad-mcp-addon-${finalAttrs.version}" { } ''
    ln -s ${finalAttrs.finalPackage}/share/freecad/Mod/FreeCADMCP "$out"
  '';

  meta = {
    description = "MCP server and FreeCAD addon for local CAD modeling";
    homepage = "https://github.com/neka-nat/freecad-mcp";
    license = lib.licenses.mit;
    mainProgram = "freecad-mcp";
  };
})
