#!/bin/bash
# shellcheck disable=SC1091
source /srv/init-container.sh

cd "${SERVER_PATH}" || exit

CMD="${1}"
ARGS=${*:2}

if [[ $CMD =~ ^-[a-z]+ ]]; then
  log "Argument detected, using default command..."
  CMD="start"
  ARGS=${*}
fi

log-debug "WORKDIR: $(pwd)"
log-debug "CMD: ${CMD}"
log-debug "ARGS: ${ARGS}"

# Run command
function run() {
  SCRIPT="${SCRIPTS_PATH}/${1}.sh"
  if [ -f "${SCRIPT}" ]; then
    log "Executing \"${1}\" script..."
    export LOG_GROUP="OCI"

    bash -c "${SCRIPT}" "${ARGS[@]}" 2>&1 | tee-server-raw | vhpretty | vhwatch | tee-output | tee-server &
    SERVER=$!

    tail --pid ${SERVER} -n +2 -f "${LOG_PATH}/output.log" 2>/dev/null
  else
    log "Script not found: ${1}"
    log "exiting..."
  fi
}

function term-sigquit() { term "SIGQUIT"; }
function term-sigterm() { term "SIGTERM"; }
function term-sigint() { term "SIGINT"; }

function term() {
  log "Received ${1} signal..." | tee-exit
  kill -TERM "$SERVER" 2>/dev/null
}

trap term-sigquit SIGQUIT
trap term-sigterm SIGTERM
trap term-sigint SIGINT

run "${CMD}"