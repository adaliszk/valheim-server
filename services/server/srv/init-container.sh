#!/bin/bash
# shellcheck disable=SC1091
source /srv/console.sh

log-out "Update permissions..."
chown 1001:1001 -R /config /data /logs /status

log-out "Rotate logs..."
LOG_FOLDER="${LOG_PATH}/$(timestamp)"
mkdir -p "${LOG_FOLDER}"
mv "${LOG_PATH}"/*.log "${LOG_FOLDER}"/.
touch "${LOG_PATH}"/{server-raw,server,output,error,backup,restore,health,exit}.log

log-out "Reset HEALTH status..."
rm -f "${STATUS_PATH}/*"
echo "1" | tee "${STATUS_PATH}"/{DungeonDB,Zonesystem,Server,Steam} > /dev/null

cd "${SERVER_PATH}" || exit