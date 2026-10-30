{ testers }:
testers.runNixOSTest {
  name = "browser-chromium";
  nodes.machine = {
    user.name = "tester";
    home.enable = true;
    programs.chromium.enable = true;
  };
  testScript = ''
    start_all()
    machine.wait_for_unit("home-manager-tester.service")
    for application in ["firefox", "thunderbird"]:
        for name in ["cert9.db", "key4.db", "pkcs11.txt"]:
            machine.succeed(f"test /home/tester/.mozilla/{application}/tester/{name} -ef /home/tester/.pki/nssdb/{name}")
    machine.succeed("test -L /home/tester/.pki/nssdb/libnssckbi.so && test -f /home/tester/.pki/nssdb/libnssckbi.so")
  '';
}
