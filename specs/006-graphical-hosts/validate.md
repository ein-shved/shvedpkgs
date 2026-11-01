# Validation: Graphical hosts

## Automated Checks

### Check: Pass setup and runtime

- Covers: [Pass integration](system.md#pass-integration),
  [GPG runtime](system.md#gpg-runtime).
- Method: Execute `projectTests.pass`. The VM checks deferred
  key import and checkout, OTP availability, independent password reads,
  repeated HM activation and explicit setup restart, then a cold boot.
- Evidence: Exit 0; the key and original repository contents are available,
  reads return the fixture password and exactly one keyboxd uses runtime
  sockets after each setup/read cycle.
- Notes: Uses guest-generated keys, a local Git repository and scripted key
  authentication. Reads wait for setup completion.

### Check: Application password persistence

- Covers: [Application storage](system.md#application-password-storage).
- Method: Execute `projectTests.keyring-storage`. The VM uses
  project desktop policy and normal tty/PAM login; `secret-tool` stores a
  password and reads it in independent processes and after a cold boot.
- Evidence: Exit 0; every lookup returns the exact saved fixture password.
- Notes: This runner does not exercise graphical or Lemurs login.
