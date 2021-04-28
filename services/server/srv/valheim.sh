#!/bin/bash
# shellcheck disable=SC1091
source /srv/console.sh

echo " "
echo "Thank you for using ADALISZK/VALHEIM-SERVER v${VERSION:-1.0}@${REF:-develop}"
echo " "
echo "Documentation: https://adaliszk.github.io/valheim-server "
echo "Docker: https://hub.docker.com/r/adaliszk/valheim-server "
echo "Source: https://github.com/adaliszk/valheim-server "
echo " "
echo "If you like it, please leave a star on Docker-Hub! "
echo " "

console-time "ServerBoot"
log-group "ContainerInit"

source /srv/init-container.sh
source /srv/format-output.sh

CMD="${1}"
ARGS=${*:2}

if [[ $CMD =~ ^-[a-z]+ ]]; then
  log "Argument detected, using default command..."
  CMD="start"
  ARGS=${*}
fi

if [[ -f "${CMD}" ]]; then
  bash -c "${CMD}" "${ARGS[@]}"
  exit $?
fi

log-debug "WORKDIR: $(pwd)"
log-debug "CMD: ${CMD}"
log-debug "ARGS: ${ARGS}"

# Run command
function run() {
  SCRIPT="${SCRIPTS_PATH}/${1}.sh"

  if [ -f "${SCRIPT}" ]; then
    log-out "Executing \"${1}\" script..."
    bash -c "${SCRIPT}" "${ARGS[@]}" 2>&1 | tee-raw | format-output | tee-output | format-log >> "${LOG_PATH}/server.log" &
    SERVER=$!
    tail --pid ${SERVER} -n +2 -f "${LOG_PATH}/output.log" 2>/dev/null
  else
    log-out "Script not found: ${1}"
    log-out "exiting..."
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

log-metric "Container was initialized in" | console-timeEnd "ContainerInit"
run "${CMD}"
