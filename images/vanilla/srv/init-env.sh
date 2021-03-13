#!/bin/bash

function log-stdout {
  echo "c> ${*}"
}

function log-env {
  for VAR in "$@"
  do
      log-stdout "$VAR: ${!VAR:-(empty)}"
  done
}

log-stdout "Initialize environment..."

export SERVER_PATH="/server" CONFIG_PATH="/config" SCRIPTS_PATH="/scripts"
export BACKUP_PATH="/backups" DATA_PATH="/data" LOG_PATH="/logs"

log-env SERVER_PATH CONFIG_PATH SCRIPTS_PATH BACKUP_PATH DATA_PATH LOG_PATH
