#!/bin/bash
set -uo pipefail

UHUBCTL="${UHUBCTL:-/opt/homebrew/bin/uhubctl}"
STATE_FILE="${STATE_FILE:-$HOME/.webcam_port}"
CAMERA_PATTERN='046d:08e7|Logi Webcam'
PROTECTED_PATTERN='0fd9:|Stream Deck'
FALLBACK_HUB="0-1"
FALLBACK_PORT="3"

show_notification() {
  osascript -e "display notification \"$1\" with title \"Webcam\"" >/dev/null 2>&1 || true
}

notify() {
  [[ "${TOGGLE_QUIET:-0}" == 1 ]] || show_notification "$1"
}

fail() {
  echo "toggle-webcam: $1" >&2
  show_notification "$1"
  exit 1
}

# Stream Deck runs with no TTY, so sudo must be non-interactive (-n) or it hangs.
run_uhubctl() {
  "$UHUBCTL" "$@" 2>/dev/null || sudo -n "$UHUBCTL" "$@"
}

find_camera() {
  awk -v pat="$CAMERA_PATTERN" '
    /^Current status for hub / { hub = $5 }
    $1 == "Port" && $0 ~ pat { port = $2; sub(":", "", port); print hub, port; exit }
  ' <<<"$1"
}

port_line() {
  awk -v hub="$2" -v port="$3:" '
    /^Current status for hub / { cur = $5 }
    cur == hub && $1 == "Port" && $2 == port { print; exit }
  ' <<<"$1"
}

[[ -x "$UHUBCTL" ]] || fail "uhubctl not found at $UHUBCTL"

status=$(run_uhubctl) || fail "Could not read USB hub status (uhubctl failed)"

read -r hub port <<<"$(find_camera "$status")"

if [[ "${1:-}" == "--status" ]]; then
  [[ -n "${hub:-}" ]] && echo on || echo off
  exit 0
fi

if [[ -n "${hub:-}" ]]; then
  line=$(port_line "$status" "$hub" "$port")
  if [[ "$line" =~ $PROTECTED_PATTERN ]]; then
    fail "Refusing to power off hub $hub port $port: it is the Stream Deck"
  fi

  echo "$hub $port" >"$STATE_FILE"
  run_uhubctl -l "$hub" -p "$port" -a off >/dev/null || fail "Could not power off hub $hub port $port"
  notify "Camera off"
  echo "Camera off (hub $hub port $port)"
  exit 0
fi

if [[ -r "$STATE_FILE" ]]; then
  read -r hub port <"$STATE_FILE"
fi
hub="${hub:-$FALLBACK_HUB}"
port="${port:-$FALLBACK_PORT}"

line=$(port_line "$status" "$hub" "$port")
[[ -n "$line" ]] || fail "Webcam not found, and hub $hub port $port does not exist. Is the hub plugged in?"
[[ "$line" == *" off"* ]] || fail "Webcam not found, and hub $hub port $port already has power. Is the camera unplugged?"

run_uhubctl -l "$hub" -p "$port" -a on >/dev/null || fail "Could not power on hub $hub port $port"
notify "Camera on"
echo "Camera on (hub $hub port $port)"
