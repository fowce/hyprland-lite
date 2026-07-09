#!/usr/bin/env bash
set -Eeuo pipefail

cache_dir="${XDG_CACHE_HOME:-$HOME/.cache}/hyprland-lite"
state_file="${cache_dir}/current-wallpaper"
lockscreen="${cache_dir}/lockscreen.png"
wallpaper_dir="$HOME/.config/wallpapers"

mkdir -p "$cache_dir"

start_daemon() {
  if ! pgrep -x swww-daemon >/dev/null 2>&1; then
    swww-daemon >/dev/null 2>&1 &
    sleep 0.5
  fi
}

set_wallpaper() {
  local image="$1"
  [[ -f "$image" ]] || {
    printf 'Wallpaper not found: %s\n' "$image" >&2
    exit 1
  }

  start_daemon
  swww img "$image" --transition-type any
  printf '%s\n' "$image" > "$state_file"

  if command -v magick >/dev/null 2>&1; then
    magick "$image" -resize 1920x1080^ -gravity center -extent 1920x1080 -blur 0x18 "$lockscreen"
  fi
}

case "${1:-}" in
  --restore)
    if [[ -f "$state_file" ]]; then
      set_wallpaper "$(cat "$state_file")"
    elif [[ -f "${wallpaper_dir}/default.jpg" ]]; then
      set_wallpaper "${wallpaper_dir}/default.jpg"
    fi
    ;;
  --random)
    image="$(find "$wallpaper_dir" -maxdepth 1 -type f \( -iname '*.jpg' -o -iname '*.jpeg' -o -iname '*.png' -o -iname '*.webp' \) | shuf -n 1)"
    [[ -n "${image:-}" ]] || exit 0
    set_wallpaper "$image"
    ;;
  "")
    printf 'Usage: wallpaper.sh --restore | --random | PATH\n' >&2
    exit 1
    ;;
  *)
    set_wallpaper "$1"
    ;;
esac
