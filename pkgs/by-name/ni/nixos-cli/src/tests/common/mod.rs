use std::process::Command;

pub fn hostname() -> String {
    let output = Command::new("uname").arg("-n").output().unwrap();
    assert!(output.status.success());
    String::from_utf8(output.stdout)
        .unwrap()
        .trim_end_matches('\n')
        .to_owned()
}
