#!/bin/bash

if [[ ! -d "${SERVER_PATH}/valheim_server_Data" ]];
  then
    echo "Extracting Server files in $(pwd)"

    # @TODO: Should use `time` but `-f` wasn't working, so this is a quick and dirty solution
    EXTRACT_BEGIN=$(date +%s.%N)
    tar -xzf "${SERVER_PATH}/valheim_server_Data.tar.gz"
    EXTRACT_END=$(date +%s.%N)

    echo "Extracting Server files took $(bc -l <<< "(${EXTRACT_END}-${EXTRACT_BEGIN})*1000")ms"
  fi

# Print out some stats for the Metrics exporter
WORLD_FILE="${DATA_PATH}/worlds/${SERVER_WORLD}.db"
if [ -f "${WORLD_FILE}" ];
  then
    echo "World \"${SERVER_WORLD}\" is $(stat --printf="%s" "${WORLD_FILE}") bytes large"
    echo "Worlds are $(du --bytes "${DATA_PATH}/worlds" | cut -f1) bytes large"
  fi

