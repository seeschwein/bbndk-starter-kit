# Connecting MCP clients

The image contains a dependency-free MCP server restricted to `/workspace`. It exposes file operations plus allowlisted BB10 build actions; it does not expose an arbitrary shell or Docker socket.

## Start the container

```bash
docker compose up -d dev
```

Every local client ultimately runs:

```bash
docker exec -i bbndk-dev python3 /opt/bbndk-mcp/server.py
```

Do not add `-t`; MCP stdio must remain machine-readable.

## Claude Desktop and Claude Code

Merge `mcp/clients/portable.mcp.json`'s `mcpServers.bbndk` entry into Claude Desktop's developer configuration, or use it as project-root `.mcp.json` with Claude Code. Restart the client and approve the server.

## Cursor

Copy `mcp/clients/portable.mcp.json` to `.cursor/mcp.json`. Open Cursor Settings > MCP and verify `bbndk` is ready.

## Cline in VSCodium

Install Cline from Open VSX. Open Cline > MCP Servers > Configure MCP Servers and merge the `bbndk` entry from `mcp/clients/portable.mcp.json` into `mcpServers`.

## VS Code / compatible forks

Copy `mcp/clients/vscode.mcp.json` to `.vscode/mcp.json`, then run `MCP: List Servers`. VSCodium may not expose Microsoft's built-in agent host; use Cline there.

## Codex CLI

Merge `mcp/clients/codex.toml` into `~/.codex/config.toml`, restart Codex, and inspect the tools before approving calls.

## Docker MCP Toolkit

Edit the placeholders in `mcp/docker-toolkit/server.yaml`, then:

```bash
docker mcp profile create --name bbndk \
  --server file://"$PWD/mcp/docker-toolkit/server.yaml"
docker mcp client connect claude-desktop --profile bbndk
# Other supported names include cursor, cline, codex, vscode, and zed.
```

A client can also launch the gateway manually:

```json
{"command":"docker","args":["mcp","gateway","run","--profile","bbndk"]}
```

## Safety

- Mount only a dedicated projects directory at `/workspace`.
- Review writes and build/package calls; do not auto-approve every tool.
- Never mount `/var/run/docker.sock`, `~/.ssh`, or the whole home directory.
- This is starter developer tooling, not a hardened multi-tenant service.
