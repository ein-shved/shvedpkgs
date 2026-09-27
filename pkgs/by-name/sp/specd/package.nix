{
  buildNpmPackage,
  callPackage,
  fetchurl,
  importNpmLock,
  lib,
  nodejs,
}:

(buildNpmPackage.override { inherit nodejs; }) (finalAttrs: {
  pname = "specd";
  version = "0.2.0";

  src = fetchurl {
    url = "https://registry.npmjs.org/@specd/cli/-/cli-${finalAttrs.version}.tgz";
    hash = "sha256-8ZzR2mj2XEbZ3RLCVbwCeirItFo+GY0BZs9nFuOWerc=";
  };

  npmDeps = importNpmLock {
    npmRoot = ./.;
    packageLock = lib.importJSON ./package-lock.json;
  };
  npmConfigHook = importNpmLock.npmConfigHook;

  dontNpmBuild = true;

  meta = {
    description = "CLI for the SpecD spec-driven development platform";
    homepage = "https://getspecd.dev";
    license = lib.licenses.mit;
    mainProgram = "specd";
  };
})
