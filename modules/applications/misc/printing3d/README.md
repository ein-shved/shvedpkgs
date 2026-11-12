# Slicing through Codex

Hosts with `environment.printing3d.enable` and `services.codex.enable` receive
the packaged `mcp-3d-printer-server` and the `prusaslicer` Codex MCP connection.
Codex starts the server over stdio and uses the installed PrusaSlicer CLI.

Export a complete configuration from PrusaSlicer with **File → Export → Export
Config**. Ask Codex to call `slice_stl` with the absolute local `stl_path` and
the exported INI as `slicer_profile`. The result includes the generated local
G-code path. Slicing needs neither a running GUI nor printer credentials.
The existing `prusaConfig` option populates GUI configuration; export a combined
INI for the CLI rather than passing that configuration directory.

The upstream server also offers printer tools. A printer connection is separate
from this local slicing setup and requires its own connection settings.

User Codex configuration takes precedence over system defaults. To disable:

```toml
[mcp_servers.prusaslicer]
enabled = false
```

For modeling in FreeCAD, see [Modeling through Codex](freecad/README.md).
