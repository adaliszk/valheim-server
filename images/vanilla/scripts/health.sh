#!/bin/bash
# shellcheck disable=SC1091
source /srv/init-env.sh
source /srv/console.sh

function log-health() {
  log-info "Health> ${*}" | tee-health
}

function log-debug-health() {
  log-debug "Health> ${*}"
}

STATUS=0

function status-to-word() {
  STATUS_CODE="${1}"

  STATUS_TEXT="DOWN"
  if [ "${STATUS_CODE}" = 0 ]; then
    STATUS_TEXT="UP"
  fi

  echo $STATUS_TEXT
}

function check-status() {
  LAST_STATUS_FILE="${STATUS_PATH}/${1}.old"
  LAST_STATUS="$(cat "${LAST_STATUS_FILE}" 2> /dev/null || echo 999)"

  STATUS_FILE="${STATUS_PATH}/${1}"
  STATUS="$(cat "${STATUS_FILE}" || echo 999)"

  log-debug-health "${1} is $(status-to-word "${STATUS}")"

  if [[ "${LAST_STATUS}" != "${STATUS}" ]]; then
    log-health "${1} is $(status-to-word "${STATUS}")"
  fi

  if [ "${STATUS}" != 0 ]; then STATUS=1; fi
  echo -n "${STATUS}" > "${LAST_STATUS_FILE}"
}

function check-port() {
  LAST_STATUS_FILE="${STATUS_PATH}/Port-${1}"
  LAST_PORT_STATUS="$(cat "${LAST_STATUS_FILE}" 2> /dev/null || echo 999)"

  nc -uz 0.0.0.0 "${1}"
  PORT_STATUS=$?

  log-debug-health "Port ${1} is $(status-to-word "${PORT_STATUS}")"

  if [[ "${LAST_PORT_STATUS}" != "${PORT_STATUS}" ]]; then
    log-health "Port ${1} is $(status-to-word "${PORT_STATUS}")"
  fi

  if [ ${PORT_STATUS} != 0 ]; then STATUS=1; fi
  echo -n "${PORT_STATUS}" > "${LAST_STATUS_FILE}"
}

check-port 2456

if [ "${SERVER_PUBLIC:-1}" == "1" ]; then
  check-port 2457
fi

check-status "DungeonDB"
check-status "Zonesystem"
check-status "Server"

echo "${STATUS}" > "${STATUS_PATH}/Health"
log-debug-health "Health is $(status-to-word "${STATUS}")"

exit "${STATUS}"
