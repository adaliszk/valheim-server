#!/bin/bash

echo "Extracting Server files in $(pwd)"

# Could use `time` but for some reason `-f` wasn't working
EXTRACT_BEGIN=$(date +%s.%N)
tar -xzf "${SERVER_PATH}/valheim_server_Data.tar.gz"
EXTRACT_END=$(date +%s.%N)
echo "Extracting Server files took $(bc -l <<< "(${EXTRACT_END}-${EXTRACT_BEGIN})*1000")ms"

TEMP_LD_LIBRARY_PATH="$LD_LIBRARY_PATH"
export LD_LIBRARY_PATH="${SERVER_PATH}/linux64:$LD_LIBRARY_PATH"

# Print out some stats for the Metrics exporter
WORLD_FILE="${DATA_PATH}/worlds/${SERVER_WORLD}.db"
if [ -f "${WORLD_FILE}" ];
  then
    echo "World \"${SERVER_WORLD}\" is $(stat --printf="%s" "${WORLD_FILE}") bytes large"
    echo "Worlds are $(du --bytes "${DATA_PATH}/worlds" | cut -f1) bytes large"
  fi

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
