{
  fetchurl,
  runCommand,
}:
runCommand "oauth.jar"
  {
    src = fetchurl {
      url = "https://gerrit-ci.gerritforge.com/view/Plugins-stable-3.13/job/plugin-oauth-bazel-master-stable-3.13/4/artifact/bazel-bin/plugins/oauth/oauth.jar";
      hash = "sha256-SopXmT8zN3JBUtcxWq3EqIzuTP1QxxF7Ed0boFGT5Uw=";
    };
  }
  ''
    ln -s $src $out
  ''
