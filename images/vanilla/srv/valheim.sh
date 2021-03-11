#!/bin/bash
source /srv/console.sh
source /srv/init-env.sh
source /srv/init-scripts.sh

cd "${SERVER_PATH}" || exit

CMD="${1}"
ARGS="${*:2}"

log "WORKDIR: $(pwd)"
log "CMD: ${CMD}"
log "ARGS: ${ARGS}"

function run {
  SCRIPT="${SCRIPTS_PATH}/${1}.sh"
  if [ -f "${SCRIPT}" ];
    then
      log "Executing \"${1}\" script..."
      bash -c "${SCRIPT}" "${ARGS}" 2>&1 | tee-server-raw | format-output
    else
      log "Script not found: ${1}"
      log "exiting..."
    fi
}

run "${CMD}" "${ARGS}"
