# Momentics over XQuartz on macOS

The slim image excludes Eclipse/Momentics. Use the optional Compose profile with a full historical image, or build a separate GUI image containing `plugins`, `features`, `configuration`, and `qde`.

## Setup

```bash
brew install --cask xquartz
open -a XQuartz
```

In XQuartz Settings > Security, enable **Allow connections from network clients**, quit, and reopen XQuartz. Authorise local clients only:

```bash
xhost +localhost
```

Start Momentics:

```bash
BBNDK_WORKSPACE="$HOME/bbndk-projects" \
BBNDK_MOMENTICS_IMAGE="novelprofessor/bbndk" \
docker compose --profile gui up momentics
```

The service uses `DISPLAY=host.docker.internal:0` and launches `/home/admin/bin/bbndk/qde`. If the path differs:

```bash
docker run --rm --entrypoint bash novelprofessor/bbndk -lc \
  "find /home/admin/bin/bbndk -maxdepth 3 -type f -name 'qde*' -executable"
```

When finished:

```bash
./scripts/xquartz-stop.sh
```

X11 exposes display/input services. Keep access limited to localhost, revoke it afterward, and never use `xhost +`.
