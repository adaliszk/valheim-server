#!/bin/bash
# shellcheck disable=SC1091
source /srv/init-env.sh
source /srv/console.sh

NAME="${1:-auto}"
INDEX="${2:-1}"

function log-restore() {
  log-info "Restore> ${*}" | tee-backup
}

cd "${BACKUP_PATH}" || exit

FILE=$(find "${BACKUP_PATH}" -name "${NAME}*" | tail -n "+${INDEX}" | head -1)

if [[ -f "${FILE}" ]]; then
  log-restore "Found backup to restore: ${FILE}"
  log-restore "Extracting snapshot \"${FILE}\" to ${DATA_PATH}"
  tar -xvf --overwrite "${FILE}" -C "${DATA_PATH}"
else
  log-restore "Could not found a backup to restore with \"${NAME}\"!"
fi
