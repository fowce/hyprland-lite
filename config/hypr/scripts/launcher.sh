#!/usr/bin/env bash
set -Eeuo pipefail

pkill rofi 2>/dev/null || rofi -show drun -replace -i -config "$HOME/.config/rofi/launcher.rasi"
