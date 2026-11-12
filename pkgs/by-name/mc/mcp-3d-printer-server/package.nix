{
  buildNpmPackage,
  fetchFromGitHub,
  lib,
}:
buildNpmPackage (finalAttrs: {
  pname = "mcp-3d-printer-server";
  version = "1.2.29";

  src = fetchFromGitHub {
    owner = "DMontgomery40";
    repo = "mcp-3D-printer-server";
    rev = "99cbd5cb4d96f6108c63e446a88442d1265dc483";
    hash = "sha256-wd7oe4ZZNg6jKNYVoF3XQEgaiEhyDeOz7Ah+iYRl8xQ=";
  };
  npmDepsHash = "sha256-nVCSU5eaVOxphIuBpviwA7z1Zpqj5t4n4FVYZy32Nbo=";
  npmFlags = [ "--ignore-scripts" ];

  meta = {
    description = "MCP server for local 3D slicing and printer integrations";
    homepage = "https://github.com/DMontgomery40/mcp-3D-printer-server";
    license = lib.licenses.gpl2Only;
    mainProgram = "mcp-3d-printer-server";
  };
})
