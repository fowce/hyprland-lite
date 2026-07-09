#!/usr/bin/env bash
set -Eeuo pipefail

PROJECT_NAME="hyprland-lite"
UNINSTALL_BASE="${HOME}/.config-uninstalled/${PROJECT_NAME}"
STATE_DIR="${HOME}/.local/state/${PROJECT_NAME}"
TIMESTAMP="$(date +%Y%m%d-%H%M%S)"
LOG_FILE="${STATE_DIR}/uninstall-${TIMESTAMP}.log"

ACTION=""
DRY_RUN=false
VERBOSE=false

CONFIG_TARGETS=(
  "hypr"
  "waybar"
  "rofi"
  "mako"
  "kitty"
  "zsh"
  "fastfetch"
  "quickshell"
  "palettes"
  "theme"
  "wallpapers"
)

HOME_TARGETS=(
  ".zshrc"
)

usage() {
  cat <<EOF
Usage: ./uninstall.sh [ACTION] [OPTIONS]

Actions:
  --dry-run       Show what would be moved without changing files.
  --uninstall     Move managed config targets into a timestamped backup.
  --help          Show this help.

Options:
  --verbose       Print extra details.

Examples:
  ./uninstall.sh --dry-run
  ./uninstall.sh --uninstall

This script does not delete files. It moves target paths into:
  ~/.config-uninstalled/hyprland-lite/<timestamp>
EOF
}

log() {
  mkdir -p "${STATE_DIR}"
  printf '%s\n' "$*" | tee -a "${LOG_FILE}" >/dev/null
}

say() {
  printf '%s\n' "$*"
  log "$*"
}

debug() {
  if [[ "${VERBOSE}" == true ]]; then
    say "DEBUG: $*"
  fi
}

die() {
  say "ERROR: $*"
  exit 1
}

confirm() {
  local prompt="$1"
  local answer
  read -r -p "${prompt} [y/N] " answer
  [[ "${answer}" == "y" || "${answer}" == "Y" || "${answer}" == "yes" || "${answer}" == "YES" ]]
}

run_cmd() {
  say "+ $*"
  if [[ "${DRY_RUN}" == true ]]; then
    return 0
  fi
  "$@"
}

require_not_root() {
  if [[ "${EUID}" -eq 0 ]]; then
    die "Do not run this script as root."
  fi
}

safe_under_home() {
  local path="$1"
  [[ "${path}" == "${HOME}" || "${path}" == "${HOME}/"* ]]
}

destination_for_config_target() {
  local name="$1"
  printf '%s/.config/%s\n' "${HOME}" "${name}"
}

append_manifest() {
  local uninstall_dir="$1"
  shift
  if [[ "${DRY_RUN}" == false ]]; then
    printf '%s\n' "$*" >> "${uninstall_dir}/manifest.txt"
  fi
}

move_target() {
  local uninstall_dir="$1"
  local label="$2"
  local target="$3"
  local archived="${uninstall_dir}/${label}"

  safe_under_home "${target}" || die "Refusing to move path outside HOME: ${target}"

  if [[ -e "${target}" || -L "${target}" ]]; then
    run_cmd mkdir -p "$(dirname -- "${archived}")"
    run_cmd mv -- "${target}" "${archived}"
    append_manifest "${uninstall_dir}" "MOVED|${target}|${label}"
    if [[ "${DRY_RUN}" == true ]]; then
      say "Would move target aside: ${target}"
    else
      say "Moved target aside: ${target}"
    fi
  else
    append_manifest "${uninstall_dir}" "MISSING|${target}|${label}"
    say "No target found: ${target}"
  fi
}

print_plan() {
  local name home_target

  say "Uninstall mode moves target paths into a timestamped backup."
  say "It does not delete files and does not install or restore packages."
  say "Targets:"

  for name in "${CONFIG_TARGETS[@]}"; do
    say "  $(destination_for_config_target "${name}")"
  done

  for home_target in "${HOME_TARGETS[@]}"; do
    say "  ${HOME}/${home_target}"
  done
}

uninstall_targets() {
  local uninstall_dir="${UNINSTALL_BASE}/${TIMESTAMP}"
  local name home_target

  say "Creating uninstall backup: ${uninstall_dir}"
  run_cmd mkdir -p "${uninstall_dir}/config" "${uninstall_dir}/home"

  if [[ "${DRY_RUN}" == false ]]; then
    : > "${uninstall_dir}/manifest.txt"
    append_manifest "${uninstall_dir}" "UNINSTALL_CREATED|$(date -Is)"
  fi

  for name in "${CONFIG_TARGETS[@]}"; do
    move_target "${uninstall_dir}" "config/${name}" "$(destination_for_config_target "${name}")"
  done

  for home_target in "${HOME_TARGETS[@]}"; do
    move_target "${uninstall_dir}" "home/${home_target}" "${HOME}/${home_target}"
  done

  if [[ "${DRY_RUN}" == true ]]; then
    cat <<EOF

Dry run complete.

No files were moved.

Planned uninstall backup:
  ${uninstall_dir}
EOF
  else
    cat <<EOF

Uninstall move complete.

Files were moved into:
  ${uninstall_dir}

To restore from this backup with the switch helper:
  ./switch-config.sh --to backup --backup ${uninstall_dir}

Log:
  ${LOG_FILE}
EOF
  fi
}

parse_args() {
  if [[ "$#" -eq 0 ]]; then
    usage
    exit 0
  fi

  while [[ "$#" -gt 0 ]]; do
    case "$1" in
      --dry-run)
        ACTION="uninstall"
        DRY_RUN=true
        ;;
      --uninstall)
        ACTION="uninstall"
        ;;
      --verbose)
        VERBOSE=true
        ;;
      --help|-h)
        usage
        exit 0
        ;;
      *)
        die "Unknown argument: $1"
        ;;
    esac
    shift
  done
}

main() {
  parse_args "$@"
  require_not_root
  mkdir -p "${STATE_DIR}"
  say "${PROJECT_NAME} uninstall started at $(date -Is)"

  case "${ACTION}" in
    uninstall)
      print_plan
      if [[ "${DRY_RUN}" == false ]]; then
        say "This will move config targets out of ~/.config and HOME."
        say "It will not reload or kill the current Hyprland session."
        if ! confirm "Move these targets into an uninstall backup now?"; then
          say "Uninstall cancelled."
          exit 0
        fi
      fi
      uninstall_targets
      ;;
    *)
      usage
      ;;
  esac
}

trap 'die "Uninstall failed at line ${LINENO}. Check log: ${LOG_FILE}"' ERR
main "$@"
