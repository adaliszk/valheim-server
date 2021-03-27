#!/bin/bash
# shellcheck disable=SC1091
source /srv/init-env.sh

NAME="${1:-backup}"

function tee-backup() {
  tee "${LOG_PATH}/backup.log"
}

function log-backup() {
  echo "i> Backup> ${*}" | tee-backup
}

cd "${BACKUP_PATH}" || exit

log-backup "Removing old files for ${NAME}..."
# @TODO: try alternative solutions instead of ignoring SC2010
# shellcheck disable=SC2010
ls -tp | grep "^${NAME}" | grep -v '/$' | tail -n "+${BACKUP_RETENTION}" | xargs -I {} rm -- {}

SERVER_WORLD_SIZE=$(stat --printf="%s" "${DATA_PATH}/worlds/${SERVER_WORLD}.db")
log-backup "World \"${SERVER_WORLD}\" is ${SERVER_WORLD_SIZE} bytes large"

WORLDS_SIZE=$(du --bytes "${DATA_PATH}/worlds" | cut -f1)
log-backup "Worlds are ${WORLDS_SIZE} bytes large"

log-backup "Saving a new \"${NAME}\" backup..."
sleep 0.1 # wait a little for the files to be properly written on the disk
FILE_NAME="${NAME}-$(date +%Y%m%dT%H%M%S%z)"

# Could use `time` but for some reason `-f` wasn't working
COMPRESS_BEGIN=$(date +%s.%N)
tar -cf "${BACKUP_PATH}/${FILE_NAME}.tar.gz" -C "${DATA_PATH}" . | tee-backup
COMPRESS_END=$(date +%s.%N)

log-backup "Made a backup for \"${NAME}\" that $(stat --printf="%s" "${BACKUP_PATH}/${FILE_NAME}.tar.gz") bytes large"
log-backup "Compressing files for \"${NAME}\" backup took $(bc -l <<<"(${COMPRESS_END}-${COMPRESS_BEGIN})*1000")ms"
log-backup "Backups are $(du --bytes "${BACKUP_PATH}" | cut -f1) bytes large"
