# Modeling through Codex

Hosts with `environment.printing3d.enable` and `services.codex.enable` receive
the packaged `freecad-mcp` server, FreeCAD addon and shared Codex connection.

1. Open FreeCAD normally. Its local bridge starts automatically.
2. Start a new Codex session and ask it to create or edit a model in FreeCAD.
3. Use `/mcp` in Codex to inspect the connection if needed.

The bridge connects through `127.0.0.1:9875`. Nix enables auto-start at each
FreeCAD launch while preserving other addon settings and FreeCAD preferences.
Closing FreeCAD leaves Codex available; modeling resumes after reopening it.

User Codex configuration retains precedence. To disable this MCP connection:

```toml
[mcp_servers.freecad]
enabled = false
```
