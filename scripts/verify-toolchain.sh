#!/usr/bin/env bash
set -euo pipefail
printf 'QNX_HOST=%s\nQNX_TARGET=%s\n' "${QNX_HOST:-}" "${QNX_TARGET:-}"
test -x "$QNX_HOST/usr/bin/qcc"
qcc -V
java -version
blackberry-nativepackager -version
printf '#include <stdio.h>\nint main(void){puts("BB10 toolchain OK");return 0;}\n' >/tmp/bb10-smoke.c
qcc -Vgcc_ntoarmv7le /tmp/bb10-smoke.c -o /tmp/bb10-smoke
file /tmp/bb10-smoke
file /tmp/bb10-smoke | grep -q ARM
echo 'Toolchain verification passed.'
