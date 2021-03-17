#!/bin/bash

if [ "$(ls -A "${CONFIG_PATH}")" ];
  then
    log "Initialize config files from ${CONFIG_PATH}"
    cp -rfa "${CONFIG_PATH}/"*.txt "${DATA_PATH}"
  fi
