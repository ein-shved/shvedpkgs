# System Specification

## Pass integration

Reference: [REQ-001](requirements.md#req-001-full-access-to-pass).

The pass module owns `programs.pass`. Enabling it installs upstream pass with
pass-otp and enables the NixOS GnuPG agent. Package and agent integration work
without graphical services or Home Manager. Host policy selects this feature.

Private host configuration supplies these optional inputs:

- `programs.pass.gpgid`: package containing `gpg.id`. Setup identifies the key
  by its machine-readable fingerprint and imports it if the secret key is
  absent.
- `programs.pass.giturl`: password repository URL. With both inputs, setup
  clones it into the user's pass store, following the repository's default
  branch. An existing Git-backed store is retained.

Key import precedes repository preparation. A missing input skips its dependent
setup. Private setup applies with active [primary Home Manager integration](../001-project-architecture/system.md#primary-user-home-manager-integration)
and uses the [primary account](../001-project-architecture/system.md#primary-user). Its execution belongs to
[GPG runtime](#gpg-runtime).

## GPG runtime

Reference: [REQ-001](requirements.md#req-001-full-access-to-pass).

The pass module declares `pass-setup.service` in the primary user's HM
environment. This user oneshot is wanted by `default.target` and ordered after
`sockets.target`. HM activation installs the unit; the user manager runs private
setup in its runtime environment. Successful completion marks setup ready and
keeps the unit active with `RemainAfterExit=yes`. HM's normal service reload
applies changed setup commands during an existing session. Setup and later pass
commands share the user's runtime socket directory.

This avoids a pre-login keyboxd retaining the database lock while later clients
use a different socket.

## Application password storage

Reference:
[REQ-002](requirements.md#req-002-persistent-password-storage-for-applications).

For the [graphical role](../002-host-classification/system.md#host-role-flags), desktop policy enables
`services.gnome.gnome-keyring.enable`. The login and configured Lemurs PAM
services enable `pam_gnome_keyring` startup and unlocking. Automatic unlock
requires matching account and keyring passwords.

## Browser password policy

Reference:
[REQ-002](requirements.md#req-002-persistent-password-storage-for-applications).

Graphical host browser policy selects Brave and sets the managed
`PasswordManagerEnabled = false` policy for Brave, Chromium and Google Chrome.
Additional browser configurations must supply an equivalent managed policy
disabling built-in website password saving.

## FreeCAD MCP bridge

`environment.printing3d.enable` installs the customized FreeCAD GUI.
[Joint selection](../005-development-host-tooling/system.md#freecad-connection)
adds its MCP bridge for
[REQ-004](../005-development-host-tooling/requirements.md#req-004-use-3d-modeling-and-printing-tools-through-codex).

### Delivery

- The normal by-name package `pkgs.freecad-mcp` supplies the server and
  addon from one pinned `neka-nat/freecad-mcp` revision. Its patch phase
  configures addon startup.
- `pkgs.freecad-mcp.addon` is a small derivation linking its root to the
  package's `share/freecad/Mod/FreeCADMCP`. Joint selection supplies this
  field through `freecad-wayland.customize.modules`.
- The server uses its own Python environment; no runtime download is needed.

### Startup

- The packaged addon sets `auto_start_rpc = true` using upstream
  `load_settings` / `save_settings` before the upstream autostart callback
  on each GUI launch.
- Settings use `FreeCAD.getUserAppDataDir()/freecad_mcp_settings.json`.
  Other fields and writable user preferences are preserved.
- FreeCAD loads `InitGui.py` at startup, so the first normal GUI launch
  starts the bridge without workbench selection. Its default listener
  is loopback port 9875.
