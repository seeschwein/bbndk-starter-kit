#!/usr/bin/env bash
set -euo pipefail
ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
TYPE="${1:-}"; NAME="${2:-}"; APP_ID="${3:-}"
[[ "$TYPE" == cli || "$TYPE" == cascades ]] || { echo "Usage: $0 <cli|cascades> <folder-name> <reverse.domain.id>" >&2; exit 2; }
[[ "$NAME" =~ ^[A-Za-z][A-Za-z0-9_-]*$ ]] || { echo "Invalid project name" >&2; exit 2; }
[[ "$APP_ID" =~ ^[A-Za-z0-9]+([._-][A-Za-z0-9]+)+$ ]] || { echo "Use an ID such as com.example.myapp" >&2; exit 2; }
DEST="$ROOT/projects/$NAME"
[[ ! -e "$DEST" ]] || { echo "$DEST exists" >&2; exit 1; }
SRC="$ROOT/templates/$([[ "$TYPE" == cli ]] && echo hello-cli || echo cascades-qml)"
mkdir -p "$ROOT/projects"; cp -R "$SRC" "$DEST"
find "$DEST" -type f -print0 | xargs -0 sed -i.bak -e "s/com\.example\.hellocli/$APP_ID/g" -e "s/com\.example\.cascadeshello/$APP_ID/g" -e "s/hellocli/$NAME/g" -e "s/cascadeshello/$NAME/g"
find "$DEST" -name '*.bak' -delete
echo "Created $DEST"
