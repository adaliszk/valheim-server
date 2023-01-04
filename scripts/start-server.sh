#!/usr/bin/env bash
# Copyright © 2022 by Ádám Liszkai using BSD 2-Clause License
# https://source.adaliszk.io/valheim-server/license

export LD_LIBRARY_PATH="./linux64:$LD_LIBRARY_PATH"
export SteamAppId="892970"

# Build the Server's Arguments into a Command-Line
SERVER_ARGS=(
	"-nographics"
	"-batchmode"
	"-name" "${SERVER_NAME}"
	"-password" "${SERVER_PASSWORD}"
	"-world" "${SERVER_WORLD}"
	"-savedir" "/tmp/valheim-server"
	"-port" "${SERVER_PORT}"
	"-saveinterval" "${SAVE_INTERVAL}"
	"-backups" "${BACKUP_RETENTION}"
	"-backupshort" "${BACKUP_FIRST_INTERVAL}"
	"-backuplong" "${BACKUP_CYCLE_INTERVAL}"
)

[[ ${SERVER_PUBLIC} == "true" ]] && SERVER_ARGS+=("-public" "1") || SERVER_ARGS+=("-public" "0")
[[ ${SERVER_CROSSPLAY} == "true" ]] && SERVER_ARGS+=("-crossplay")

echo "Execute: valheim_server.x86_64" "${SERVER_ARGS[@]}" | log ContainerInit
./valheim_server.x86_64 "${SERVER_ARGS[@]}" 2>&1