#!/bin/bash
source /srv/console.sh

function log {
  echo "B> ${*}" | tee-backup
}

tar -cvf "${SERVER_DATA_PATH}/backups/$(date +%Y-%m-%dT%H%M%S%z).tar.gz" "${SERVER_DATA_PATH}/worlds" | tee-backup