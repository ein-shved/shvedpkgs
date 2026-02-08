{
  runCommand,
  fetchurl,
}:
runCommand "gerrit-commit-msg-hook"
  rec {
    version = "3.13.1";
    src = fetchurl {
      url = "https://raw.githubusercontent.com/GerritCodeReview/gerrit/refs/tags/v${version}/resources/com/google/gerrit/server/tools/root/hooks/commit-msg";
      hash = "sha256-a6rL37WSDeILCIyLEIyhZdQT2SW4zfiyEa64oA0iQlI=";
    };
    meta.mainProgram = "gerrit-commit-msg-hook";
  }
  ''
    install -D $src $out/bin/gerrit-commit-msg-hook
    patchShebangs $out/bin/
  ''
