#!/bin/bash
# shellcheck disable=SC1091
source /srv/utils.sh

chown-path "${LOG_PATH}"
chown-path "${CONFIG_PATH}"
chown-path "${BACKUP_PATH}"

chown-path "${SERVER_PATH}"
chown-path "${DATA_PATH}"