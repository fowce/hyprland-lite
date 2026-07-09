#!/usr/bin/env bash
set -Eeuo pipefail

usage() {
  cat <<EOF
Usage: apply-palette.sh PALETTE [--repo-root PATH] [--no-reload]

Examples:
  apply-palette.sh warm
  apply-palette.sh warm --repo-root /home/user/hyprland-lite
  apply-palette.sh warm --no-reload
EOF
}

palette_name=""
repo_root=""
reload=true

while [[ "$#" -gt 0 ]]; do
  case "$1" in
    --repo-root)
      shift
      [[ "$#" -gt 0 ]] || {
        usage
        exit 1
      }
      repo_root="$1"
      ;;
    --no-reload)
      reload=false
      ;;
    --help|-h)
      usage
      exit 0
      ;;
    -*)
      printf 'Unknown option: %s\n' "$1" >&2
      usage
      exit 1
      ;;
    *)
      if [[ -n "$palette_name" ]]; then
        printf 'Only one palette name can be provided.\n' >&2
        exit 1
      fi
      palette_name="$1"
      ;;
  esac
  shift
done

[[ -n "$palette_name" ]] || {
  usage
  exit 1
}

if [[ -n "$repo_root" ]]; then
  config_root="${repo_root%/}/config"
else
  config_root="${XDG_CONFIG_HOME:-$HOME/.config}"
fi

palette_file="${config_root}/palettes/${palette_name}.json"
theme_dir="${config_root}/theme"
hypr_theme_dir="${config_root}/hypr/modules/theme"
hypr_config_dir="${config_root}/hypr"
quickshell_theme_dir="${config_root}/quickshell/theme"
mako_config="${config_root}/mako/config"

[[ -f "$palette_file" ]] || {
  printf 'Palette not found: %s\n' "$palette_file" >&2
  exit 1
}

require_color() {
  local key="$1"
  local value
  value="$(jq -r --arg key "$key" '.[$key] // empty' "$palette_file")"
  if [[ ! "$value" =~ ^#[0-9a-fA-F]{6}$ ]]; then
    printf 'Invalid or missing color "%s" in %s\n' "$key" "$palette_file" >&2
    exit 1
  fi
  printf '%s\n' "$value"
}

strip_hash() {
  printf '%s\n' "${1#"#"}"
}

background="$(require_color background)"
sidebar="$(require_color sidebar)"
surface="$(require_color surface)"
hover="$(require_color hover)"
border="$(require_color border)"
accent="$(require_color accent)"
accent_hover="$(require_color accent_hover)"
accent_active="$(require_color accent_active)"
text="$(require_color text)"
text_secondary="$(require_color text_secondary)"
text_disabled="$(require_color text_disabled)"
success="$(require_color success)"
warning="$(require_color warning)"
error="$(require_color error)"
info="$(require_color info)"

mkdir -p "$theme_dir" "$hypr_theme_dir" "$hypr_config_dir" "$quickshell_theme_dir" "$(dirname "$mako_config")"

cat > "${theme_dir}/colors.css" <<EOF
@define-color background ${background};
@define-color background_alpha ${background}dd;
@define-color sidebar ${sidebar};
@define-color surface ${surface};
@define-color hover ${hover};
@define-color border ${border};
@define-color accent ${accent};
@define-color accent_hover ${accent_hover};
@define-color accent_active ${accent_active};
@define-color text ${text};
@define-color text_secondary ${text_secondary};
@define-color text_disabled ${text_disabled};
@define-color success ${success};
@define-color warning ${warning};
@define-color error ${error};
@define-color info ${info};
EOF

cat > "${theme_dir}/colors.rasi" <<EOF
* {
  background: ${background}ee;
  sidebar: ${sidebar};
  surface: ${surface};
  surface-hover: ${hover};
  border: ${border};
  accent: ${accent};
  accent-hover: ${accent_hover};
  accent-active: ${accent_active};
  text: ${text};
  muted: ${text_secondary};
  disabled: ${text_disabled};
  success: ${success};
  warning: ${warning};
  danger: ${error};
  info: ${info};
}
EOF

cat > "${theme_dir}/colors-kitty.conf" <<EOF
foreground ${text}
background ${background}
selection_foreground ${background}
selection_background ${accent}

cursor ${accent}
cursor_text_color ${background}
url_color ${accent_hover}

active_border_color ${accent}
inactive_border_color ${border}
bell_border_color ${error}
visual_bell_color none

wayland_titlebar_color ${background}
tab_bar_background ${background}
active_tab_foreground ${background}
active_tab_background ${accent}
inactive_tab_foreground ${text_secondary}
inactive_tab_background ${surface}

color0 ${background}
color1 ${error}
color2 ${success}
color3 ${accent}
color4 ${info}
color5 ${accent_hover}
color6 ${text_secondary}
color7 ${text}

color8 ${text_disabled}
color9 ${error}
color10 ${success}
color11 ${warning}
color12 ${info}
color13 ${accent_hover}
color14 ${text_secondary}
color15 #fff4ed
EOF

cat > "${hypr_theme_dir}/colors.lua" <<EOF
local colors = {
    background = "${background}",
    sidebar = "${sidebar}",
    surface = "${surface}",
    hover = "${hover}",
    border = "${border}",
    accent = "${accent}",
    accent_hover = "${accent_hover}",
    accent_active = "${accent_active}",
    text = "${text}",
    text_secondary = "${text_secondary}",
    text_disabled = "${text_disabled}",
    success = "${success}",
    warning = "${warning}",
    error = "${error}",
    info = "${info}",
}

function colors.rgba(name, alpha)
    local hex = colors[name]
    if not hex then
        return "rgba(ffffffff)"
    end
    return "rgba(" .. string.sub(hex, 2) .. (alpha or "ff") .. ")"
end

return colors
EOF

cat > "${hypr_config_dir}/colors-hyprlock.conf" <<EOF
\$background = rgba($(strip_hash "$background")ee)
\$background_dim = rgba($(strip_hash "$background")bb)
\$surface = rgba($(strip_hash "$surface")cc)
\$hover = rgba($(strip_hash "$hover")cc)
\$border = rgba($(strip_hash "$border")dd)
\$accent = rgba($(strip_hash "$accent")ff)
\$accent_hover = rgba($(strip_hash "$accent_hover")ff)
\$accent_active = rgba($(strip_hash "$accent_active")ff)
\$text = rgba($(strip_hash "$text")ff)
\$text_secondary = rgba($(strip_hash "$text_secondary")ff)
\$text_disabled = rgba($(strip_hash "$text_disabled")ff)
\$success = rgba($(strip_hash "$success")ff)
\$warning = rgba($(strip_hash "$warning")ff)
\$error = rgba($(strip_hash "$error")ff)
\$info = rgba($(strip_hash "$info")ff)
EOF

cat > "${quickshell_theme_dir}/ColorPalette.qml" <<EOF
import QtQuick

QtObject {
    readonly property color background: "${background}"
    readonly property color sidebar: "${sidebar}"
    readonly property color surface: "${surface}"
    readonly property color hover: "${hover}"
    readonly property color border: "${border}"
    readonly property color accent: "${accent}"
    readonly property color accentHover: "${accent_hover}"
    readonly property color accentActive: "${accent_active}"
    readonly property color text: "${text}"
    readonly property color textSecondary: "${text_secondary}"
    readonly property color textDisabled: "${text_disabled}"
    readonly property color success: "${success}"
    readonly property color warning: "${warning}"
    readonly property color error: "${error}"
    readonly property color info: "${info}"
}
EOF

cat > "$mako_config" <<EOF
font=Fira Sans Semibold 10
background-color=${background}dd
text-color=${text}
border-color=${accent}
progress-color=over ${accent}

width=360
height=120
margin=12
padding=12
border-size=1
border-radius=10

default-timeout=5000
ignore-timeout=0

anchor=top-right
layer=overlay
max-visible=5
sort=-time

[urgency=low]
default-timeout=3000
border-color=${border}

[urgency=high]
default-timeout=0
border-color=${error}
EOF

printf '%s\n' "$palette_name" > "${theme_dir}/current-palette"

if [[ "$reload" == true && -z "$repo_root" ]]; then
  if pgrep -x waybar >/dev/null 2>&1; then
    pkill -SIGUSR2 waybar || true
  fi
  if command -v hyprctl >/dev/null 2>&1; then
    hyprctl reload || true
  fi
  if pgrep -x mako >/dev/null 2>&1; then
    pkill -x mako || true
    mako >/dev/null 2>&1 &
  fi
fi

printf 'Applied palette: %s\n' "$palette_name"
