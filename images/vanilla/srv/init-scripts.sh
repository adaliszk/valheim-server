#!/bin/bash

function copy-files {
  SOURCE_PATH="${1}"
  TARGET_PATH="${2}"

  for FILE in "${SOURCE_PATH}"/*;
    do
      FILENAME="$(basename "$FILE")"
      COPY="cp -f ${FILE} ${TARGET_PATH}/${FILENAME}"
      debug-log "$COPY"
      $COPY
    done
}

if [ "$(ls -A "${CONFIG_PATH}")" ];
  then
    log "Initialize config files from ${CONFIG_PATH}"
    copy-files "${CONFIG_PATH}" "${DATA_PATH}"
  fi

if [ "$(ls -A "${SCRIPTS_PATH}")" ];
  then
    log "Scripts already initialized, skipping..."
  else
    log "Initialize scripts from ${SCRIPTS_PATH}"
    copy-files /srv/scripts "${SCRIPTS_PATH}"
  fi
