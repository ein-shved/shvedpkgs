{ klcacerts, openssl, testers }:
testers.runNixOSTest {
  name = "kl-trust";
  nodes.machine.kl.trust.enable = true;
  testScript = ''
    start_all()
    machine.wait_for_unit("multi-user.target")
    machine.succeed('for cert in ${klcacerts}/*.crt; do ${openssl}/bin/openssl verify -no_check_time -partial_chain -CAfile /etc/ssl/certs/ca-bundle.crt "$cert" || exit; done')
    machine.succeed("bash -lc 'printenv CURL_CA_BUNDLE' | grep -Fx /etc/ssl/certs/ca-bundle.crt")
  '';
}
