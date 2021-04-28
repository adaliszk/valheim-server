#!/bin/bash
# shellcheck disable=SC1091
source /srv/console.sh
log-group "ConfigInit"

if [ "$(ls -A "${CONFIG_PATH}"/*.txt 2>/dev/null)" ]; then
  echo "Initialize config files from ${CONFIG_PATH}"
  cp -rfa "${CONFIG_PATH}/"*.txt "${DATA_PATH}" 2> /dev/null
fi

if [ -w "${CONFIG_PATH}" ]; then
  echo "Copy new files back to ${CONFIG_PATH}"
  cp -rfa "${DATA_PATH}/"*.txt "${CONFIG_PATH}/" 2> /dev/null
fi

echo "::metric::Initializing Configuration took" | console-timeEnd "ConfigInit"
