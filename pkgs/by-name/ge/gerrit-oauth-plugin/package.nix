{
  fetchurl,
  runCommand,
}:
runCommand "oauth.jar"
  {
    src = fetchurl {
      url = "https://gerrit-ci.gerritforge.com/job/plugin-oauth-bazel-master-stable-3.13/lastSuccessfulBuild/artifact/bazel-bin/plugins/oauth/oauth.jar";
      hash = "sha256-mGG5I79AcucjHthmIVcJ+VdRfwMDdlKCQI0/R9p/b6k=";
    };
  }
  ''
    ln -s $src $out
  ''
