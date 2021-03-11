#!/bin/bash
source /srv/console.sh

cd "${SERVER_PATH}" || exit

CMD="${*}"
log "WORKDIR: $(pwd)"
log "CMD: ${CMD}"


function script {
  echo "${SCRIPTS_PATH}/${1}.sh"
}


function run {
  SCRIPT="$(script "${1}")"
  if [ -f "${SCRIPT}" ];
    then
      log "Executing \"${1}\" script..."
      bash -c "${SCRIPT}" "${*:2}" 2>&1 | tee "${LOG_PATH}/server-raw.log" | format-output &
      SERVER=$!

      tail -f "${LOG_PATH}/output.log" 2> /dev/null &
      wait "$SERVER"
      kill -TERM $! 2>/dev/null
    fi
}


function term {
  if [ "${CMD}" = "start" ];
    then
      log "Stopping the server..." | tee-exit
      run "backup"
    fi

  kill -TERM "$SERVER" 2>/dev/null
}

trap term SIGINT SIGQUIT SIGTERM


log "Creating output log files..."
touch "${LOG_PATH}"/{server-raw,server,output,error,backup,restore,health,exit}.log

run "${CMD}" "${*:2}"
