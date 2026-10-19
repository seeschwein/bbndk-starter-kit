#!/usr/bin/env bash
set -euo pipefail

PROJECT="${1:-}"
[[ -n "$PROJECT" ]] || { echo "Usage: $0 PROJECT_PATH" >&2; exit 2; }
[[ -d "$PROJECT" ]] || { echo "Project directory not found: $PROJECT" >&2; exit 1; }

DESC="$PROJECT/bar-descriptor.xml"
[[ -f "$DESC" ]] || { echo "Missing bar-descriptor.xml in $PROJECT" >&2; exit 1; }

extract_tag() {
  local tag="$1"
  sed -n "s:.*<$tag>\\(.*\\)</$tag>.*:\\1:p" "$DESC" | head -n1
}

APP_ID="$(extract_tag id)"
FILENAME="$(extract_tag filename)"

[[ -n "$APP_ID" ]] || { echo "Missing <id> in bar-descriptor.xml" >&2; exit 1; }
[[ "$APP_ID" =~ ^[A-Za-z0-9]+([._-][A-Za-z0-9]+)+$ ]] || { echo "Invalid app id: $APP_ID" >&2; exit 1; }
[[ -n "$FILENAME" ]] || { echo "Missing <filename> in bar-descriptor.xml" >&2; exit 1; }

echo "check: id=$APP_ID"
echo "check: filename=$FILENAME"

mapfile -t ASSET_PATHS < <(grep -o 'asset path="[^"]*"' "$DESC" | sed 's/asset path="//; s/"//')

for rel in "${ASSET_PATHS[@]}"; do
  if [[ "$rel" == *"/"* ]]; then
    if [[ ! -e "$PROJECT/$rel" ]]; then
      echo "warning: asset path does not currently exist: $rel"
    else
      echo "check: asset ok: $rel"
    fi
  else
    if [[ -e "$PROJECT/$rel" ]]; then
      echo "check: asset ok: $rel"
    else
      echo "warning: top-level asset not present yet: $rel"
    fi
  fi
done

if [[ -f "$PROJECT/Makefile" ]]; then
  echo "check: Makefile present"
elif [[ -f "$PROJECT/CMakeLists.txt" ]]; then
  echo "check: CMakeLists.txt present"
else
  echo "No Makefile or CMakeLists.txt found in $PROJECT" >&2
  exit 1
fi

if [[ -d "$PROJECT/assets" ]]; then
  echo "check: assets directory present"
fi

if [[ -d "$PROJECT/src" ]]; then
  echo "check: src directory present"
fi

echo "check: OK"
