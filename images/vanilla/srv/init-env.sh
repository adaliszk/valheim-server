#!/bin/bash

function log-stdout {
  echo "c> ${*}"
}

log-stdout "Initialize environment..."

export SERVER_PATH="/server" CONFIG_PATH="/config" SCRIPTS_PATH="/scripts"
export BACKUP_PATH="/backups" DATA_PATH="/data" LOG_PATH="/logs"