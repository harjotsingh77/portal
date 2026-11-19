#!/bin/bash
# One-line Portal installer:
#   curl -fsSL https://raw.githubusercontent.com/harjotsingh77/portal/main/install.sh | bash
# Files fetched with curl aren't quarantined, so the "Apple could not verify Portal" prompt never appears.
set -euo pipefail

URL="${PORTAL_DMG_URL:-https://github.com/harjotsingh77/portal/releases/latest/download/Portal.dmg}"
DEST="${PORTAL_INSTALL_DIR:-/Applications}"
[[ -w "$DEST" ]] || DEST="$HOME/Applications"
mkdir -p "$DEST"

TMP="$(mktemp -d)"
MNT="$TMP/mnt"
cleanup() { hdiutil detach "$MNT" -quiet 2>/dev/null || true; rm -rf "$TMP"; }
trap cleanup EXIT

echo "Downloading Portal…"
curl -fL --progress-bar "$URL" -o "$TMP/Portal.dmg"

mkdir -p "$MNT"
hdiutil attach "$TMP/Portal.dmg" -nobrowse -readonly -mountpoint "$MNT" -quiet

osascript -e 'quit app "Portal"' 2>/dev/null || true
rm -rf "$DEST/Portal.app"
ditto "$MNT/Portal.app" "$DEST/Portal.app"
xattr -dr com.apple.quarantine "$DEST/Portal.app" 2>/dev/null || true

echo "Installed Portal in $DEST. Opening…"
[[ -n "${PORTAL_NO_OPEN:-}" ]] || open "$DEST/Portal.app"
