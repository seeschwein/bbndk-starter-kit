---
name: bb10-dev
description: Universal skill for BlackBerry 10 / QNX native C/C++/Qt development with the bbndk-starter-kit toolchain
metadata:
  type: reference
---

# BlackBerry 10 Development Skill (Universal)

This skill covers development for BlackBerry 10 (BB10) using the native C/C++ toolchain with Qt 4.8.6 / Cascades UI framework, specifically tailored for the **bbndk-starter-kit** containerized workflow. It applies to **any** BB10 project — CLI apps, Cascades QML apps, or CMake-based native libraries.

## Quick Start with bbndk-starter-kit

```bash
# 1. Start the development container
cd bbndk-starter-kit
docker compose up -d dev

# 2. Create a new project (CLI, Cascades, or Cascades+CMake)
./tools/bbndk new cli myapp com.example.myapp
./tools/bbndk new cascades mygui com.example.mygui
./tools/bbndk new cascades-cmake mygui2 com.example.mygui2

# 3. Build
./tools/bbndk build /workspace/myapp

# 4. Deploy to device (Development Mode required)
./tools/bbndk exec blackberry-deploy -installApp -device <IP> -password <pass> /workspace/myapp/build/myapp.bar

# 5. Shell into container for interactive work
./tools/bbndk shell
```

## Toolchains Available

### 1. XIAZY Clang 19 (Primary — C++20/23 capable)

**Image**: `ghcr.io/xiazy/blackberry10-toolchain:latest` (or use bbndk-starter-kit with XIAZY)

**Features**:
- Clang 19.1.7 frontend with full C++20/23 support
- GNU Binutils 2.45 `armnto` linker (QNX-compatible)
- BB10 10.3.1 SDK: headers, Cascades/Qt 4.8.6 libs, CRT objects
- Compiler-rt builtins for ARMv7 (VFPv3-D16, softfp)
- `bb10-cc` / `bb10-c++` gcc-compatible driver wrappers
- `blackberry-deploy`, `blackberry-nativepackager`, `blackberry-signer` included
- QNX 6.5.0 SDK for x86 (simulator target)
- TLS 1.0 Java fix built-in

**Compiler Flags** (via `bb10-c++`):
```bash
# Defaults (gnu++98, no exceptions, no RTTI)
bb10-c++ source.cpp -o output

# Modern C++ (REQUIRED for C++17+)
bb10-c++ -std=gnu++17 -fexceptions -frtti -fno-use-cxa-atexit \
  -O2 -g -Wall -Wextra -pthread -fPIC \
  source.cpp -o output

# C++20/23
bb10-c++ -std=gnu++20 -fexceptions -frtti -fno-use-cxa-atexit \
  -O2 -g -Wall -Wextra -pthread -fPIC \
  source.cpp -o output
```

### 2. GCC 9.3 (Legacy Baseline)

**Image**: `sw7ft/bb10-gcc9:latest` (Docker Hub)

**Usage**:
```bash
docker run --rm -v "$PWD":/src -w /src \
  sw7ft/bb10-gcc9:latest \
  arm-blackberry-qnx8eabi-g++ -std=c++17 -O2 -g -Wall -Wextra \
  -pthread -fPIC -fexceptions -frtti file.cpp -o output
```

### 3. BBNDK Starter Kit (Local Build)

**Image**: `bbndk-starter-kit:local` (built from this repo)

**Features**:
- Complete BBNDK 10.3.1 host tools (`qcc`, `blackberry-deploy`, `blackberry-nativepackager`)
- Pre-extracted SDK at `/opt/bbndk/`
- qmake 4.8.6 for Cascades projects
- Momentics IDE available via `docker compose --profile gui up momentics`
- MCP server for AI-assisted development

**Usage**:
```bash
# Build with qmake (legacy projects)
cd /workspace/myapp && mkdir -p build/arm && cd build/arm
qmake ../../myapp.pro CONFIG+=device
make -j$(nproc)

# Package BAR
blackberry-nativepackager -devMode -package myapp.bar bar-descriptor.xml -configuration Device-Debug
```

---

## Build Systems

### CMake (Recommended for new projects)

The XIAZY toolchain provides `/opt/bb10-toolchain.cmake`.

**Basic CMakeLists.txt**:
```cmake
cmake_minimum_required(VERSION 3.20)
project(my_app LANGUAGES CXX)

# BB10 expects ARM binaries in this directory structure
set(CMAKE_RUNTIME_OUTPUT_DIRECTORY "${CMAKE_BINARY_DIR}/arm/o.le-v7-g")

# Qt4 moc/rcc/uic support
include(BB10Qt4)
qt4_wrap_cpp(MOC_SOURCES src/controller.h)
qt4_add_resources(QRC_SOURCES assets/resources.qrc)

add_executable(my_app src/main.cpp src/controller.cpp ${MOC_SOURCES} ${QRC_SOURCES})
target_link_libraries(my_app PRIVATE bbcascades QtDeclarative QtCore QtGui QtNetwork)

# For BAR packaging, ensure executable name matches bar-descriptor.xml
set_target_properties(my_app PROPERTIES OUTPUT_NAME "myapp")
```

**Build via bbndk-starter-kit**:
```bash
./tools/bbndk build /workspace/myapp
# Or directly in container:
docker run --rm -v "$PWD":/src -w /src \
  ghcr.io/xiazy/blackberry10-toolchain:latest \
  bb10-build /src
```

### qmake (Legacy / bbndk-starter-kit templates)

```bash
# In bbndk-starter-kit container
cd /workspace/myapp
mkdir -p build/arm
cd build/arm
qmake ../../myapp.pro CONFIG+=device
make -j$(nproc)
```

### Plain Make (for simple projects)

```makefile
CXX = bb10-c++
CXXFLAGS = -std=gnu++17 -fexceptions -frtti -fno-use-cxa-atexit \
           -O2 -g -Wall -Wextra -pthread -fPIC
LDFLAGS = -lbbcascades -lQtDeclarative -lQtCore

TARGET = myapp
SOURCES = src/main.cpp src/controller.cpp

all: $(TARGET)

$(TARGET): $(SOURCES)
	$(CXX) $(CXXFLAGS) -o $(TARGET) $(SOURCES) $(LDFLAGS)
```

---

## Project Templates (bbndk-starter-kit)

| Template | Command | Best For |
|---|---|---|
| **CLI** | `./tools/bbndk new cli name com.example.name` | Headless C/C++ services, daemons, tools |
| **Cascades (qmake)** | `./tools/bbndk new cascades name com.example.name` | QML-based UI apps with .pro file |
| **Cascades (CMake)** | `./tools/bbndk new cascades-cmake name com.example.name` | Modern CMake-based Cascades apps |

**Generated structure**:
```
projects/name/
├── src/main.cpp          # C++ entry point
├── assets/main.qml       # QML UI (Cascades only)
├── assets/               # Images, bundled libs, resources
├── bar-descriptor.xml    # BAR manifest
├── Makefile              # qmake wrapper (Cascades)
└── name.pro              # qmake project (Cascades)
# Or CMakeLists.txt for cascades-cmake
```

---

## BAR Packaging

### bar-descriptor.xml (Complete Template)

```xml
<?xml version="1.0" encoding="utf-8"?>
<qnx xmlns="http://www.qnx.com/schemas/application/1.0">
  <id>com.example.myapp</id>
  <filename>myapp</filename>
  <name>My App</name>
  <versionNumber>1.0.0</versionNumber>
  <description>BB10 native application</description>
  <author>Developer</author>
  <authorId>dev</authorId>
  <buildId>1</buildId>
  <configuration>Device-Debug</configuration>
  <icon>
    <image>icon.png</image>
  </icon>
  <action>
    <type>application</type>
    <name>myapp</name>
    <arg>myapp</arg>
  </action>
  <!-- Private runtime libraries (if bundling) -->
  <env>
    <var name="LD_LIBRARY_PATH">/app/native/libs</var>
  </env>
  <assets>
    <!-- Main executable -->
    <asset path="arm/o.le-v7-g/myapp">myapp</asset>
    <!-- All assets directory -->
    <asset path="assets">assets</asset>
    <!-- Individual bundled libraries -->
    <asset path="assets/libs/libstdc++.so.6">libs/libstdc++.so.6</asset>
    <asset path="assets/libs/libgcc_s.so.1">libs/libgcc_s.so.1</asset>
  </assets>
  <permissions>
    <permission>access_shared</permission>
    <permission>access_internet</permission>
    <permission>read_device_identifying_information</permission>
    <permission>access_location_services</permission>
    <!-- Add as needed -->
  </permissions>
</qnx>
```

### Packaging Commands

```bash
# Device-Debug (default, for development)
blackberry-nativepackager -devMode -package myapp.bar bar-descriptor.xml -configuration Device-Debug

# Device-Release (for distribution)
blackberry-nativepackager -devMode -package myapp.bar bar-descriptor.xml -configuration Device-Release

# With debug token (for device testing without dev mode)
blackberry-nativepackager -devMode -debugToken debugtoken.bar \
  -package myapp.bar bar-descriptor.xml -configuration Device-Debug
```

---

## Deployment

### Physical Device (Non-Rooted) — Standard Workflow

**Prerequisites**:
1. **Enable Development Mode** on device: Settings → Security → Development Mode
2. **Note device IP** (shown on screen, typically `169.254.0.1` over USB or WiFi IP)
3. **Set development password**

**Deploy**:
```bash
# From host (using bbndk-starter-kit wrapper)
./tools/bbndk exec blackberry-deploy -installApp -device <IP> -password <pass> /workspace/myapp/myapp.bar

# Or directly with XIAZY image
docker run --rm --network host -v "$PWD":/src \
  ghcr.io/xiazy/blackberry10-toolchain:latest \
  blackberry-deploy -installApp -device <IP> -password <pass> /src/myapp.bar
```

**TLS 1.0 Workaround** (already in XIAZY & bbndk-starter-kit images):
```dockerfile
ENV JDK_JAVA_OPTIONS="-Djava.security.manager=allow --add-exports=java.xml/com.sun.org.apache.xerces.internal.parsers=ALL-UNNAMED"
RUN echo "jdk.tls.disabledAlgorithms=" >> ${JAVA_HOME}/conf/security/java.security \
 && echo "jdk.zip.disableZip64 = false" >> ${JAVA_HOME}/conf/security/java.security
```

### Rooted Device (SSH) — Faster, No TLS Issues

```bash
# Requires bb10mt root
./tools/install-rooted.sh root@<phone-ip> /workspace/myapp/myapp.bar
```

### Simulator (QEMU x86)

```bash
# Start simulator (requires qcow2 image)
docker compose --profile gui up -d momentics
# Or run QEMU directly with bb10-x86 target

# Deploy to simulator gateway
blackberry-deploy -installApp -device 10.0.2.2 -password <pass> /workspace/myapp/myapp.bar
```

---

## Cascades UI Development

### Minimal main.cpp

```cpp
#include <bb/cascades/AbstractPane>
#include <bb/cascades/Application>
#include <bb/cascades/QmlDocument>

using namespace bb::cascades;

Q_DECL_EXPORT int main(int argc, char **argv)
{
    Application app(argc, argv);
    QmlDocument *qml = QmlDocument::create("asset:///main.qml").parent(&app);
    AbstractPane *root = qml->createRootObject<AbstractPane>();
    app.setScene(root);
    return Application::exec();
}
```

### Basic QML (main.qml)

```qml
import bb.cascades 1.0

Page {
    Container {
        layout: DockLayout {}
        Label {
            text: qsTr("Hello BB10")
            horizontalAlignment: HorizontalAlignment.Center
            verticalAlignment: VerticalAlignment.Center
        }
    }
}
```

### Application Resources (.qrc)

```xml
<!-- assets/resources.qrc -->
<RCC>
  <qresource prefix="/">
    <file>main.qml</file>
    <file>images/icon.png</file>
    <file>translations/app_en.ts</file>
  </qresource>
</RCC>
```

In CMake:
```cmake
qt4_add_resources(QRC_SOURCES assets/resources.qrc)
add_executable(myapp ... ${QRC_SOURCES})
```

### moc Requirements

Any class with `Q_OBJECT`, signals, slots, `Q_PROPERTY`, `Q_INVOKABLE`:
```cmake
include(BB10Qt4)
qt4_wrap_cpp(MOC_SOURCES src/controller.h src/model.h)
add_executable(myapp src/main.cpp src/controller.cpp src/model.cpp ${MOC_SOURCES})
```

---

## Runtime Libraries & ABI

### Private Runtime Strategy (Critical)

**BB10 System provides** (do NOT bundle):
- `libc.so.3`
- `libm.so.2`
- `libsocket.so.3`
- `/usr/lib/ldqnx.so.2` (dynamic loader)

**Bundle ONLY** (matching SONAMEs from same GCC version):
- `libstdc++.so.6`
- `libgcc_s.so.1`

### XIAZY Toolchain Builtins

The XIAZY image builds compiler-rt builtins providing ARM runtime helpers:
- `__aeabi_memcpy`, `__aeabi_memset`, `__aeabi_memclr`
- `__aeabi_d2lz`, `__aeabi_l2d`, `__aeabi_d2ulz`, etc.
- Linked after `-lc` so they only supply what libc lacks
- Located at `/opt/bb10-toolchain/lib/libclang_rt.builtins-armv7.a`

### C++ Standard Library Notes

- BB10 ships with Dinkumware STL (GCC 4.x era)
- XIAZY toolchain uses GCC 4.8.3's `libstdc++.so` from SDK
- **Never mix** libstdc++ versions across shared library boundaries
- Source SDK lib: `/opt/bb10-sdk/target/qnx6/armle-v7/lib/libstdc++.so.6`

---

## Common Issues & Fixes

| Issue | Cause | Fix |
|---|---|---|
| `undefined reference to '__dso_handle'` | Clang default uses `cxa_atexit` | Add `-fno-use-cxa-atexit` to link flags |
| `cannot find -ldl` | `dlopen` is in libc on QNX | Remove `-ldl`; use `-ldl` only on Linux |
| `libstdc++.so.6` version mismatch | Bundled lib doesn't match compiler | Use SDK's `libstdc++.so.6` from same GCC version |
| `libgcc_s.so.1` missing for ARM | Not in SDK package | Build from GCC 4.8.3 sources or extract from device |
| TLS handshake fails on deploy | Java blocks TLS 1.0 | Set `jdk.tls.disabledAlgorithms=` in java.security |
| `blackberry-deploy` timeout | Device not in Dev Mode / wrong IP | Verify Dev Mode enabled, check IP |
| moc fails on headers | Missing `Q_OBJECT` / Qt includes | Ensure `qt4_wrap_cpp`, add Qt4 include paths |
| `-std=gnu++98` default | XIAZY driver defaults to C++98 | Explicitly set `-std=gnu++17` or `-std=gnu++20` |
| Exceptions/RTTI disabled by default | Driver adds `-fno-exceptions -fno-rtti` | Explicitly add `-fexceptions -frtti` |

---

## MCP (Model Context Protocol) Integration

The bbndk-starter-kit includes a restricted MCP server at `/opt/bbndk-mcp/server.py`.

### Start MCP Server

```bash
# Start container
docker compose up -d dev

# Run MCP server (stdio, no -t flag)
docker exec -i bbndk-dev python3 /opt/bbndk-mcp/server.py
```

### Configure Clients

**Claude Code / Claude Desktop** — Use `.mcp.json` or merge `mcp/clients/portable.mcp.json`:
```json
{
  "mcpServers": {
    "bbndk": {
      "command": "docker",
      "args": ["exec", "-i", "bbndk-dev", "python3", "/opt/bbndk-mcp/server.py"]
    }
  }
}
```

**Cursor / Cline / VS Code** — Copy to `.cursor/mcp.json` or `.vscode/mcp.json`

**Codex CLI** — Merge `mcp/clients/codex.toml` into `~/.codex/config.toml`

### MCP Tools Exposed

The server provides file operations + BB10 build actions:
- `read_file`, `write_file`, `list_dir`, `glob`
- `build_project(path)` — runs `bb10-build`
- `package_bar(path, config)` — runs `blackberry-nativepackager`
- `deploy_bar(path, ip, pass)` — runs `blackberry-deploy`
- `run_probes(path)` — executes probe suite on device

### Common MCP Tool Calls

```python
# Build a CMake Cascades project
result = run_bash({
    "command": "docker run --rm -v /workspace:/src -w /src "
               "ghcr.io/xiazy/blackberry10-toolchain:latest "
               "bb10-build /src",
    "description": "Build CMake project with XIAZY Clang"
})

# Compile single file with modern C++
result = run_bash({
    "command": "docker run --rm -v /workspace:/src -w /src/probes "
               "ghcr.io/xiazy/blackberry10-toolchain:latest "
               "bb10-c++ -std=gnu++17 -fexceptions -frtti "
               "-fno-use-cxa-atexit -O2 -g -Wall -Wextra -pthread -fPIC "
               "file.cpp -o build/file",
    "description": "Compile probe with XIAZY toolchain"
})

# Package BAR
result = run_bash({
    "command": "docker run --rm -v /workspace:/src -w /src "
               "ghcr.io/xiazy/blackberry10-toolchain:latest "
               "blackberry-nativepackager -devMode -package app.bar bar-descriptor.xml",
    "description": "Package BAR for deployment"
})

# Deploy to device
result = run_bash({
    "command": "docker run --rm --network host -v /workspace:/src "
               "ghcr.io/xiazy/blackberry10-toolchain:latest "
               "blackberry-deploy -installApp -device 192.168.x.x -password pass "
               "/src/app.bar",
    "description": "Install BAR on BB10 device"
})
```

---

## bbndk-starter-kit Specific Commands

| Command | Description |
|---|---|
| `./tools/bbndk up` | Start dev container |
| `./tools/bbndk shell` | Interactive bash in container |
| `./tools/bbndk doctor` | Verify toolchain health |
| `./tools/bbndk check /path` | Validate project structure |
| `./tools/bbndk build /path` | Build project (Make/CMake) |
| `./tools/bbndk exec <cmd>` | Run arbitrary command in container |
| `./tools/bbndk new cli name id` | Scaffold CLI project |
| `./tools/bbndk new cascades name id` | Scaffold Cascades (qmake) |
| `./tools/bbndk new cascades-cmake name id` | Scaffold Cascades (CMake) |

---

## Debugging

### On-Device Logs

```bash
# Get device logs via blackberry-deploy
blackberry-deploy -getDeviceLog <IP> -password <pass>

# Or via SSH (if rooted)
ssh root@<IP> "slog2info -b"
```

### GDB (Requires Root/SSH)

```bash
# On device
gdbserver :1234 /app/native/myapp

# From host (needs gdb-multiarch or arm-none-eabi-gdb)
gdb-multiarch -ex "target remote <IP>:1234" /path/to/myapp
```

### Simulator Debugging

```bash
# bb10-x86 builds run in QEMU simulator
QNX_ARCH=x86 bb10-c++ -o myapp_x86 source.cpp
# Run in simulator, attach gdb
```

---

## References

- [XIAZY blackberry10-toolchain](https://github.com/XIAZY/blackberry10-toolchain) — Modern Clang toolchain
- [extrowerk/bb10-gcc9](https://github.com/extrowerk/bb10-gcc9) — GCC 9.3 baseline
- [BBNDK Starter Kit](https://github.com/seeschwein/bbndk-starter-kit) — This containerized workflow
- [BlackBerry 10 Native SDK Docs](https://developer.blackberry.com/native/) — Archived official docs
- [Qt 4.8 Documentation](https://doc.qt.io/archives/qt-4.8/) — Qt version on BB10
- [Cascades API Reference](https://developer.blackberry.com/native/reference/cascades/) — UI framework
- [fen-blackberry](https://github.com/acmiyaguchi/fen-blackberry) — Rust on BB10 experiment