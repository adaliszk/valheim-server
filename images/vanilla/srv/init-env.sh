#!/bin/bash

export SteamAppId=892970

export SERVER_PATH="/server"
export CONFIG_PATH="/config"
export SCRIPTS_PATH="/scripts"
export BACKUP_PATH="/backups"
export DATA_PATH="/data"
export LOG_PATH="/logs"

export STATUS_PATH="/status"
touch "${STATUS_PATH}"/{DungeonDB,Zonesystem,Server}

export LOG_GROUP="OCI"