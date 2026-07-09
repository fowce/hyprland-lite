#!/usr/bin/env bash
set -Eeuo pipefail

PROJECT_NAME="hyprland-lite"
ROOT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd -P)"
FAILED=0

say() {
  printf '%s\n' "$*"
}

mark_failed() {
  FAILED=1
  say "FAIL: $*"
}

need_command() {
  local cmd="$1"
  if command -v "${cmd}" >/dev/null 2>&1; then
    return 0
  fi
  say "SKIP: ${cmd} not found"
  return 1
}

check_bash() {
  local file
  say "Checking shell syntax..."
  while IFS= read -r -d '' file; do
    bash -n "${file}" || mark_failed "bash syntax: ${file}"
  done < <(find "${ROOT_DIR}" -path "${ROOT_DIR}/.git" -prune -o -type f -name '*.sh' -print0)
}

check_lua() {
  local file
  need_command luac || return 0
  say "Checking Lua syntax..."
  while IFS= read -r -d '' file; do
    luac -p "${file}" || mark_failed "lua syntax: ${file}"
  done < <(find "${ROOT_DIR}/config/hypr" -type f -name '*.lua' -print0)
}

check_json() {
  local file
  need_command jq || return 0
  say "Checking JSON/JSONC syntax..."
  while IFS= read -r -d '' file; do
    jq empty "${file}" >/dev/null || mark_failed "json syntax: ${file}"
  done < <(find "${ROOT_DIR}/config" \( -name '*.json' -o -name '*.jsonc' \) -print0)
}

check_scripts_executable() {
  local file
  say "Checking executable scripts..."
  while IFS= read -r -d '' file; do
    if [[ ! -x "${file}" ]]; then
      mark_failed "script is not executable: ${file}"
    fi
  done < <(find "${ROOT_DIR}" -path "${ROOT_DIR}/.git" -prune -o -type f -name '*.sh' -print0)
}

check_public_text() {
  local pattern
  need_command rg || return 0
  say "Checking public text..."
  pattern="$(printf '%s|%s|%s|%s|%s|%s' "fo""wce" "ML""4W" "ml""4w" "Ste""phan" "Ra""abe" "insp""ired")"
  if rg -n "${pattern}" "${ROOT_DIR}"; then
    mark_failed "public text contains a blocked personal/upstream reference"
  fi
}

check_required_files() {
  local file
  say "Checking required files..."

  for file in \
    "AGENTS.md" \
    "LICENSE" \
    "README.md" \
    ".gitignore" \
    "install.sh" \
    "uninstall.sh" \
    "switch-config.sh" \
    "docs/ui-components.md" \
    "config/hypr/hyprland.lua" \
    "config/waybar/config.jsonc" \
    "config/rofi/config.rasi" \
    "config/quickshell/shell.qml" \
    "config/palettes/warm.json" \
    "config/theme/apply-palette.sh"
  do
    [[ -e "${ROOT_DIR}/${file}" ]] || mark_failed "missing required file: ${file}"
  done
}

main() {
  say "${PROJECT_NAME} static checks"
  say "Root: ${ROOT_DIR}"

  check_required_files
  check_bash
  check_lua
  check_json
  check_scripts_executable
  check_public_text

  if [[ "${FAILED}" -eq 0 ]]; then
    say "All static checks passed."
  else
    say "Static checks failed."
    exit 1
  fi
}

main "$@"
