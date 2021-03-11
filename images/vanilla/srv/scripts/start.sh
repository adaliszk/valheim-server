#!/bin/bash

echo "Extracting Server files in $(pwd)"

# Could use `time` but for some reason `-f` wasn't working
EXTRACT_BEGIN=$(date +%s)
tar -xzf "${SERVER_PATH}/valheim_server_Data.tar.gz"
EXTRACT_END=$(date +%s)
echo "Extracting Server files took $((EXTRACT_END-EXTRACT_BEGIN))s"


TEMP_LD_LIBRARY_PATH="$LD_LIBRARY_PATH"
export LD_LIBRARY_PATH="${SERVER_PATH}/linux64:$LD_LIBRARY_PATH"

SERVER_ARGS=(
  "-name ${SERVER_NAME}"
  "-password ${SERVER_PASSWORD}"
  "-world ${SERVER_WORLD}"
  "-savedir ${DATA_PATH}"
  "-public ${SERVER_PUBLIC}"
)

SERVER_ARGS_STR=$( IFS=$' '; echo "${SERVER_ARGS[*]}" )

SERVER_CMD="${SERVER_PATH}/valheim_server.x86_64 -nographics -batchmode -port 2456 ${SERVER_ARGS_STR}"

echo "Execute: ${SERVER_CMD}"
${SERVER_CMD}

export LD_LIBRARY_PATH="$TEMP_LD_LIBRARY_PATH"
