#!/usr/bin/env bash
set -Eeuo pipefail

PROJECT_NAME="hyprland-lite"
BACKUP_BASE="${HOME}/.config-backups/${PROJECT_NAME}"
STATE_DIR="${HOME}/.local/state/${PROJECT_NAME}"
TIMESTAMP="$(date +%Y%m%d-%H%M%S)"
LOG_FILE="${STATE_DIR}/install-${TIMESTAMP}.log"

ACTION=""
DRY_RUN=false
VERBOSE=false
RESTORE_PATH=""
INSTALL_PACKAGES=false
CONFIGURE_TUN=false
CREATED_BACKUP_DIR=""
AUR_HELPER=""

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

PACKAGE_REQUIRED=(
  "hyprland"
  "waybar"
  "rofi"
  "kitty"
  "zsh"
  "fastfetch"
  "fzf"
  "eza"
  "zsh-autosuggestions"
  "zsh-syntax-highlighting"
  "ttf-jetbrains-mono-nerd"
  "ttf-fira-sans"
  "ttf-font-awesome"
  "jq"
  "polkit-gnome"
  "xdg-desktop-portal-hyprland"
  "pipewire"
  "wireplumber"
  "networkmanager"
  "pavucontrol"
  "cliphist"
  "wl-clipboard"
  "hyprlock"
  "hypridle"
  "mako"
  "brightnessctl"
  "playerctl"
  "hyprpicker"
  "hyprsunset"
  "hyprshade"
  "grim"
  "slurp"
  "imagemagick"
  "swww"
  "quickshell"
)

PACKAGE_OPTIONAL=(
  "libnotify"
  "nwg-look"
  "qt6ct"
  "tesseract"
  "tesseract-data-eng"
  "nautilus"
  "zen-browser"
)

COMMAND_REQUIRED=(
  "hyprctl"
  "waybar"
  "rofi"
  "kitty"
  "zsh"
  "fastfetch"
  "fzf"
  "eza"
  "jq"
  "wpctl"
  "nmtui"
  "pavucontrol"
  "cliphist"
  "wl-copy"
  "wl-paste"
  "hyprlock"
  "hypridle"
  "mako"
  "brightnessctl"
  "playerctl"
  "hyprpicker"
  "hyprsunset"
  "hyprshade"
  "grim"
  "slurp"
  "magick"
  "qs"
)

COMMAND_OPTIONAL=(
  "notify-send"
  "nwg-look"
  "qt6ct"
  "tesseract"
  "nautilus"
  "zen-browser"
)

package_for_command() {
  case "$1" in
    hyprctl) printf '%s\n' "hyprland" ;;
    wpctl) printf '%s\n' "wireplumber" ;;
    nmtui) printf '%s\n' "networkmanager" ;;
    wl-copy|wl-paste) printf '%s\n' "wl-clipboard" ;;
    magick) printf '%s\n' "imagemagick" ;;
    qs) printf '%s\n' "quickshell" ;;
    *) printf '%s\n' "$1" ;;
  esac
}

wallpaper_backend_available() {
  if command -v swww >/dev/null 2>&1 && command -v swww-daemon >/dev/null 2>&1; then
    return 0
  fi

  if command -v awww >/dev/null 2>&1 && command -v awww-daemon >/dev/null 2>&1; then
    return 0
  fi

  return 1
}

append_unique() {
  local value="$1"
  shift
  local item

  for item in "$@"; do
    [[ "${item}" != "${value}" ]] || return 1
  done

  printf '%s\n' "${value}"
}

usage() {
  cat <<EOF
Usage: ./install.sh [ACTION] [OPTIONS]

Actions:
  --check                 Check system and dependency status only.
  --dry-run               Show what would happen without changing files.
  --backup-only           Create a backup of current config targets only.
  --install               Backup current targets and install this config.
  --restore PATH          Restore from a backup directory.
  --help                  Show this help.

Options:
  --install-packages      Ask before installing missing pacman/AUR packages.
  --configure-tun         Ask before configuring tun autoload for VPN.
  --verbose               Print extra details.

Examples:
  ./install.sh --check
  ./install.sh --dry-run
  ./install.sh --install
  ./install.sh --install --install-packages --configure-tun
  ./install.sh --restore ~/.config-backups/hyprland-lite/20260708-235900
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
    die "Do not run this installer as root. It only asks for sudo when needed."
  fi
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

check_arch() {
  if [[ -r /etc/os-release ]]; then
    if ! grep -qi '^ID=arch\|^ID_LIKE=.*arch' /etc/os-release; then
      say "WARN: This system does not look like Arch Linux. Continuing checks only."
    fi
  else
    say "WARN: /etc/os-release is missing."
  fi
}

check_hyprland() {
  if command -v hyprctl >/dev/null 2>&1; then
    say "FOUND command: hyprctl"
  elif pacman -Q hyprland >/dev/null 2>&1; then
    say "FOUND package: hyprland"
  else
    say "MISSING: hyprland/hyprctl"
  fi
}

check_dependencies() {
  local missing_cmds=()
  local missing_pkgs=()
  local repair_pkgs=()
  local missing_optional_cmds=()
  local missing_optional_pkgs=()
  local cmd pkg

  say "Checking required commands..."
  for cmd in "${COMMAND_REQUIRED[@]}"; do
    if command -v "${cmd}" >/dev/null 2>&1; then
      debug "FOUND command: ${cmd} -> $(command -v "${cmd}")"
    else
      missing_cmds+=("${cmd}")
      say "MISSING command: ${cmd}"
      pkg="$(package_for_command "${cmd}")"
      if command -v pacman >/dev/null 2>&1 && pacman -Q "${pkg}" >/dev/null 2>&1; then
        if unique_value="$(append_unique "${pkg}" "${repair_pkgs[@]}")"; then
          repair_pkgs+=("${unique_value}")
        fi
        say "REPAIR package needed: ${pkg} is installed but command ${cmd} is missing"
      fi
    fi
  done

  if wallpaper_backend_available; then
    debug "FOUND wallpaper backend: swww/awww"
  else
    missing_cmds+=("swww-or-awww")
    say "MISSING command: swww or awww wallpaper backend"
    if command -v pacman >/dev/null 2>&1 && pacman -Q swww >/dev/null 2>&1; then
      if unique_value="$(append_unique "swww" "${repair_pkgs[@]}")"; then
        repair_pkgs+=("${unique_value}")
      fi
      say "REPAIR package needed: swww provider is installed but no swww/awww command pair is available"
    fi
  fi

  say "Checking optional/recommended commands..."
  for cmd in "${COMMAND_OPTIONAL[@]}"; do
    if command -v "${cmd}" >/dev/null 2>&1; then
      debug "FOUND optional command: ${cmd} -> $(command -v "${cmd}")"
    else
      missing_optional_cmds+=("${cmd}")
      say "WARN missing optional command: ${cmd}"
    fi
  done

  if command -v pacman >/dev/null 2>&1; then
    say "Checking required packages..."
    for pkg in "${PACKAGE_REQUIRED[@]}"; do
      if pacman -Q "${pkg}" >/dev/null 2>&1; then
        debug "FOUND package: ${pkg}"
      else
        missing_pkgs+=("${pkg}")
        say "MISSING package: ${pkg}"
      fi
    done

    say "Checking optional/recommended packages..."
    for pkg in "${PACKAGE_OPTIONAL[@]}"; do
      if pacman -Q "${pkg}" >/dev/null 2>&1; then
        debug "FOUND optional package: ${pkg}"
      else
        missing_optional_pkgs+=("${pkg}")
        say "WARN missing optional package: ${pkg}"
      fi
    done
  else
    say "WARN: pacman not found; skipping package checks."
  fi

  if [[ "${#missing_cmds[@]}" -eq 0 && "${#missing_pkgs[@]}" -eq 0 ]]; then
    say "Dependency check completed: no missing required commands/packages detected."
  fi

  if [[ "${#missing_optional_cmds[@]}" -gt 0 || "${#missing_optional_pkgs[@]}" -gt 0 ]]; then
    say "Optional dependency check completed with warnings. See docs/dependencies.md."
  fi

  if [[ "${INSTALL_PACKAGES}" == true && "${#missing_pkgs[@]}" -gt 0 ]]; then
    install_missing_required_packages "${missing_pkgs[@]}"
  fi

  if [[ "${INSTALL_PACKAGES}" == true && "${#repair_pkgs[@]}" -gt 0 ]]; then
    reinstall_required_packages "${repair_pkgs[@]}"
  fi
}

assert_required_commands_available() {
  local missing=()
  local cmd

  for cmd in "${COMMAND_REQUIRED[@]}"; do
    if ! command -v "${cmd}" >/dev/null 2>&1; then
      missing+=("${cmd}")
    fi
  done

  if ! wallpaper_backend_available; then
    missing+=("swww-or-awww")
  fi

  if [[ "${#missing[@]}" -gt 0 ]]; then
    say "ERROR: Required commands are still missing: ${missing[*]}"
    say "Install them first, or run: ./install.sh --install --install-packages"
    die "Refusing real install with missing required commands."
  fi
}

find_aur_helper() {
  local helper

  AUR_HELPER=""
  for helper in yay paru pikaur; do
    if command -v "${helper}" >/dev/null 2>&1; then
      AUR_HELPER="${helper}"
      return 0
    fi
  done

  return 1
}

bootstrap_yay_bin() {
  local build_dir="${TMPDIR:-/tmp}/${PROJECT_NAME}-yay-bin-${TIMESTAMP}"

  say "No AUR helper found."
  say "The installer can bootstrap yay-bin from AUR into: ${build_dir}"
  say "This requires sudo for pacman dependencies, then makepkg as the current user."

  if ! confirm "Bootstrap yay-bin AUR helper now?"; then
    say "AUR helper bootstrap skipped."
    return 1
  fi

  run_cmd sudo pacman -S --needed base-devel git
  run_cmd git clone https://aur.archlinux.org/yay-bin.git "${build_dir}"
  say "+ cd ${build_dir} && makepkg -si"
  if [[ "${DRY_RUN}" == false ]]; then
    (cd "${build_dir}" && makepkg -si)
  fi
}

ensure_aur_helper() {
  if find_aur_helper; then
    say "FOUND AUR helper: ${AUR_HELPER}"
    return 0
  fi

  bootstrap_yay_bin || return 1

  if find_aur_helper; then
    say "FOUND AUR helper: ${AUR_HELPER}"
    return 0
  fi

  die "AUR helper was not found after bootstrap attempt."
}

install_missing_required_packages() {
  say "Missing required packages: $*"

  if ensure_aur_helper; then
    if confirm "Install missing required packages with ${AUR_HELPER} -S --needed?"; then
      run_cmd "${AUR_HELPER}" -S --needed "$@"
    else
      say "Package installation skipped."
    fi
  else
    say "Package installation skipped because no AUR helper is available."
  fi
}

reinstall_required_packages() {
  say "Required packages with missing commands: $*"

  if ensure_aur_helper; then
    if confirm "Reinstall/repair these packages with ${AUR_HELPER} -S?"; then
      run_cmd "${AUR_HELPER}" -S "$@"
    else
      say "Package repair skipped."
    fi
  else
    say "Package repair skipped because no AUR helper is available."
  fi
}

check_disk_space() {
  local available_kb
  available_kb="$(df -Pk "${HOME}" | awk 'NR == 2 { print $4 }')"
  debug "Available space in HOME filesystem: ${available_kb} KiB"
  if [[ "${available_kb}" -lt 1048576 ]]; then
    say "WARN: Less than 1 GiB free in HOME filesystem. Backup may fail."
  fi
}

source_for_config_target() {
  local root="$1"
  local name="$2"
  printf '%s/config/%s\n' "${root}" "${name}"
}

destination_for_config_target() {
  local name="$1"
  printf '%s/.config/%s\n' "${HOME}" "${name}"
}

plan_changes() {
  local root="$1"
  local name src dst pair home_dst home_src_rel home_src

  say "Install mode: copy directories from repository into ~/.config and home files."
  say "Repository root: ${root}"
  say "Targets:"

  for name in "${CONFIG_TARGETS[@]}"; do
    src="$(source_for_config_target "${root}" "${name}")"
    dst="$(destination_for_config_target "${name}")"
    say "  ${src} -> ${dst}"
  done

  for pair in "${HOME_TARGETS[@]}"; do
    home_dst="${pair%%:*}"
    home_src_rel="${pair#*:}"
    home_src="${root}/${home_src_rel}"
    say "  ${home_src} -> ${HOME}/${home_dst}"
  done
}

validate_sources_for_install() {
  local root="$1"
  local name src pair home_src_rel home_src
  local missing=0

  if [[ ! -f "${root}/.install-ready" ]]; then
    if [[ "${DRY_RUN}" == true ]]; then
      say "WARN: Missing ${root}/.install-ready. Real install would be refused."
    else
      die "Missing ${root}/.install-ready. Refusing to install an unmarked config tree."
    fi
  fi

  if [[ -f "${root}/.install-ready" && "$(tr -d '[:space:]' < "${root}/.install-ready")" != "ready" ]]; then
    if [[ "${DRY_RUN}" == true ]]; then
      say "WARN: Config tree is not marked ready. Real install would be refused."
    else
      die "Config tree is not marked ready. Set .install-ready to 'ready' only after configs are complete and reviewed."
    fi
  fi

  for name in "${CONFIG_TARGETS[@]}"; do
    src="$(source_for_config_target "${root}" "${name}")"
    if [[ ! -e "${src}" ]]; then
      say "MISSING source: ${src}"
      missing=1
    fi
  done

  for pair in "${HOME_TARGETS[@]}"; do
    home_src_rel="${pair#*:}"
    home_src="${root}/${home_src_rel}"
    if [[ ! -e "${home_src}" ]]; then
      say "MISSING source: ${home_src}"
      missing=1
    fi
  done

  if [[ "${missing}" -ne 0 ]]; then
    die "Install sources are incomplete. Create config files first or run --backup-only/--check."
  fi
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
  local backup_dir="$1"
  shift
  printf '%s\n' "$*" >> "${backup_dir}/manifest.txt"
}

backup_one_path() {
  local backup_dir="$1"
  local label="$2"
  local target="$3"
  local backup_path="${backup_dir}/${label}"
  local parent link_value resolved copy_path

  safe_under_home "${target}" || die "Refusing to back up path outside HOME: ${target}"

  if [[ -L "${target}" ]]; then
    parent="$(dirname -- "${backup_path}")"
    run_cmd mkdir -p "${parent}"
    if [[ "${DRY_RUN}" == false ]]; then
      cp -aP -- "${target}" "${backup_path}"
      link_value="$(readlink -- "${target}")"
      append_manifest "${backup_dir}" "SYMLINK|${target}|${label}|${link_value}"
      resolved="$(readlink -f -- "${target}" || true)"
      if [[ -n "${resolved}" && -e "${resolved}" && "${resolved}" == "${HOME}/"* ]]; then
        copy_path="${backup_dir}/symlink-targets/${label}"
        mkdir -p "$(dirname -- "${copy_path}")"
        cp -a -- "${resolved}" "${copy_path}"
        append_manifest "${backup_dir}" "SYMLINK_TARGET_COPY|${target}|symlink-targets/${label}|${resolved}"
      fi
    fi
    if [[ "${DRY_RUN}" == true ]]; then
      say "Would back up symlink: ${target}"
    else
      say "Backed up symlink: ${target}"
    fi
  elif [[ -e "${target}" ]]; then
    parent="$(dirname -- "${backup_path}")"
    run_cmd mkdir -p "${parent}"
    if [[ "${DRY_RUN}" == false ]]; then
      cp -a -- "${target}" "${backup_path}"
      append_manifest "${backup_dir}" "PATH|${target}|${label}"
    fi
    if [[ "${DRY_RUN}" == true ]]; then
      say "Would back up path: ${target}"
    else
      say "Backed up path: ${target}"
    fi
  else
    if [[ "${DRY_RUN}" == false ]]; then
      append_manifest "${backup_dir}" "MISSING|${target}|${label}"
    fi
    say "No existing path to back up: ${target}"
  fi
}

create_backup() {
  local backup_dir="${BACKUP_BASE}/${TIMESTAMP}"
  local name target pair home_dst

  CREATED_BACKUP_DIR="${backup_dir}"
  if [[ "${DRY_RUN}" == true ]]; then
    say "Creating backup plan: ${backup_dir}"
  else
    say "Creating backup: ${backup_dir}"
  fi
  run_cmd mkdir -p "${backup_dir}/config" "${backup_dir}/home"

  if [[ "${DRY_RUN}" == false ]]; then
    : > "${backup_dir}/manifest.txt"
    append_manifest "${backup_dir}" "BACKUP_CREATED|$(date -Is)"
  fi

  for name in "${CONFIG_TARGETS[@]}"; do
    target="$(destination_for_config_target "${name}")"
    backup_one_path "${backup_dir}" "config/${name}" "${target}"
  done

  for pair in "${HOME_TARGETS[@]}"; do
    home_dst="${pair%%:*}"
    backup_one_path "${backup_dir}" "home/${home_dst}" "${HOME}/${home_dst}"
  done

  if [[ "${DRY_RUN}" == false && ! -s "${backup_dir}/manifest.txt" ]]; then
    die "Backup manifest was not created correctly: ${backup_dir}/manifest.txt"
  fi

  if [[ "${DRY_RUN}" == true ]]; then
    say "Backup plan ready: ${backup_dir}"
  else
    say "Backup ready: ${backup_dir}"
  fi
}

archive_existing_for_replace() {
  local backup_dir="$1"
  local label="$2"
  local target="$3"
  local archive_path="${backup_dir}/replaced/${label}"

  safe_under_home "${target}" || die "Refusing to replace path outside HOME: ${target}"

  if [[ -e "${target}" || -L "${target}" ]]; then
    run_cmd mkdir -p "$(dirname -- "${archive_path}")"
    run_cmd mv -- "${target}" "${archive_path}"
    if [[ "${DRY_RUN}" == true ]]; then
      say "Would move existing target aside: ${target} -> ${archive_path}"
    else
      say "Moved existing target aside: ${target} -> ${archive_path}"
    fi
  fi
}

install_configs() {
  local root="$1"
  local backup_dir="$2"
  local name src dst pair home_dst home_src_rel home_src

  validate_sources_for_install "${root}"

  for name in "${CONFIG_TARGETS[@]}"; do
    src="$(source_for_config_target "${root}" "${name}")"
    dst="$(destination_for_config_target "${name}")"
    archive_existing_for_replace "${backup_dir}" "config/${name}" "${dst}"
    copy_preserve "${src}" "${dst}"
    if [[ "${DRY_RUN}" == true ]]; then
      say "Would install: ${dst}"
    else
      say "Installed: ${dst}"
    fi
  done

  for pair in "${HOME_TARGETS[@]}"; do
    home_dst="${pair%%:*}"
    home_src_rel="${pair#*:}"
    home_src="${root}/${home_src_rel}"
    archive_existing_for_replace "${backup_dir}" "home/${home_dst}" "${HOME}/${home_dst}"
    copy_preserve "${home_src}" "${HOME}/${home_dst}"
    if [[ "${DRY_RUN}" == true ]]; then
      say "Would install: ${HOME}/${home_dst}"
    else
      say "Installed: ${HOME}/${home_dst}"
    fi
  done
}

restore_backup() {
  local backup_dir="$1"
  local restore_backup_dir="${BACKUP_BASE}/pre-restore-${TIMESTAMP}"
  local line kind target label backup_path

  [[ -d "${backup_dir}" ]] || die "Backup directory does not exist: ${backup_dir}"
  [[ -f "${backup_dir}/manifest.txt" ]] || die "Backup manifest not found: ${backup_dir}/manifest.txt"

  say "Restore source: ${backup_dir}"
  say "Current state will be moved aside to: ${restore_backup_dir}"

  if ! confirm "Restore this backup now?"; then
    say "Restore cancelled."
    return 0
  fi

  run_cmd mkdir -p "${restore_backup_dir}/replaced"

  while IFS='|' read -r kind target label _rest; do
    case "${kind}" in
      PATH|SYMLINK)
        backup_path="${backup_dir}/${label}"
        [[ -e "${backup_path}" || -L "${backup_path}" ]] || die "Backup item missing: ${backup_path}"
        archive_existing_for_replace "${restore_backup_dir}" "${label}" "${target}"
        copy_preserve "${backup_path}" "${target}"
        say "Restored: ${target}"
        ;;
      MISSING)
        if [[ -e "${target}" || -L "${target}" ]]; then
          archive_existing_for_replace "${restore_backup_dir}" "${label}" "${target}"
          say "Original path was missing; current path moved aside: ${target}"
        else
          say "Original path was missing and current path is also absent: ${target}"
        fi
        ;;
      BACKUP_CREATED|SYMLINK_TARGET_COPY|"")
        ;;
      *)
        say "WARN: Unknown manifest entry ignored: ${line}"
        ;;
    esac
  done < "${backup_dir}/manifest.txt"
}

configure_tun_autoload() {
  local target="/etc/modules-load.d/tun.conf"

  say "VPN tun autoload can be configured by writing ${target} with sudo."
  say "Rollback: sudo rm ${target}; sudo modprobe -r tun"

  if ! confirm "Configure tun autoload for VPN?"; then
    say "tun autoload skipped."
    return 0
  fi

  if [[ "${DRY_RUN}" == true ]]; then
    say "+ printf 'tun\\n' | sudo tee ${target}"
    say "+ sudo modprobe tun"
    return 0
  fi

  printf 'tun\n' | sudo tee "${target}" >/dev/null
  sudo modprobe tun
  say "tun autoload configured."
}

print_rollback() {
  local backup_dir="$1"
  cat <<EOF

Rollback:
  ./install.sh --restore ${backup_dir}

Log:
  ${LOG_FILE}
EOF
}

parse_args() {
  if [[ "$#" -eq 0 ]]; then
    usage
    exit 0
  fi

  while [[ "$#" -gt 0 ]]; do
    case "$1" in
      --check)
        ACTION="check"
        ;;
      --dry-run)
        ACTION="install"
        DRY_RUN=true
        ;;
      --backup-only)
        ACTION="backup-only"
        ;;
      --install)
        ACTION="install"
        ;;
      --restore)
        ACTION="restore"
        shift
        [[ "$#" -gt 0 ]] || die "--restore requires a backup path"
        RESTORE_PATH="$1"
        ;;
      --install-packages)
        INSTALL_PACKAGES=true
        ;;
      --configure-tun)
        CONFIGURE_TUN=true
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
  local root backup_dir

  parse_args "$@"
  require_not_root
  mkdir -p "${STATE_DIR}"
  say "${PROJECT_NAME} installer started at $(date -Is)"

  root="$(repo_root)"
  check_arch
  check_hyprland
  check_disk_space

  case "${ACTION}" in
    check)
      check_dependencies
      ;;
    backup-only)
      plan_changes "${root}"
      create_backup
      ;;
    install)
      plan_changes "${root}"
      check_dependencies
      if [[ "${DRY_RUN}" == false ]]; then
        assert_required_commands_available
      fi
      validate_sources_for_install "${root}"
      if [[ "${DRY_RUN}" == false ]]; then
        if ! confirm "Proceed with backup and copy-based install?"; then
          say "Install cancelled."
          exit 0
        fi
      fi
      create_backup
      backup_dir="${CREATED_BACKUP_DIR}"
      install_configs "${root}" "${backup_dir}"
      if [[ "${CONFIGURE_TUN}" == true ]]; then
        configure_tun_autoload
      fi
      print_rollback "${backup_dir}"
      ;;
    restore)
      restore_backup "${RESTORE_PATH}"
      ;;
    *)
      usage
      ;;
  esac
}

trap 'die "Installer failed at line ${LINENO}. Check log: ${LOG_FILE}"' ERR
main "$@"
