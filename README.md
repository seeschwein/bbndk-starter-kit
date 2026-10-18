# 🫐 bbndk-starter-kit 🍇

A reproducible Debian 13 container for the legacy BlackBerry 10.3.1 Native SDK, with native CLI and Cascades/QML templates, build automation, optional Momentics through XQuartz, and a restricted MCP server for coding agents.

> **Legal notice:** Apache-2.0 covers this project's original files only. The BlackBerry/QNX SDK is third-party software and is not relicensed here. Read [THIRD_PARTY_NOTICE.md](THIRD_PARTY_NOTICE.md) before redistribution.

## Requirements
| Host | Recommended setup | Notes |
|---|---|---|
| macOS, Intel | Docker Desktop | Runs the image natively |
| macOS, Apple Silicon | Docker Desktop | Runs the required `linux/amd64` image through emulation |
| Linux, x86-64 | Docker Engine plus Compose plugin, or Docker Desktop | Native container architecture |
| Windows 10/11, x86-64 | Docker Desktop with WSL 2 and Linux containers | PowerShell and WSL instructions are provided |

The legacy BBNDK host tools are 32-bit Intel Linux executables. The image is therefore published as `linux/amd64`, including on ARM-based hosts.

## Fastest path: prebuilt image

### macOS

Install and start Docker Desktop, then run:

```bash
git https://github.com/seeschwein/bbndk-starter-kit
cd bbndk-starter-kit
mkdir -p projects
export BBNDK_IMAGE=ghcr.io/seeschwein/bbndk-starter-kit:latest
export BBNDK_WORKSPACE="$HOME/bbndk-projects"
docker pull "$BBNDK_IMAGE"
docker compose up -d --no-build dev
docker compose exec dev qcc -V
```
### Linux

Install Docker Engine and the Docker Compose plugin for your distro.

Clone and start the environment:

```bash
git clone REPOSITORY_URL
cd bbndk-starter-kit
mkdir -p projects
export BBNDK_IMAGE=ghcr.io/seeschwein/bbndk-starter-kit:latest
export BBNDK_WORKSPACE="$PWD/bbndk-projects"
docker pull "$BBNDK_IMAGE"
docker compose up -d --no-build dev
docker compose exec dev qcc -V
```
### Windows: PowerShell

Install Docker Desktop, select the WSL 2 backend, and make sure Docker is using **Linux containers**. In PowerShell:

```powershell
git clone REPOSITORY_URL
Set-Location bbndk-starter-kit
New-Item -ItemType Directory -Force projects | Out-Null
$env:BBNDK_IMAGE = "ghcr.io/OWNER/bbndk-starter-kit:latest"
$env:BBNDK_WORKSPACE = "${PWD}\projects"
docker pull $env:BBNDK_IMAGE
docker compose up -d --no-build dev
docker compose exec dev qcc -V
```

Environment variables set with `$env:` apply to the current PowerShell session. Set them again in a new terminal, or copy `.env.example` to `.env` if the repository provides one.

### Windows: WSL 2

For the best Linux-container file performance, clone the repository inside the WSL filesystem rather than under `/mnt/c`:

```bash
cd ~
git clone REPOSITORY_URL
cd bbndk-starter-kit
mkdir -p projects
export BBNDK_IMAGE=ghcr.io/seeschwein/bbndk-starter-kit:latest
export BBNDK_WORKSPACE="$PWD/projects"
docker pull "$BBNDK_IMAGE"
docker compose up -d --no-build dev
docker compose exec dev qcc -V
```

In Docker Desktop, enable the distribution under **Settings > Resources > WSL Integration**.


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

Inside the container:

```bash
qcc -V
blackberry-nativepackager -version
```
qcc.                       |  bbpkg
:-------------------------:|:-------------------------:
![alt text](/docs/qcc.png) | ![alt text](/docs/packager.png)

Java 21 prints SecurityManager deprecation warnings. Just ignore, they are expected; compatibility flags allow the 2014 packager to run.

## Create a CLI project

```bash
./scripts/new-project.sh cli myapp com.example.myapp
docker compose exec -w /workspace/myapp dev make
docker compose exec -w /workspace/myapp dev make inspect
```

The BAR appears under `projects/myapp` on the host.

## Create a Cascades project

```bash
./scripts/new-project.sh cascades mycascades com.example.mycascades
docker compose exec -w /workspace/mycascades dev make
```

Use VSCodium for source editing and the optional Momentics image for historical BlackBerry wizards and QML exploration. See [docs/XQUARTZ.md](docs/XQUARTZ.md).

## Connect MCP agents

Start `bbndk-dev`, then configure the client to run

```bash
docker compose up -d dev
docker exec -i bbndk-dev python3 /opt/bbndk-mcp/server.py
```

Some steps for Claude Desktop/Code, Cursor, Cline in VSCodium, VS Code-compatible clients, Codex CLI, and Docker MCP Toolkit are in [docs/MCP.md](docs/MCP.md).

## VSCodium

Open the host `projects/` folder directly and build with `docker compose exec`. For agent support, install Cline and use the supplied MCP configuration. This avoids adding SSH to the image.

```bash
docker compose exec -w /workspace/myapp dev make
```

## Momentics/X11
The primary image is designed for command-line builds. Momentics is optional and uses a separate GUI image.

```bash
brew install --cask xquartz
open -a XQuartz
xhost +localhost
docker compose --profile gui up momentics
```

Follow the security and troubleshooting steps in [docs/XQUARTZ.md](docs/XQUARTZ.md).

## Security

- Mount only a dedicated project directory at `/workspace`.
- Do not mount the Docker socket, SSH directory, credentials, or entire home directory into the development container.
- Review MCP write and build calls instead of enabling unconditional approval.
- Verify downloaded SDK archives before extraction.
- Treat the environment as legacy development tooling, not as a hardened multi-tenant service.

## License

Original project files: Apache License 2.0. Third-party SDK components retain their original licenses and notices.
