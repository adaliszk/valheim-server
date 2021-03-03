#!/bin/bash

TEMP_LD_LIBRARY_PATH="$LD_LIBRARY_PATH"

export LD_LIBRARY_PATH="${SERVER_PATH}/linux64:$LD_LIBRARY_PATH"

./valheim_server.x86_64 -nographics -batchmode \
  -name "${SERVER_MOTD}" \
  -world "${SERVER_WORLD}" \
  -password "${SERVER_PASSWORD}" \
  -port 2456 \
  -public 1

export LD_LIBRARY_PATH="$TEMP_LD_LIBRARY_PATH"
