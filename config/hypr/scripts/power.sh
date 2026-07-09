#!/usr/bin/env bash
set -Eeuo pipefail

lock_screen() {
  script_dir="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd -P)"
  "${script_dir}/lock.sh"
}

logout_session() {
  hyprctl dispatch exit || hyprctl dispatch 'hl.dsp.exit()'
}

case "${1:-}" in
  --lock)
    lock_screen
    ;;
  --suspend)
    systemctl suspend
    ;;
  --logout)
    logout_session
    ;;
  --reboot)
    systemctl reboot
    ;;
  --poweroff)
    systemctl poweroff
    ;;
  *)
    choice="$(printf 'lock\nsuspend\nlogout\nreboot\npoweroff\n' | rofi -dmenu -replace -i -p "power" -config "$HOME/.config/rofi/power.rasi")"
    case "$choice" in
      lock) lock_screen ;;
      suspend) systemctl suspend ;;
      logout) logout_session ;;
      reboot) systemctl reboot ;;
      poweroff) systemctl poweroff ;;
      *) exit 0 ;;
    esac
    ;;
esac
