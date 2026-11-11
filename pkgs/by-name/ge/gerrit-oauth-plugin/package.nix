{
  fetchurl,
  runCommand,
}:
runCommand "oauth.jar"
  {
    src = fetchurl {
      url = "https://gerrit-ci.gerritforge.com/job/plugin-oauth-bazel-stable-3.14/1/artifact/bazel-bin/plugins/oauth/oauth.jar";
      hash = "sha256-R6IahUTXS294nnxXB1WI4gREg5sqUn6sahtKfvaNfZI=";
    };
  }
  ''
    ln -s $src $out
  ''
