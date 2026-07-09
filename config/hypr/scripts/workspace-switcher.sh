#!/usr/bin/env bash
set -Eeuo pipefail

active_workspace="$(hyprctl activeworkspace -j | jq -r '.id')"
workspaces_json="$(hyprctl workspaces -j)"

menu="$(
  for workspace in 1 2 3 4 5 6 7 8 9 10; do
    windows="$(jq -r --argjson id "$workspace" '.[] | select(.id == $id) | .windows // 0' <<<"$workspaces_json")"
    windows="${windows:-0}"
    if [[ "$workspace" == "$active_workspace" ]]; then
      printf '* %s  %s windows\n' "$workspace" "$windows"
    else
      printf '  %s  %s windows\n' "$workspace" "$windows"
    fi
  done
)"

selected="$(printf '%s\n' "$menu" | rofi -dmenu -replace -i -p "workspace" -config "$HOME/.config/rofi/workspace.rasi")"
[[ -n "$selected" ]] || exit 0

target="$(awk '{print $1 == "*" ? $2 : $1}' <<<"$selected")"
[[ "$target" =~ ^[0-9]+$ ]] || exit 1

hyprctl dispatch workspace "$target"
