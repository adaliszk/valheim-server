#!/bin/bash
# shellcheck disable=SC1091

CMD="${1}"
ARGS=${*:2}

source /srv/console.sh

if [[ $CMD =~ ^-[a-z]+ ]];
  then
    log-stdout "exec> Argument detected, using default command..."
    CMD="start"
    ARGS=${*}
  fi

cd "${SERVER_PATH}" || exit

log-stdout "exec> WORKDIR: $(pwd)"
log-stdout "exec> USER: $(id -u)"
log-stdout "exec> GROUP: $(id -g)"

log-stdout "exec> CMD: ${CMD}"
log-stdout "exec> ARGS: ${ARGS}"



function run {
  SCRIPT="${SCRIPTS_PATH}/${1}.sh"
  if [ -f "${SCRIPT}" ];
    then
      log "exec> Executing \"${1}\" script..."
      bash -c "${SCRIPT}" "${ARGS[@]}" 2>&1 | tee-server-raw | vhpretty | tee-server &
      SERVER=$!

      echo "exec> Script started on PID: ${SERVER}" | tee-server >> "$(output-log)"
      tail --pid ${SERVER} -n +1 -f "${LOG_PATH}/output.log" 2> /dev/null
      log "exec> Script on ${SERVER} has exited!" | tee-exit
    else
      log "exec> Script not found: ${1}"
      log "exec> exiting..."
    fi
}

function term-sigquit { term "SIGQUIT"; }
function term-sigterm { term "SIGTERM"; }
function term-sigint { term "SIGINT"; }

function term {
  log "exec> Received ${1} signal..." | tee-exit
  kill -TERM "$SERVER" 2> /dev/null
}

trap term-sigquit SIGQUIT
trap term-sigterm SIGTERM
trap term-sigint SIGINT

run "${CMD}"
