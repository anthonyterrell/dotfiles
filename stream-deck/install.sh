#!/bin/bash
set -euo pipefail

DIR="$(cd "$(dirname "$0")" && pwd)"
PLUGIN="com.anthonyterrell.avtoggles.sdPlugin"
PLUGINS_DIR="$HOME/Library/Application Support/com.elgato.StreamDeck/Plugins"

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

resize() {
  local source="$DIR/icons/$1.png"
  local name="$2"
  local size="$3"

  sips -z "$size" "$size" "$source" --out "$DIR/$PLUGIN/imgs/$name.png" >/dev/null
  sips -z "$((size * 2))" "$((size * 2))" "$source" --out "$DIR/$PLUGIN/imgs/$name@2x.png" >/dev/null
}

build_plugin_images() {
  mkdir -p "$DIR/$PLUGIN/imgs"
  for icon in camera-on camera-off mic-on mic-off; do
    resize "$icon" "$icon" 72
  done
  resize camera-on action-webcam 20
  resize mic-on action-mic 20
  resize camera-on category 28
  resize camera-on plugin 256
  echo "Built plugin images in $DIR/$PLUGIN/imgs"
}

link_plugin() {
  local target="$PLUGINS_DIR/$PLUGIN"

  if [[ -e "$target" && ! -L "$target" ]]; then
    echo "$target exists and is not a link; remove it and re-run" >&2
    exit 1
  fi
  mkdir -p "$PLUGINS_DIR"
  ln -sfn "$DIR/$PLUGIN" "$target"
  echo "Linked $target -> $DIR/$PLUGIN"
}

restart_stream_deck() {
  if pgrep -xq "Stream Deck"; then
    pkill -TERM -x "Stream Deck"
    while pgrep -xq "Stream Deck"; do sleep 0.5; done
  fi
  open -b com.elgato.StreamDeck
  echo "Restarted Stream Deck"
}

mkdir -p "$HOME/Applications"
build_app ToggleWebcam toggle-webcam.sh
build_app ToggleMic toggle-mic.sh
build_plugin_images
link_plugin
restart_stream_deck
