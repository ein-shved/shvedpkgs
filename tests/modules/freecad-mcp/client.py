"""Exercise the installed server over its real JSON-lines MCP transport."""

import json
import os
from pathlib import Path
import select
import subprocess
import sys
import time


class Client:
    def __init__(self, command):
        self.log = open("mcp-server.log", "ab")
        self.child = subprocess.Popen(
            command, stdin=subprocess.PIPE, stdout=subprocess.PIPE, stderr=self.log
        )
        self.buffer = bytearray()
        self.identifier = 0

    def send(self, value):
        self.child.stdin.write(json.dumps(value).encode() + b"\n")
        self.child.stdin.flush()

    def request(self, method, params):
        self.identifier += 1
        identifier = self.identifier
        self.send({"jsonrpc": "2.0", "id": identifier, "method": method, "params": params})
        deadline = time.monotonic() + 90
        while True:
            while b"\n" not in self.buffer:
                remaining = deadline - time.monotonic()
                assert remaining > 0 and select.select(
                    [self.child.stdout], [], [], remaining
                )[0], f"MCP timeout: {method}"
                chunk = os.read(self.child.stdout.fileno(), 65536)
                assert chunk, f"MCP server exited: {self.child.poll()}"
                self.buffer.extend(chunk)
            line, _, rest = self.buffer.partition(b"\n")
            self.buffer[:] = rest
            # Every stdout line must be protocol JSON, including during startup.
            reply = json.loads(line)
            if reply.get("id") == identifier:
                assert "error" not in reply, reply
                return reply["result"]

    def tool(self, tool_name, **arguments):
        result = self.request("tools/call", {"name": tool_name, "arguments": arguments})
        assert not result.get("isError"), result
        return "\n".join(item["text"] for item in result["content"] if item["type"] == "text")

    def close(self):
        self.child.terminate()
        try:
            self.child.wait(timeout=10)
        except subprocess.TimeoutExpired:
            self.child.kill()
            self.child.wait()
        self.log.close()


mode, command = sys.argv[1], sys.argv[2:]
client = Client(command)
try:
    client.request("initialize", {
        "protocolVersion": "2025-03-26", "capabilities": {},
        "clientInfo": {"name": "freecad-mcp-integration", "version": "1"},
    })
    client.send({"jsonrpc": "2.0", "method": "notifications/initialized"})
    tools = {tool["name"] for tool in client.request("tools/list", {})["tools"]}
    assert {"list_documents", "get_rpc_status"} <= tools
    if mode in {"closed", "lifecycle"}:
        unavailable = client.request("tools/call", {"name": "list_documents", "arguments": {}})
        assert unavailable.get("isError"), unavailable
        if mode == "closed":
            print(json.dumps({"closed_gui": True, "tools": sorted(tools)}))
            sys.exit(0)
        Path("closed-ready").touch()
        deadline = time.monotonic() + 180
        while not Path("gui-ready").exists():
            assert time.monotonic() < deadline, "GUI did not become ready"
            time.sleep(0.25)

    documents = json.loads(client.tool("list_documents"))
    assert documents == [], documents
    status = json.loads(client.tool("get_rpc_status"))
    assert status["success"] and status["rpc_server"] == "running", status
    result = {"connected": True, "documents": documents,
              "addon_version": status["addon_version"], "tools": sorted(tools)}
    Path("connected-ready").write_text(json.dumps(result))
    print(json.dumps(result))

finally:
    client.close()
