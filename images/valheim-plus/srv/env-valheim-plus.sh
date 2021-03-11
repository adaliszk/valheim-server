#!/bin/bash
source /srv/env-server.sh

if [ -d "${MOD_CONFIG_PATH}-ro" ];
  then
    log "Configuration files are attached in ReadOnly, copying them..."
    for CONFIG_FILE in "${MOD_CONFIG_PATH}-ro"/*.cfg; do
      FILENAME="$(basename "$CONFIG_FILE")"
      cp -f "${CONFIG_FILE}" "${MOD_CONFIG_PATH}/${FILENAME}"
      done
  fi
