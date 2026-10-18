#!/usr/bin/env bash
set -euo pipefail
ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
OUT="${1:-$ROOT/output/bbndk-sdk-10.3.1.995.tar.zst}"
mkdir -p "$(dirname "$OUT")"
for p in bbndk-env_10_3_1_995.sh host_10_3_1_12_linux_x86 target_10_3_1_995_qnx6 target_10_3_1_995_target-override; do
  [[ -e "$ROOT/sdk/$p" ]] || { echo "Missing sdk/$p" >&2; exit 1; }
done
command -v zstd >/dev/null || { echo "Install zstd: brew install zstd" >&2; exit 1; }
tar -C "$ROOT/sdk" --zstd -cf "$OUT" bbndk-env_10_3_1_995.sh host_10_3_1_12_linux_x86 target_10_3_1_995_qnx6 target_10_3_1_995_target-override
shasum -a 256 "$OUT" > "$OUT.sha256"
BYTES="$(stat -f%z "$OUT" 2>/dev/null || stat -c%s "$OUT")"
if (( BYTES >= 2147483648 )); then
  echo "Archive is >= 2 GiB; split it into release assets under 2 GiB." >&2
  exit 3
fi
echo "Created $OUT"
cat "$OUT.sha256"
