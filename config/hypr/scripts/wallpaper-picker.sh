#!/usr/bin/env bash
set -Eeuo pipefail

wallpaper_dir="$HOME/.config/wallpapers"
script_dir="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd -P)"
rofi_theme="${XDG_CONFIG_HOME:-${HOME}/.config}/rofi/wallpaper.rasi"

mkdir -p "$wallpaper_dir"

mapfile -t wallpapers < <(
  find "$wallpaper_dir" -maxdepth 1 -type f \( -iname '*.jpg' -o -iname '*.jpeg' -o -iname '*.png' -o -iname '*.webp' \) | sort
)

[[ "${#wallpapers[@]}" -gt 0 ]] || exit 0

selection="$(
  for image in "${wallpapers[@]}"; do
    printf ' \0icon\x1f%s\n' "$image"
  done | rofi -dmenu -replace -i -show-icons -format i -p "" -theme "$rofi_theme"
)"

[[ -n "$selection" ]] || exit 0
[[ "$selection" =~ ^[0-9]+$ ]] || exit 0
"${script_dir}/wallpaper.sh" "${wallpapers[$selection]}"
