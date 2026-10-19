#!/usr/bin/env bash
set -euo pipefail

fail() {
  echo "doctor: $*" >&2
  exit 1
}

echo "== BBNDK doctor =="

[[ -n "${QNX_HOST:-}" ]] || fail "QNX_HOST is not set"
[[ -n "${QNX_TARGET:-}" ]] || fail "QNX_TARGET is not set"
[[ -d "$QNX_HOST" ]] || fail "QNX_HOST does not exist: $QNX_HOST"
[[ -d "$QNX_TARGET" ]] || fail "QNX_TARGET does not exist: $QNX_TARGET"

command -v qcc >/dev/null 2>&1 || fail "qcc not found in PATH"
command -v blackberry-nativepackager >/dev/null 2>&1 || fail "blackberry-nativepackager not found in PATH"
command -v java >/dev/null 2>&1 || fail "java not found in PATH"

echo "-- qcc version"
qcc -V >/dev/null || fail "qcc -V failed"

echo "-- packager version"
blackberry-nativepackager -version >/dev/null || fail "blackberry-nativepackager -version failed"

echo "-- java version"
java -version >/dev/null 2>&1 || fail "java -version failed"

if command -v qmake >/dev/null 2>&1; then
  echo "-- qmake version"
  qmake -v >/dev/null || fail "qmake -v failed"
fi

TMPDIR="$(mktemp -d)"
trap 'rm -rf "$TMPDIR"' EXIT

cat >"$TMPDIR/hello.c" <<'SRC'
#include <stdio.h>
int main(void) {
    puts("doctor ok");
    return 0;
}
SRC

echo "-- compile smoke test"
qcc -Vgcc_ntoarmv7le -O2 "$TMPDIR/hello.c" -o "$TMPDIR/hello" || fail "qcc compile failed"

echo "-- package smoke test"
cat >"$TMPDIR/bar-descriptor.xml" <<'XML'
<?xml version="1.0" encoding="utf-8" standalone="no"?>
<qnx>
  <id>com.example.doctor</id>
  <filename>hello</filename>
  <name>Doctor Test</name>
  <versionNumber>1.0.0</versionNumber>
  <description>Doctor test package</description>
  <asset path="hello">hello</asset>
</qnx>
XML

(
  cd "$TMPDIR"
  blackberry-nativepackager -package hello.bar -devMode bar-descriptor.xml >/dev/null
) || fail "packaging smoke test failed"

echo "doctor: OK"
