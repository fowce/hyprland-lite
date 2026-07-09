#!/usr/bin/env bash
set -Eeuo pipefail

cache_dir="${XDG_CACHE_HOME:-$HOME/.cache}/hyprland-lite"
state_file="${cache_dir}/current-wallpaper"
lockscreen="${cache_dir}/lockscreen.png"
wallpaper_dir="$HOME/.config/wallpapers"

mkdir -p "$cache_dir"

backend_command() {
  if command -v swww >/dev/null 2>&1 && command -v swww-daemon >/dev/null 2>&1; then
    printf '%s\n' "swww"
    return 0
  fi

  if command -v awww >/dev/null 2>&1 && command -v awww-daemon >/dev/null 2>&1; then
    printf '%s\n' "awww"
    return 0
  fi

  printf 'Wallpaper backend not found. Install swww or awww.\n' >&2
  exit 1
}

start_daemon() {
  local backend="$1"
  local daemon="${backend}-daemon"

  if ! pgrep -x "$daemon" >/dev/null 2>&1; then
    "$daemon" >/dev/null 2>&1 &
    sleep 0.5
  fi
}

set_wallpaper() {
  local image="$1"
  local backend

  [[ -f "$image" ]] || {
    printf 'Wallpaper not found: %s\n' "$image" >&2
    exit 1
  }

  backend="$(backend_command)"
  start_daemon "$backend"
  "$backend" img "$image" --transition-type any
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
