#!/usr/bin/env bash
set -euo pipefail
xhost -localhost 2>/dev/null || true
docker compose --profile gui down
