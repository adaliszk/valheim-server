#!/bin/bash
source /srv/console.sh

NAME="${1:-auto}"

function log {
  echo "B> ${*}" | tee-backup
}

tar -cvf "${BACKUP_PATH}/${NAME}-$(date +%Y%m%dT%H%M%S%z).tar.gz" -C "${DATA_PATH}/worlds" . | tee-backup
