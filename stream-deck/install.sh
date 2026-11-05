#!/bin/bash
set -euo pipefail

DIR="$(cd "$(dirname "$0")" && pwd)"

build_app() {
  local app="$HOME/Applications/$1.app"
  local script="$DIR/$2"

  chmod +x "$script"
  rm -rf "$app"
  osacompile -o "$app" -e "do shell script quoted form of \"$script\""
  /usr/libexec/PlistBuddy -c "Add :LSUIElement bool true" "$app/Contents/Info.plist"
  # Editing Info.plist breaks osacompile's ad-hoc signature, and Apple Silicon won't launch an unsigned applet.
  codesign --force --sign - "$app"

  echo "Built $app -> $script"
}

mkdir -p "$HOME/Applications"
build_app ToggleWebcam toggle-webcam.sh
build_app ToggleMic toggle-mic.sh
