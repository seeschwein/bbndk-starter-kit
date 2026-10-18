#!/usr/bin/env bash
set -euo pipefail
ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
ARCHIVE=""
URL="${BBNDK_SDK_URL:-}"
EXPECTED="${BBNDK_SDK_SHA256:-}"
while [[ $# -gt 0 ]]; do
  case "$1" in
    --archive) ARCHIVE="${2:?missing archive path}"; shift 2 ;;
    -h|--help) echo "Usage: $0 --archive FILE, or set BBNDK_SDK_URL and optionally BBNDK_SDK_SHA256"; exit 0 ;;
    *) echo "Unknown option: $1" >&2; exit 2 ;;
  esac
done
mkdir -p "$ROOT/sdk"
TMP=""
trap '[[ -n "$TMP" ]] && rm -f "$TMP"' EXIT
if [[ -z "$ARCHIVE" ]]; then
  [[ -n "$URL" ]] || { echo "Set BBNDK_SDK_URL or pass --archive." >&2; exit 2; }
  TMP="$(mktemp -t bbndk-sdk.XXXXXX.tar.zst)"
  curl --fail --location --retry 3 --output "$TMP" "$URL"
  ARCHIVE="$TMP"
fi
[[ -f "$ARCHIVE" ]] || { echo "Archive not found: $ARCHIVE" >&2; exit 1; }
if [[ -n "$EXPECTED" ]]; then
  ACTUAL="$(shasum -a 256 "$ARCHIVE" | awk '{print $1}')"
  [[ "$ACTUAL" == "$EXPECTED" ]] || { echo "SHA-256 mismatch" >&2; exit 1; }
fi
case "$ARCHIVE" in
  *.tar.zst|*.tzst) tar --zstd -xf "$ARCHIVE" -C "$ROOT/sdk" ;;
  *.tar.gz|*.tgz) tar -xzf "$ARCHIVE" -C "$ROOT/sdk" ;;
  *.zip) unzip -q "$ARCHIVE" -d "$ROOT/sdk" ;;
  *) echo "Unsupported archive: $ARCHIVE" >&2; exit 1 ;;
esac
for item in bbndk-env_10_3_1_995.sh host_10_3_1_12_linux_x86 target_10_3_1_995_qnx6 target_10_3_1_995_target-override; do
  [[ -e "$ROOT/sdk/$item" ]] || { echo "Missing sdk/$item after extraction" >&2; exit 1; }
done
echo "SDK installed in $ROOT/sdk"
