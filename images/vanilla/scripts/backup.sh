#!/bin/bash
# shellcheck disable=SC1091
source /srv/init-env.sh
source /srv/console.sh

NAME="${1:-backup}"

function log {
  echo "i> backup> ${*}" | tee-backup
}

cd "${BACKUP_PATH}" || exit

log "Removing old files for ${NAME}..."
# @TODO: try alternative solutions instead of ignoring SC2010
# shellcheck disable=SC2010
ls -tp | grep "^${NAME}" | grep -v '/$' | tail -n "+${BACKUP_RETENTION}" | xargs -I {} rm -- {}

SERVER_WORLD_SIZE=$(stat --printf="%s" "${DATA_PATH}/worlds/${SERVER_WORLD}.db")
log "World \"${SERVER_WORLD}\" is ${SERVER_WORLD_SIZE} bytes large"

WORLDS_SIZE=$(du --bytes "${DATA_PATH}/worlds" | cut -f1)
log "Worlds are ${WORLDS_SIZE} bytes large"

log "Saving a new \"${NAME}\" backup..."
sleep 0.1 # wait a little for the files to be properly written on the disk
FILE_NAME="${NAME}-$(date +%Y%m%dT%H%M%S%z)"

# Could use `time` but for some reason `-f` wasn't working
COMPRESS_BEGIN=$(date +%s.%N)
tar -cf "${BACKUP_PATH}/${FILE_NAME}.tar.gz" -C "${DATA_PATH}" . | tee-backup
COMPRESS_END=$(date +%s.%N)

log "Made a backup for \"${NAME}\" that $(stat --printf="%s" "${BACKUP_PATH}/${FILE_NAME}.tar.gz") bytes large"
log "Compressing files for \"${NAME}\" backup took $(bc -l <<< "(${COMPRESS_END}-${COMPRESS_BEGIN})*1000")ms"
log "Backups are $(du --bytes "${BACKUP_PATH}" | cut -f1) bytes large"
