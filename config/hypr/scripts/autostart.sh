#!/usr/bin/env bash
set -Eeuo pipefail

state_dir="${XDG_STATE_HOME:-${HOME}/.local/state}/hyprland-lite"
log_file="${state_dir}/autostart.log"

mkdir -p "${state_dir}"
: > "${log_file}"

log() {
  printf '[%s] %s\n' "$(date -Is)" "$*" >> "${log_file}"
}

run_bg() {
  local name="$1"
  shift

  log "start: ${name}: $*"
  "$@" >> "${log_file}" 2>&1 &
}

run_shell_bg() {
  local name="$1"
  local command="$2"

  log "start: ${name}: ${command}"
  bash -lc "${command}" >> "${log_file}" 2>&1 &
}

run_once() {
  local process="$1"
  local name="$2"
  shift 2

  if pgrep -x "${process}" >/dev/null 2>&1; then
    log "skip: ${name} already running"
    return 0
  fi

  run_bg "${name}" "$@"
}

run_once_shell() {
  local process="$1"
  local name="$2"
  local command="$3"

  if pgrep -x "${process}" >/dev/null 2>&1; then
    log "skip: ${name} already running"
    return 0
  fi

  run_shell_bg "${name}" "${command}"
}

run_if_command() {
  local command_name="$1"
  local name="$2"
  shift 2

  if command -v "${command_name}" >/dev/null 2>&1; then
    run_bg "${name}" "$@"
  else
    log "skip: ${name}: missing command ${command_name}"
  fi
}

run_once_if_command() {
  local command_name="$1"
  local process="$2"
  local name="$3"
  shift 3

  if command -v "${command_name}" >/dev/null 2>&1; then
    run_once "${process}" "${name}" "$@"
  else
    log "skip: ${name}: missing command ${command_name}"
  fi
}

log "autostart begin"

dbus-update-activation-environment --systemd WAYLAND_DISPLAY XDG_CURRENT_DESKTOP XDG_SESSION_TYPE >> "${log_file}" 2>&1 || true

if [[ -x /usr/lib/polkit-gnome/polkit-gnome-authentication-agent-1 ]]; then
  run_once "polkit-gnome-authentication-agent-1" "polkit" /usr/lib/polkit-gnome/polkit-gnome-authentication-agent-1
else
  log "skip: polkit: missing /usr/lib/polkit-gnome/polkit-gnome-authentication-agent-1"
fi

run_once "waybar" "waybar" waybar -c "${HOME}/.config/waybar/config.jsonc" -s "${HOME}/.config/waybar/style.css"
run_once "mako" "mako" mako

if [[ -x "${HOME}/.config/hypr/scripts/wallpaper.sh" ]]; then
  run_shell_bg "wallpaper restore" "${HOME}/.config/hypr/scripts/wallpaper.sh --restore"
else
  log "skip: wallpaper restore: missing executable script"
fi

run_once_if_command "qs" "qs" "quickshell" qs
run_once "hypridle" "hypridle" hypridle

if pgrep -f 'wl-paste --watch cliphist store' >/dev/null 2>&1; then
  log "skip: clipboard watcher already running"
else
  run_shell_bg "clipboard watcher" "wl-paste --watch cliphist store"
fi

if command -v hyprshade >/dev/null 2>&1; then
  hyprshade on vibrance >> "${log_file}" 2>&1 || log "warn: hyprshade vibrance failed"
else
  log "skip: hyprshade: missing command"
fi

log "autostart end"
