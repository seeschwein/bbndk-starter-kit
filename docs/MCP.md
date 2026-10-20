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

## BB10 Development Tips for MCP Agents

### Common Build Commands

```bash
# Compile a single C++ file with XIAZY Clang (C++17, exceptions, RTTI)
bb10-c++ -std=gnu++17 -fexceptions -frtti -fno-use-cxa-atexit \
  -O2 -g -Wall -Wextra -pthread -fPIC \
  source.cpp -o build/output

# Build a CMake-based Cascades project
bb10-build /workspace/myapp

# Build with qmake (legacy)
cd /workspace/myapp && mkdir -p build/arm && cd build/arm
qmake ../../myapp.pro CONFIG+=device
make -j$(nproc)
```

### BAR Packaging

```bash
# Package a BAR (Device-Debug)
blackberry-nativepackager -devMode -package app.bar bar-descriptor.xml -configuration Device-Debug

# Package a BAR (Device-Release)
blackberry-nativepackager -devMode -package app.bar bar-descriptor.xml -configuration Device-Release
```

### Deployment to Device

```bash
# Physical device (Development Mode required)
blackberry-deploy -installApp -device <IP> -password <PASS> /path/to/app.bar

# Simulator (QEMU)
blackberry-deploy -installApp -device 10.0.2.2 -password <PASS> /path/to/app.bar

# Rooted device (SSH)
tools/install-rooted.sh root@<IP> /path/to/app.bar
```

### Required `bar-descriptor.xml` Assets

For apps bundling private runtime libraries:
```xml
<env>
  <var name="LD_LIBRARY_PATH">/app/native/probes</var>
</env>
<assets>
  <asset path="arm/o.le-v7-g/appname">appname</asset>
  <asset path="assets/probes/libstdc++.so.6">probes/libstdc++.so.6</asset>
  <asset path="assets/probes/libgcc_s.so.1">probes/libgcc_s.so.1</asset>
  <asset path="assets/run-probes.sh">run-probes.sh</asset>
</assets>
```

### Key Compiler Flags (XIAZY bb10-c++)

| Flag | Purpose |
|------|---------|
| `-std=gnu++17` / `-std=gnu++20` | C++ standard (gnu++98 default!) |
| `-fexceptions -frtti` | Enable exceptions/RTTI (disabled by default!) |
| `-fno-use-cxa-atexit` | Fix `__dso_handle` undefined reference |
| `-fPIC` | Position-independent code |
| `-pthread` | Thread support |

### Common Linker Issues

| Error | Fix |
|-------|-----|
| `undefined reference to '__dso_handle'` | Add `-fno-use-cxa-atexit` |
| `cannot find -ldl` | Remove `-ldl`; dlopen is in libc on QNX |
| `libstdc++.so.6` version mismatch | Use SDK's `libstdc++.so.6` from `/opt/bb10-sdk/target/qnx6/armle-v7/lib/` |
| `libgcc_s.so.1` missing | Build from GCC 4.8.3 sources or extract from device |

### Runtime Library Policy

**Bundle only**:
- `libstdc++.so.6` (matching SDK GCC version)
- `libgcc_s.so.1` (matching SDK GCC version)

**Never bundle** (use system):
- `libc.so.3`
- `libm.so.2`
- `libsocket.so.3`
- `/usr/lib/ldqnx.so.2`

### Cascades QML Tips

```qml
// main.qml - basic page
import bb.cascades 1.0

Page {
    Container {
        layout: DockLayout {}
        Label {
            text: "Hello BB10"
            horizontalAlignment: HorizontalAlignment.Center
            verticalAlignment: VerticalAlignment.Center
        }
    }
}
```

### moc Requirements

Classes with `Q_OBJECT`, signals, slots, `Q_PROPERTY`, `Q_INVOKABLE`:
```cmake
include(BB10Qt4)
qt4_wrap_cpp(MOC_SOURCES src/controller.h)
add_executable(app src/main.cpp src/controller.cpp ${MOC_SOURCES})
```

### Debugging on Device

```bash
# Get device logs
blackberry-deploy -getDeviceLog <IP> -password <PASS>

# Run gdbserver on device (requires root/SSH)
gdbserver :1234 /app/native/appname

# Connect from host
gdb-multiarch -ex "target remote <IP>:1234" /path/to/appname
```

### TLS 1.0 Java Fix (already in image)

If deployment fails with SSL/TLS errors, verify the Java policy:
```bash
cat ${JAVA_HOME}/conf/security/java.security | grep tls
# Should show: jdk.tls.disabledAlgorithms=
```
