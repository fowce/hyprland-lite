#!/usr/bin/env bash
set -Eeuo pipefail

if ! command -v tesseract >/dev/null 2>&1; then
  notify-send "OCR unavailable" "Install tesseract to use text extraction." 2>/dev/null || true
  exit 1
fi

geometry="$(slurp)"
[[ -n "$geometry" ]] || exit 0

text="$(grim -g "$geometry" - | tesseract stdin stdout 2>/dev/null)"
[[ -n "$text" ]] || exit 0

printf '%s' "$text" | wl-copy
notify-send "OCR copied" "Extracted text was copied to clipboard." 2>/dev/null || true
