#!/bin/bash
# shellcheck disable=SC1091
source /srv/init-env.sh
source /srv/console.sh

export LOG_GROUP="ContainerInit"

log "Rotate logs..."
LOG_FOLDER="${LOG_PATH}/$(date "+%Y-%m-%d_%H%M%S%z")"
mkdir -p "${LOG_FOLDER}"

for LOG in "${LOG_PATH}"/*.log; do
  FILENAME=$(basename "${LOG}")
  mv "$LOG" "${LOG_FOLDER}/${FILENAME}"
done

touch "${LOG_PATH}"/{server-raw,server,output,error,backup,restore,health,exit}.log

log "Reset HEALTH status..."
rm -f "${STATUS_PATH}/*"
bash -c "${SCRIPTS_PATH}/health.sh"
