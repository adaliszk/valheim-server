#!/bin/bash
source /srv/console.sh

log "Creating Log files..."
touch "${LOG_PATH}"/{server-raw,server,output,error,backup,restore,health,exit}.log

export SteamAppId=892970
