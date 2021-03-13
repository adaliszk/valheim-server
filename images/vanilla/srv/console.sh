#!/bin/bash
export SERVER_PATH="/server" CONFIG_PATH="/config" SCRIPTS_PATH="/scripts"
export BACKUP_PATH="/backups" DATA_PATH="/data" LOG_PATH="/logs"

function vhpretty {
  /srv/vhpretty.py
}

function output-log {
  echo "${LOG_PATH}/output.log"
}

function tee-output {
   tee "$(output-log)"
}

function tee-server-raw {
  tee "${LOG_PATH}/server-raw.log"
}

function server-log {
  echo "${LOG_PATH}/server.log"
}

function tee-server {
  tee "$(server-log)"
}

function tee-backup {
   tee "${LOG_PATH}/backup.log" | tee-output
}

function tee-exit {
  tee "${LOG_PATH}/exit.log" | tee-output
}

function log {
  echo "c> ${*}" | tee-output
}

function log-env {
  for VAR in "$@"
  do
      debug-log "$VAR: ${!VAR:-(empty)}"
  done
}

function debug-log {
  echo "d> ${*}" | tee-output
}

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