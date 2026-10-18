#!/usr/bin/env bash
set -euo pipefail
command -v xhost >/dev/null || { echo "Install XQuartz: brew install --cask xquartz" >&2; exit 1; }
open -a XQuartz
sleep 3
xhost +localhost
docker compose --profile gui up momentics
