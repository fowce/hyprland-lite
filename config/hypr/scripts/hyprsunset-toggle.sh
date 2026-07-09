#!/usr/bin/env bash
set -Eeuo pipefail

if pgrep -x hyprsunset >/dev/null 2>&1; then
  pkill -x hyprsunset
else
  hyprsunset -t 4500 >/dev/null 2>&1 &
fi
