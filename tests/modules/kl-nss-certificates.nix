{ klcacerts, nss, testers }:
testers.runNixOSTest {
  name = "kl-nss-certificates";
  nodes.machine = {
    user.name = "tester";
    home.enable = true;
    kl.nss.certificates.enable = true;
  };
  testScript = ''
    start_all()
    machine.wait_for_unit("home-manager-tester.service")
    machine.succeed("su - tester -c 'for cert in ${klcacerts}/*.crt; do name=$(basename \"$cert\" .crt); ${nss.tools}/bin/certutil -L -d sql:$HOME/.pki/nssdb -n \"$name\" || exit; done'")
    machine.succeed("stat -c %U /home/tester/.pki/nssdb/cert9.db | grep -Fx tester")
  '';
}
