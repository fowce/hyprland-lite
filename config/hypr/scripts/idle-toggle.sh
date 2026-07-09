#!/usr/bin/env bash
set -Eeuo pipefail

case "${1:-toggle}" in
  status)
    if pgrep -x hypridle >/dev/null 2>&1; then
      printf '{"text":"idle on","class":"active","tooltip":"Idle locking is active"}\n'
    else
      printf '{"text":"idle off","class":"inactive","tooltip":"Idle locking is inactive"}\n'
    fi
    ;;
  on)
    pgrep -x hypridle >/dev/null 2>&1 || hypridle >/dev/null 2>&1 &
    ;;
  off)
    pkill -x hypridle 2>/dev/null || true
    ;;
  toggle)
    if pgrep -x hypridle >/dev/null 2>&1; then
      pkill -x hypridle
    else
      hypridle >/dev/null 2>&1 &
    fi
    ;;
  *)
    printf 'Usage: idle-toggle.sh [status|on|off|toggle]\n' >&2
    exit 1
    ;;
esac
