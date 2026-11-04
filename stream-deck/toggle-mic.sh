#!/bin/bash
set -uo pipefail

STATE_FILE="${STATE_FILE:-$HOME/.mic_volume}"
FALLBACK_VOLUME=50

notify() {
  osascript -e "display notification \"$1\" with title \"Microphone\"" >/dev/null 2>&1 || true
}

fail() {
  echo "toggle-mic: $1" >&2
  notify "$1"
  exit 1
}

current=$(osascript -e 'input volume of (get volume settings)' 2>/dev/null)
[[ "$current" =~ ^[0-9]+$ ]] || fail "The current input device does not let macOS change its volume"

if (( current > 0 )); then
  echo "$current" >"$STATE_FILE"
  osascript -e 'set volume input volume 0' || fail "Could not mute the microphone"
  notify "Mic muted"
  echo "Mic muted (was $current)"
  exit 0
fi

saved=$(cat "$STATE_FILE" 2>/dev/null || true)
[[ "$saved" =~ ^[0-9]+$ ]] && (( saved > 0 )) || saved=$FALLBACK_VOLUME

osascript -e "set volume input volume $saved" || fail "Could not unmute the microphone"
notify "Mic on"
echo "Mic on (volume $saved)"
