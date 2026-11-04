#!/bin/bash
set -euo pipefail

DIR="$(cd "$(dirname "$0")" && pwd)"
APP="$HOME/Applications/ToggleWebcam.app"

chmod +x "$DIR/toggle-webcam.sh"
mkdir -p "$HOME/Applications"
rm -rf "$APP"
osacompile -o "$APP" -e "do shell script quoted form of \"$DIR/toggle-webcam.sh\""
/usr/libexec/PlistBuddy -c "Add :LSUIElement bool true" "$APP/Contents/Info.plist"
# Editing Info.plist breaks osacompile's ad-hoc signature, and Apple Silicon won't launch an unsigned applet.
codesign --force --sign - "$APP"

echo "Built $APP -> $DIR/toggle-webcam.sh"
