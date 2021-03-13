#!/bin/bash

if [ "$(ls -A "${CONFIG_PATH}")" ];
  then
    log "Initialize config files from ${CONFIG_PATH}"
    copy-files "${CONFIG_PATH}" "${DATA_PATH}"
  fi
