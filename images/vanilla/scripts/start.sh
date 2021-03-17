#!/bin/bash
source /srv/init-server.sh

TEMP_LD_LIBRARY_PATH="$LD_LIBRARY_PATH"
export LD_LIBRARY_PATH="${SERVER_PATH}/linux64:$LD_LIBRARY_PATH"

# Build the Server's Arguments into a Command-Line
SERVER_ARGS=(
  "-name" "${SERVER_NAME}"
  "-password" "${SERVER_PASSWORD}"
  "-world" "${SERVER_WORLD}"
  "-savedir" "${DATA_PATH}"
  "-public" "${SERVER_PUBLIC}"
)

SERVER_ARGS_STR=$( IFS=$' '; echo "${SERVER_ARGS[*]}" )

SERVER_CMD="${SERVER_PATH}/valheim_server.x86_64 -nographics -batchmode -logfile -port 2456"

echo "Execute: ${SERVER_CMD} ${SERVER_ARGS_STR}"
${SERVER_CMD} "${SERVER_ARGS[@]}"

export LD_LIBRARY_PATH="$TEMP_LD_LIBRARY_PATH"
