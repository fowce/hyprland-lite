#!/usr/bin/env bash
set -Eeuo pipefail

if pgrep -x waybar >/dev/null 2>&1; then
  pkill -x waybar
else
  waybar -c "$HOME/.config/waybar/config.jsonc" -s "$HOME/.config/waybar/style.css" >/dev/null 2>&1 &
fi
