#!/bin/bash
source /srv/init-server.sh

TEMP_LD_LIBRARY_PATH="$LD_LIBRARY_PATH"
export LD_LIBRARY_PATH="${SERVER_PATH}/linux64:$LD_LIBRARY_PATH"

log-env SERVER_PATH DATA_PATH
log-env SERVER_NAME SERVER_PASSWORD SERVER_WORLD SERVER_PUBLIC
log-env SERVER_ADMINS SERVER_PERMITTED SERVER_BANNED

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
