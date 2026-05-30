{
  fetchurl,
  runCommand,
}:
runCommand "oauth.jar"
  {
    src = fetchurl {
      url = "https://gerrit-ci.gerritforge.com/job/plugin-oauth-bazel-stable-3.14/3/artifact/bazel-bin/plugins/oauth/oauth.jar";
      hash = "sha256-Kc59bxE7gsy93RR+g8DD4iezFa412KO8tV14tDqkU+8=";
    };
  }
  ''
    ln -s $src $out
  ''
