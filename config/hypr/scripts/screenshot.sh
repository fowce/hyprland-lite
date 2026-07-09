#!/usr/bin/env bash
set -Eeuo pipefail

screenshot_dir="${XDG_PICTURES_DIR:-$HOME/Pictures}"
mkdir -p "$screenshot_dir"

filename="screenshot_$(date +%Y%m%d_%H%M%S).png"
path="${screenshot_dir}/${filename}"

mode="${1:-}"

case "$mode" in
  --screen)
    grim "$path"
    ;;
  --area)
    geometry="$(slurp)"
    [[ -n "$geometry" ]] || exit 0
    grim -g "$geometry" "$path"
    ;;
  *)
    choice="$(printf 'area\nscreen\n' | rofi -dmenu -replace -i -p "screenshot")"
    case "$choice" in
      area)
        geometry="$(slurp)"
        [[ -n "$geometry" ]] || exit 0
        grim -g "$geometry" "$path"
        ;;
      screen)
        grim "$path"
        ;;
      *)
        exit 0
        ;;
    esac
    ;;
esac

wl-copy < "$path"
notify-send "Screenshot saved" "$path" 2>/dev/null || true
