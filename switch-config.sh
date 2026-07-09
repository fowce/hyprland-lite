#!/usr/bin/env bash
set -Eeuo pipefail

PROJECT_NAME="hyprland-lite"
SWITCHBACK_BASE="${HOME}/.config-switchbacks/${PROJECT_NAME}"
STATE_DIR="${HOME}/.local/state/${PROJECT_NAME}"
TIMESTAMP="$(date +%Y%m%d-%H%M%S)"
LOG_FILE="${STATE_DIR}/switch-${TIMESTAMP}.log"

ACTION=""
PROFILE=""
BACKUP_PATH=""
DRY_RUN=false
VERBOSE=false
CREATED_SWITCHBACK_DIR=""

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
  ".zshrc:config/zsh/.zshrc"
)

usage() {
  cat <<EOF
Usage: ./switch-config.sh [ACTION] [OPTIONS]

Actions:
  --list                         List available config sources.
  --to repo                      Switch to this repository config.
  --to config-backup             Switch from ~/.config.backup where matching paths exist.
  --to backup --backup PATH      Switch from an installer/switch backup path.
  --help                         Show this help.

Options:
  --backup PATH                  Backup directory used with --to backup.
  --dry-run                      Show actions without changing files.
  --verbose                      Print extra details.

Examples:
  ./switch-config.sh --list
  ./switch-config.sh --to repo --dry-run
  ./switch-config.sh --to repo
  ./switch-config.sh --to config-backup --dry-run
  ./switch-config.sh --to backup --backup ~/.config-backups/hyprland-lite/20260708-235900
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

repo_root() {
  local script_dir
  script_dir="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd -P)"
  printf '%s\n' "${script_dir}"
}

safe_under_home() {
  local path="$1"
  [[ "${path}" == "${HOME}" || "${path}" == "${HOME}/"* ]]
}

require_not_root() {
  if [[ "${EUID}" -eq 0 ]]; then
    die "Do not run this script as root."
  fi
}

destination_for_config_target() {
  local name="$1"
  printf '%s/.config/%s\n' "${HOME}" "${name}"
}

source_for_config_target() {
  local root="$1"
  local name="$2"

  case "${PROFILE}" in
    repo)
      printf '%s/config/%s\n' "${root}" "${name}"
      ;;
    config-backup)
      printf '%s/.config.backup/%s\n' "${HOME}" "${name}"
      ;;
    backup)
      printf '%s/config/%s\n' "${BACKUP_PATH}" "${name}"
      ;;
    *)
      die "Unknown profile: ${PROFILE}"
      ;;
  esac
}

source_for_home_target() {
  local root="$1"
  local home_dst="$2"
  local home_src_rel="$3"

  case "${PROFILE}" in
    repo)
      printf '%s/%s\n' "${root}" "${home_src_rel}"
      ;;
    config-backup)
      printf '%s/.config.backup/%s\n' "${HOME}" "${home_dst}"
      ;;
    backup)
      printf '%s/home/%s\n' "${BACKUP_PATH}" "${home_dst}"
      ;;
    *)
      die "Unknown profile: ${PROFILE}"
      ;;
  esac
}

list_available() {
  local root backup_dir
  root="$(repo_root)"

  printf 'Current live config:\n'
  printf '  %s/.config\n' "${HOME}"
  printf '\nRepository config:\n'
  printf '  %s/config\n' "${root}"

  if [[ -d "${HOME}/.config.backup" ]]; then
    printf '\nLegacy backup config:\n'
    printf '  %s/.config.backup\n' "${HOME}"
  else
    printf '\nLegacy backup config:\n'
    printf '  missing: %s/.config.backup\n' "${HOME}"
  fi

  printf '\nInstall backups:\n'
  if [[ -d "${HOME}/.config-backups/${PROJECT_NAME}" ]]; then
    find "${HOME}/.config-backups/${PROJECT_NAME}" -maxdepth 1 -mindepth 1 -type d -print | sort
  else
    printf '  none found\n'
  fi

  printf '\nSwitchback backups:\n'
  if [[ -d "${SWITCHBACK_BASE}" ]]; then
    find "${SWITCHBACK_BASE}" -maxdepth 1 -mindepth 1 -type d -print | sort
  else
    printf '  none found\n'
  fi

  printf '\nUninstall backups:\n'
  if [[ -d "${HOME}/.config-uninstalled/${PROJECT_NAME}" ]]; then
    find "${HOME}/.config-uninstalled/${PROJECT_NAME}" -maxdepth 1 -mindepth 1 -type d -print | sort
  else
    printf '  none found\n'
  fi

  printf '\nRepository readiness:\n'
  if [[ -f "${root}/.install-ready" ]]; then
    printf '  .install-ready: %s\n' "$(tr -d '[:space:]' < "${root}/.install-ready")"
  else
    printf '  .install-ready: missing\n'
  fi

  if [[ -n "${BACKUP_PATH}" ]]; then
    backup_dir="${BACKUP_PATH/#\~/${HOME}}"
    printf '\nSelected backup path:\n'
    printf '  %s\n' "${backup_dir}"
  fi
}

validate_profile() {
  local root="$1"

  case "${PROFILE}" in
    repo)
      [[ -f "${root}/.install-ready" ]] || die "Missing ${root}/.install-ready."
      [[ "$(tr -d '[:space:]' < "${root}/.install-ready")" == "ready" ]] || die "Repository config is not marked ready."
      [[ -d "${root}/config" ]] || die "Repository config directory is missing: ${root}/config"
      ;;
    config-backup)
      [[ -d "${HOME}/.config.backup" ]] || die "Legacy backup directory is missing: ${HOME}/.config.backup"
      ;;
    backup)
      [[ -n "${BACKUP_PATH}" ]] || die "--to backup requires --backup PATH"
      BACKUP_PATH="${BACKUP_PATH/#\~/${HOME}}"
      [[ -d "${BACKUP_PATH}" ]] || die "Backup path does not exist: ${BACKUP_PATH}"
      [[ -d "${BACKUP_PATH}/config" || -d "${BACKUP_PATH}/home" ]] || die "Backup path does not look like a config backup: ${BACKUP_PATH}"
      ;;
    *)
      die "Use --to repo, --to config-backup, or --to backup."
      ;;
  esac
}

copy_preserve() {
  local src="$1"
  local dst="$2"
  local parent
  parent="$(dirname -- "${dst}")"
  run_cmd mkdir -p "${parent}"
  run_cmd cp -aP -- "${src}" "${dst}"
}

append_manifest() {
  local switchback_dir="$1"
  shift
  if [[ "${DRY_RUN}" == false ]]; then
    printf '%s\n' "$*" >> "${switchback_dir}/manifest.txt"
  fi
}

backup_one_path() {
  local switchback_dir="$1"
  local label="$2"
  local target="$3"
  local backup_path="${switchback_dir}/${label}"

  safe_under_home "${target}" || die "Refusing to back up path outside HOME: ${target}"

  if [[ -e "${target}" || -L "${target}" ]]; then
    run_cmd mkdir -p "$(dirname -- "${backup_path}")"
    if [[ "${DRY_RUN}" == false ]]; then
      cp -aP -- "${target}" "${backup_path}"
      append_manifest "${switchback_dir}" "PATH|${target}|${label}"
    fi
    say "Backed up current path: ${target}"
  else
    append_manifest "${switchback_dir}" "MISSING|${target}|${label}"
    say "No current path to back up: ${target}"
  fi
}

create_switchback() {
  local switchback_dir="${SWITCHBACK_BASE}/${TIMESTAMP}"
  local name target pair home_dst

  CREATED_SWITCHBACK_DIR="${switchback_dir}"
  say "Creating pre-switch backup: ${switchback_dir}"
  run_cmd mkdir -p "${switchback_dir}/config" "${switchback_dir}/home"

  if [[ "${DRY_RUN}" == false ]]; then
    : > "${switchback_dir}/manifest.txt"
    append_manifest "${switchback_dir}" "SWITCHBACK_CREATED|$(date -Is)"
    append_manifest "${switchback_dir}" "PROFILE|${PROFILE}"
  fi

  for name in "${CONFIG_TARGETS[@]}"; do
    target="$(destination_for_config_target "${name}")"
    backup_one_path "${switchback_dir}" "config/${name}" "${target}"
  done

  for pair in "${HOME_TARGETS[@]}"; do
    home_dst="${pair%%:*}"
    backup_one_path "${switchback_dir}" "home/${home_dst}" "${HOME}/${home_dst}"
  done

  if [[ "${DRY_RUN}" == true ]]; then
    say "Pre-switch backup plan ready: ${switchback_dir}"
  else
    say "Pre-switch backup ready: ${switchback_dir}"
  fi
}

archive_existing_for_replace() {
  local switchback_dir="$1"
  local label="$2"
  local target="$3"
  local archive_path="${switchback_dir}/replaced/${label}"

  safe_under_home "${target}" || die "Refusing to replace path outside HOME: ${target}"

  if [[ -e "${target}" || -L "${target}" ]]; then
    run_cmd mkdir -p "$(dirname -- "${archive_path}")"
    run_cmd mv -- "${target}" "${archive_path}"
    say "Moved current target aside: ${target} -> ${archive_path}"
  fi
}

copy_profile() {
  local root="$1"
  local switchback_dir="$2"
  local name src dst pair home_dst home_src_rel home_src

  for name in "${CONFIG_TARGETS[@]}"; do
    src="$(source_for_config_target "${root}" "${name}")"
    dst="$(destination_for_config_target "${name}")"

    if [[ -e "${src}" || -L "${src}" ]]; then
      archive_existing_for_replace "${switchback_dir}" "config/${name}" "${dst}"
      copy_preserve "${src}" "${dst}"
      if [[ "${DRY_RUN}" == true ]]; then
        say "Would switch: ${dst}"
      else
        say "Switched: ${dst}"
      fi
    else
      say "Source missing, keeping current target unchanged: ${src}"
    fi
  done

  for pair in "${HOME_TARGETS[@]}"; do
    home_dst="${pair%%:*}"
    home_src_rel="${pair#*:}"
    home_src="$(source_for_home_target "${root}" "${home_dst}" "${home_src_rel}")"

    if [[ -e "${home_src}" || -L "${home_src}" ]]; then
      archive_existing_for_replace "${switchback_dir}" "home/${home_dst}" "${HOME}/${home_dst}"
      copy_preserve "${home_src}" "${HOME}/${home_dst}"
      if [[ "${DRY_RUN}" == true ]]; then
        say "Would switch: ${HOME}/${home_dst}"
      else
        say "Switched: ${HOME}/${home_dst}"
      fi
    else
      say "Source missing, keeping current home target unchanged: ${home_src}"
    fi
  done
}

print_plan() {
  local root="$1"
  local name src dst pair home_dst home_src_rel home_src

  say "Switch profile: ${PROFILE}"
  say "Repository root: ${root}"
  say "No running session will be killed or reloaded by this script."
  say "Targets:"

  for name in "${CONFIG_TARGETS[@]}"; do
    src="$(source_for_config_target "${root}" "${name}")"
    dst="$(destination_for_config_target "${name}")"
    say "  ${src} -> ${dst}"
  done

  for pair in "${HOME_TARGETS[@]}"; do
    home_dst="${pair%%:*}"
    home_src_rel="${pair#*:}"
    home_src="$(source_for_home_target "${root}" "${home_dst}" "${home_src_rel}")"
    say "  ${home_src} -> ${HOME}/${home_dst}"
  done
}

parse_args() {
  if [[ "$#" -eq 0 ]]; then
    usage
    exit 0
  fi

  while [[ "$#" -gt 0 ]]; do
    case "$1" in
      --list)
        ACTION="list"
        ;;
      --to)
        ACTION="switch"
        shift
        [[ "$#" -gt 0 ]] || die "--to requires a profile"
        PROFILE="$1"
        ;;
      --backup)
        shift
        [[ "$#" -gt 0 ]] || die "--backup requires a path"
        BACKUP_PATH="$1"
        ;;
      --dry-run)
        DRY_RUN=true
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
  local root switchback_dir

  parse_args "$@"

  if [[ "${ACTION}" == "list" ]]; then
    list_available
    exit 0
  fi

  require_not_root
  mkdir -p "${STATE_DIR}"
  root="$(repo_root)"

  validate_profile "${root}"
  say "${PROJECT_NAME} switch started at $(date -Is)"
  print_plan "${root}"

  if [[ "${DRY_RUN}" == false ]]; then
    say "A pre-switch backup will be created before files are copied."
    say "Rollback source will be printed after the switch."
    if ! confirm "Switch config now?"; then
      say "Switch cancelled."
      exit 0
    fi
  fi

  create_switchback
  switchback_dir="${CREATED_SWITCHBACK_DIR}"
  copy_profile "${root}" "${switchback_dir}"

  if [[ "${DRY_RUN}" == true ]]; then
    cat <<EOF

Dry run complete.

No files were copied, moved, removed, killed, or reloaded.

Planned rollback source:
  ${switchback_dir}

Log:
  ${LOG_FILE}
EOF
  else
    cat <<EOF

Switch complete.

Rollback source:
  ${switchback_dir}

To switch back from this backup:
  ./switch-config.sh --to backup --backup ${switchback_dir}

Log:
  ${LOG_FILE}

Restart Hyprland manually when you are ready. This script does not kill or reload
the current session.
EOF
  fi
}

trap 'die "Switch failed at line ${LINENO}. Check log: ${LOG_FILE}"' ERR
main "$@"
