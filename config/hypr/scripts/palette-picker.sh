#!/usr/bin/env bash
set -Eeuo pipefail

config_home="${XDG_CONFIG_HOME:-${HOME}/.config}"
palette_dir="${config_home}/palettes"
theme_dir="${config_home}/theme"
rofi_theme="${config_home}/rofi/launcher.rasi"

die() {
  printf 'palette-picker: %s\n' "$*" >&2
  exit 1
}

command -v rofi >/dev/null 2>&1 || die "rofi is not installed"
[[ -d "${palette_dir}" ]] || die "palette directory not found: ${palette_dir}"
[[ -x "${theme_dir}/apply-palette.sh" ]] || die "palette generator not executable: ${theme_dir}/apply-palette.sh"

mapfile -t palettes < <(find "${palette_dir}" -maxdepth 1 -type f -name '*.json' -printf '%f\n' | sed 's/\.json$//' | sort)

if [[ "${#palettes[@]}" -eq 0 ]]; then
  die "no palette files found in ${palette_dir}"
fi

selection="$(printf '%s\n' "${palettes[@]}" | rofi -dmenu -i -p "Palette" -theme "${rofi_theme}")"
[[ -n "${selection}" ]] || exit 0

"${theme_dir}/apply-palette.sh" "${selection}"
