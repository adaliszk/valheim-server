#!/bin/bash
# shellcheck disable=SC1091

NAME="${1:-auto}"

function log {
  echo "B> ${*}" | tee-backup
}

log "@TODO: restore ${NAME}, exiting..."
exit 0
