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

  postInstall = ''
    substituteInPlace "$out/lib/node_modules/@specd/cli/dist/index.js" \
      --replace-fail "start with /specd to enter the workflow, which routes to /specd-design, /specd-implement, /specd-verify, and other lifecycle skills" \
                     "start with \$specd to enter the workflow, which routes to \$specd-design, \$specd-implement, \$specd-verify, and other lifecycle skills"

    substituteInPlace "$out/lib/node_modules/@specd/cli/node_modules/@specd/core/dist/index.js" \
      --replace-fail 'command: "/specd-design"' 'command: "$specd-design"' \
      --replace-fail 'command: "/specd-implement"' 'command: "$specd-implement"' \
      --replace-fail 'command: "/specd-verify"' 'command: "$specd-verify"'

    substituteInPlace "$out/lib/node_modules/@specd/cli/node_modules/@specd/plugin-agent-codex/dist/index.js" \
      --replace-fail 'description: "Write or revise specd design artifacts for an active change."' \
                     'description: "Write or revise specd artifacts for an active change."'

    find "$out/lib/node_modules/@specd/cli/node_modules/@specd/skills/templates" -type f -name '*.md' \
      -exec sed -i \
        -e 's#/tmp/specd#/tmp@@SPEC_TMP@@#g' \
        -e 's#/specd#$specd#g' \
        -e 's#/tmp@@SPEC_TMP@@#/tmp/specd#g' \
        -e 's#design\.md#plan.md#g' \
        -e 's#spec\.md#requirements.md#g' \
        -e 's#design/tasks#plan/tasks#g' \
        {} +
  '';

  passthru.tests.vm = callPackage ../../../../tests/pkgs/specd.nix {
    specd = finalAttrs.finalPackage;
  };

  meta = {
    description = "CLI for the SpecD spec-driven development platform";
    homepage = "https://getspecd.dev";
    license = lib.licenses.mit;
    mainProgram = "specd";
  };
})
