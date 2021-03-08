#!/bin/bash
export SteamAppId=892970

function log {
  echo "S> ${*}"
}

export SERVER_NAME="${SERVER_NAME:-$DEFAULT_NAME}"
log "SERVER_NAME: \"${SERVER_NAME}\""

export SERVER_MOTD="${SERVER_MOTD:-$DEFAULT_MOTD}"
log "SERVER_MOTD: \"${SERVER_MOTD}\""

export SERVER_WORLD="${SERVER_WORLD:-$DEFAULT_WORLD}"
log "SERVER_WORLD: \"${SERVER_WORLD}\""

export SERVER_PASSWORD="${SERVER_PASSWORD:-$DEFAULT_PASSWORD}"
log "SERVER_PASSWORD: \"${SERVER_PASSWORD}\""

export SERVER_PUBLIC="${SERVER_PUBLIC:-$DEFAULT_SERVER_PUBLIC}"
log "SERVER_PUBLIC: \"${SERVER_PUBLIC}\""

if [ -d "${SERVER_DATA_PATH}/configs" ];
  then
    log "Configuration files are attached in RO, copying them..."
    for CONFIG_FILE in "${SERVER_DATA_PATH}/configs"/*.txt; do
      FILENAME="$(basename "$CONFIG_FILE")"
      cp -f "${CONFIG_FILE}" "${SERVER_DATA_PATH}/${FILENAME}"
      done
  fi
