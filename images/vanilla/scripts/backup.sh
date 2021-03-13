#!/bin/bash
# shellcheck disable=SC1091
source /srv/console.sh

NAME="${1:-auto}"

tar -cvf "${BACKUP_PATH}/${NAME}-$(date +%Y%m%dT%H%M%S%z).tar.gz" -C "${DATA_PATH}/worlds" . | tee-backup
