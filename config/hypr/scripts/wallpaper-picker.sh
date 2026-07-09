#!/usr/bin/env bash
set -Eeuo pipefail

wallpaper_dir="$HOME/.config/wallpapers"
script_dir="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd -P)"

mkdir -p "$wallpaper_dir"

selection="$(
  find "$wallpaper_dir" -maxdepth 1 -type f \( -iname '*.jpg' -o -iname '*.jpeg' -o -iname '*.png' -o -iname '*.webp' \) \
    | sort \
    | sed "s#^${wallpaper_dir}/##" \
    | rofi -dmenu -replace -i -p "wallpaper"
)"

[[ -n "$selection" ]] || exit 0
"${script_dir}/wallpaper.sh" "${wallpaper_dir}/${selection}"
