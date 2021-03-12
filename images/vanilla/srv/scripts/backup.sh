#!/bin/bash
# shellcheck disable=SC1091
source /srv/console.sh

NAME="${1:-backup}"

function log {
  echo "i> backup> ${*}" | tee-backup
}

cd "${BACKUP_PATH}" || exit

log "Removing old files for ${NAME}..."
ls -tp | grep "^${NAME}" | grep -v '/$' | tail -n "+${BACKUP_RETENTION}" | xargs -I {} rm -- {}

log "Saving a new \"${NAME}\" backup..."
sleep 0.1 # wait a little for the files to be properly written on the disk
tar -cf "${BACKUP_PATH}/${NAME}-$(date +%Y%m%dT%H%M%S%z).tar.gz" -C "${DATA_PATH}" . | tee-backup
