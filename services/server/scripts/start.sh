#!/bin/bash
# shellcheck disable=SC1091
source /srv/console.sh
source /srv/init-configs.sh
source /srv/init-server.sh

log-group "Server"

TEMP_LD_LIBRARY_PATH="$LD_LIBRARY_PATH"
export LD_LIBRARY_PATH="${SERVER_PATH}/linux64:$LD_LIBRARY_PATH"

# Build the Server's Arguments into a Command-Line
SERVER_ARGS=(
  "-nographics"
  "-batchmode"
  "-name" "${SERVER_NAME}"
  "-password" "${SERVER_PASSWORD}"
  "-world" "${SERVER_WORLD}"
  "-savedir" "${DATA_PATH}"
  "-logFile" "-"
  "-public" "${SERVER_PUBLIC}"
  "-port" "2456"
)

SERVER_CMD="${SERVER_PATH}/valheim_server.x86_64"

echo "Execute: ${SERVER_CMD}" "${SERVER_ARGS[@]}"
${SERVER_CMD} "${SERVER_ARGS[@]}"

export LD_LIBRARY_PATH="$TEMP_LD_LIBRARY_PATH"
