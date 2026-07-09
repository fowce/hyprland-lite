#!/usr/bin/env bash
set -Eeuo pipefail

cache_dir="${XDG_CACHE_HOME:-$HOME/.cache}/hyprland-lite"
state_file="${cache_dir}/current-wallpaper"
lockscreen="${cache_dir}/lockscreen.png"

mkdir -p "$cache_dir"

prepare_lockscreen() {
  if [[ -f "$lockscreen" ]]; then
    return 0
  fi

  if [[ -f "$state_file" ]]; then
    local wallpaper
    wallpaper="$(cat "$state_file")"
    if [[ -f "$wallpaper" ]] && command -v magick >/dev/null 2>&1; then
      magick "$wallpaper" -resize 1920x1080^ -gravity center -extent 1920x1080 -blur 0x18 "$lockscreen"
      return 0
    fi
  fi

  if command -v magick >/dev/null 2>&1; then
    magick -size 1920x1080 gradient:"#1b1719-#2d292b" "$lockscreen"
  fi
}

prepare_lockscreen
pidof hyprlock >/dev/null 2>&1 || hyprlock
