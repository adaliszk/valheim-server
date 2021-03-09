#!/bin/bash

echo "Uncompressing Server Files in $(pwd)"
tar -xzf "${SERVER_PATH}/valheim_server_Data.tar.gz"

TEMP_LD_LIBRARY_PATH="$LD_LIBRARY_PATH"
export LD_LIBRARY_PATH="${SERVER_PATH}/linux64:$LD_LIBRARY_PATH"

CMD="${SERVER_PATH}/valheim_server.x86_64 -nographics"
CMD="${CMD} -port 2456 -savedir \"${DATA_PATH}\""
CMD="${CMD} -name \"${SERVER_MOTD}\" -world \"${SERVER_WORLD}\" -password \"${SERVER_PASSWORD}\""
CMD="${CMD} ${*}"
echo "${CMD}"
${CMD}

export LD_LIBRARY_PATH="$TEMP_LD_LIBRARY_PATH"
