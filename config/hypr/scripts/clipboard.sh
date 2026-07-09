#!/usr/bin/env bash
set -Eeuo pipefail

case "${1:-}" in
  --delete)
    cliphist list | rofi -dmenu -replace -i -p "delete clipboard" -config "$HOME/.config/rofi/clipboard.rasi" | cliphist delete
    ;;
  --wipe)
    cliphist wipe
    ;;
  *)
    cliphist list | rofi -dmenu -replace -i -p "clipboard" -config "$HOME/.config/rofi/clipboard.rasi" | cliphist decode | wl-copy
    ;;
esac
