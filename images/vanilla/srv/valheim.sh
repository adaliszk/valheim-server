#!/bin/bash
source /srv/console.sh

cd "${SERVER_PATH}" || exit

CMD="${1}"
ARGS=${*:2}

if [[ $CMD =~ ^-[a-z]+ ]];
  then
    log "Argument detected, using default command..."
    CMD="start"
    ARGS=${*}
  fi

log "WORKDIR: $(pwd)"
log "CMD: ${CMD}"
log "ARGS: ${ARGS}"

source /srv/init-scripts.sh
source /srv/init-env.sh

function run {
  SCRIPT="${SCRIPTS_PATH}/${1}.sh"
  if [ -f "${SCRIPT}" ];
    then
      log "Executing \"${1}\" script..."
      bash -c "${SCRIPT}" ${ARGS} 2>&1 | tee-server-raw | vhpretty | server-log &
      SERVER=$!
      tail --pid $SERVER -n +1 -f "${LOG_PATH}/output.log" 2> /dev/null
    else
      log "Script not found: ${1}"
      log "exiting..."
    fi
}

function term {
  kill -TERM "$SERVER" 2>/dev/null
}

trap term SIGINT SIGQUIT SIGTERM


run "${CMD}"
