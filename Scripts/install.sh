#!/usr/bin/env bash
# Build the modern BSM Input Method in Release and install it to the user's
# Input Methods directory. Because the bundle keeps the legacy input source
# identity (ADR 0009), this upgrades an existing install in place — the input
# source stays enabled with no re-enable or re-login.
set -euo pipefail

cd "$(dirname "$0")/.."

DEST="$HOME/Library/Input Methods"
APP="BSMInputMethod.app"
BUILD_DIR="build"

echo "==> Generating Xcode project"
xcodegen generate

echo "==> Building Release"
xcodebuild -project BSMInputMethod.xcodeproj \
    -scheme BSMInputMethod \
    -configuration Release \
    -derivedDataPath "$BUILD_DIR" \
    build

PRODUCT="$BUILD_DIR/Build/Products/Release/$APP"
if [[ ! -d "$PRODUCT" ]]; then
    echo "error: $PRODUCT was not produced" >&2
    exit 1
fi

echo "==> Installing to $DEST"
mkdir -p "$DEST"
# Terminate a running instance so the bundle can be replaced cleanly.
killall BSMInputMethod 2>/dev/null || true
rm -rf "$DEST/$APP"
cp -R "$PRODUCT" "$DEST/$APP"

echo "==> Installed $DEST/$APP"
echo "If this is a first install, enable it in System Settings >"
echo "Keyboard > Text Input > Input Sources > + > Traditional Chinese > BSM."
