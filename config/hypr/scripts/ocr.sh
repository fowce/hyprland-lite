#!/usr/bin/env bash
set -Eeuo pipefail

state_dir="${XDG_STATE_HOME:-$HOME/.local/state}/hyprland-lite"
log_file="${state_dir}/ocr.log"

mkdir -p "$state_dir"

log() {
  printf '[%s] %s\n' "$(date -Is)" "$*" >> "$log_file"
}

message() {
  local title="$1"
  local body="${2:-}"

  log "${title}: ${body}"

  if command -v notify-send >/dev/null 2>&1; then
    notify-send "$title" "$body" 2>/dev/null || true
  elif command -v rofi >/dev/null 2>&1; then
    rofi -e "${title}: ${body}" 2>/dev/null || true
  fi
}

require_command() {
  local cmd="$1"

  if ! command -v "$cmd" >/dev/null 2>&1; then
    message "OCR unavailable" "Missing command: ${cmd}"
    exit 1
  fi
}

ocr_language() {
  local langs

  langs="$(tesseract --list-langs 2>/dev/null || true)"
  if grep -qx 'rus' <<<"$langs" && grep -qx 'eng' <<<"$langs"; then
    printf '%s\n' "eng+rus"
  elif grep -qx 'eng' <<<"$langs"; then
    printf '%s\n' "eng"
  else
    message "OCR unavailable" "Missing tesseract language data. Install tesseract-data-eng."
    exit 1
  fi
}

require_command grim
require_command slurp
require_command tesseract
require_command wl-copy

geometry="$(slurp || true)"
[[ -n "$geometry" ]] || {
  log "selection cancelled"
  exit 0
}

lang="$(ocr_language)"
log "selected geometry: ${geometry}; lang: ${lang}"

tmp_image="$(mktemp --suffix=.png)"
trap 'rm -f "$tmp_image"' EXIT

grim -g "$geometry" "$tmp_image"

if ! text="$(tesseract "$tmp_image" stdout -l "$lang" 2>>"$log_file")"; then
  message "OCR failed" "Tesseract failed. See ${log_file}"
  exit 1
fi

if [[ -z "${text//[[:space:]]/}" ]]; then
  message "OCR empty" "No text was detected in the selected area."
  exit 0
fi

printf '%s' "$text" | wl-copy
message "OCR copied" "Extracted text was copied to clipboard."
