#!/bin/bash
# shellcheck disable=SC1091
source /srv/init-env.sh
source /srv/console.sh

function log {
  echo "H> ${*}" | tee "${LOG_PATH}/health.log" | tee-output
}

STATUS=0

function status-to-word {
  STATUS_CODE="${1}"

  STATUS_TEXT="DOWN"
  if [ "${STATUS_CODE}" = 0 ];
    then
      STATUS_TEXT="UP"
    fi

  echo $STATUS_TEXT
}

function check-server-connected {
  CONNECTED_STATUS="$(cat "${LOG_PATH}/server-connected.status")"
  log "Server is $(status-to-word "$CONNECTED_STATUS")"
}

function check-port {
  netstat -an | grep "${1}" > /dev/null
  PORT=$?
  log "Port ${1} is $(status-to-word "$PORT")"
  if [ $PORT != 0 ]; then STATUS=1; fi;
}

check-server-connected
check-port 2456

if [ "${SERVER_PUBLIC:-1}" == "1" ];
  then
    check-port 2457
  fi

exit $STATUS