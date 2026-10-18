# bbndk-starter-kit

A reproducible Debian 13 container for the legacy BlackBerry 10.3.1 Native SDK, with native CLI and Cascades/QML templates, build automation, optional Momentics through XQuartz, and a restricted MCP server for coding agents.

> **Legal notice:** Apache-2.0 covers this project's original files only. The BlackBerry/QNX SDK is third-party software and is not relicensed here. Read [THIRD_PARTY_NOTICE.md](THIRD_PARTY_NOTICE.md) before redistribution.

## Requirements

- macOS with Docker Desktop and Git
- An Intel/AMD Mac, or Apple Silicon with Docker's amd64 emulation enabled
- A BBNDK SDK archive, or a published prebuilt `linux/amd64` image
- Optional: XQuartz for Momentics

The BBNDK host executables are 32-bit Intel Linux binaries, so the image is explicitly `linux/amd64` even on Apple Silicon.

## Fastest path: prebuilt image

```bash
mkdir -p ~/bbndk-projects
export BBNDK_IMAGE=ghcr.io/seeschwein/bbndk-starter-kit:latest
export BBNDK_WORKSPACE="$HOME/bbndk-projects"
docker compose up -d dev
docker compose exec dev qcc -V
```

## Build locally

```bash
git clone https://github.com/seeschwein/bbndk-starter-kit.git
cd bbndk-starter-kit
./scripts/install-sdk.sh --archive ~/Downloads/bbndk-sdk-10.3.1.995.tar.zst
docker build --platform linux/amd64 -t bbndk-starter-kit:local .
```

Expected SDK paths are listed in `sdk/README.md`.

## Start development

```bash
mkdir -p projects
docker compose up -d dev
docker compose exec dev bash
```

Inside:

```bash
qcc -V
blackberry-nativepackager -version
```
![alt text](/docs/qcc.png)
![alt text](/docs/packager.png)

Java 21 prints SecurityManager deprecation warnings. Just ignore, they are expected; compatibility flags allow the 2014 packager to run.

## Create a CLI project

```bash
./scripts/new-project.sh cli myapp com.example.myapp
docker compose exec -w /workspace/myapp dev make
docker compose exec -w /workspace/myapp dev make inspect
```

The BAR appears under `projects/myapp` on the Mac.

## Create a Cascades project

```bash
./scripts/new-project.sh cascades mycascades com.example.mycascades
docker compose exec -w /workspace/mycascades dev make
```

Use VSCodium for source editing and the optional Momentics image for historical BlackBerry wizards and QML exploration. See [docs/XQUARTZ.md](docs/XQUARTZ.md).

## Connect MCP agents

Start `bbndk-dev`, then configure the client to run:

```bash
docker exec -i bbndk-dev python3 /opt/bbndk-mcp/server.py
```

Ready-made steps for Claude Desktop/Code, Cursor, Cline in VSCodium, VS Code-compatible clients, Codex CLI, and Docker MCP Toolkit are in [docs/MCP.md](docs/MCP.md).

## VSCodium

Open the host `projects/` folder directly and build with `docker compose exec`. For agent support, install Cline and use the supplied MCP configuration. This avoids adding SSH to the image.

```bash
docker compose exec -w /workspace/myapp dev make
```

## Momentics/X11

```bash
brew install --cask xquartz
open -a XQuartz
xhost +localhost
docker compose --profile gui up momentics
```

Follow the security and troubleshooting steps in `docs/XQUARTZ.md`.

## Publishing

Will upload compressed SDK payloads as release assets, and distribute the image through GHCR or another registry. See [docs/DISTRIBUTION.md](docs/DISTRIBUTION.md).

## License

Original project files: Apache License 2.0. Third-party SDK components retain their original licenses and notices.
