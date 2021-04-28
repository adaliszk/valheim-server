#!/bin/bash
# shellcheck disable=SC1091
source /srv/console.sh

STATUS=0

echo " " >> "${LOG_PATH}/health.log"

function log() {
  GROUP="${LOG_LEVEL_HEALTH}" .format "${*}" | tee-output >> "${LOG_PATH}/health.log"
}

function log-debug() {
  LEVEL="${LOG_LEVEL_DEBUG}" GROUP="${LOG_LEVEL_HEALTH}" .format "${*}" >> "${LOG_PATH}/health.log"
}

function status-to-word() {
  [[ "${1}" == 0 ]] && echo "UP" || echo "DOWN"
}

function status-to-success() {
  [[ "${1}" == 0 ]] && echo "Success" || echo "Error"
}

function status-to-health() {
  [[ "${1}" == 0 ]] && echo "Healthy" || echo "Unstable"
}

function check-status() {
  LAST_STATUS_FILE="${STATUS_PATH}/${1}.old"
  LAST_STATUS="$(cat "${LAST_STATUS_FILE}" 2> /dev/null || echo 999)"

  STATUS_FILE="${STATUS_PATH}/${1}"
  STATUS="$(cat "${STATUS_FILE}" || echo 999)"

  log-debug "${1} is $(status-to-word "${STATUS}")"

  if [[ "${LAST_STATUS}" != "${STATUS}" ]]; then
    log "${1} is $(status-to-word "${STATUS}")"
  fi

  echo -n "${STATUS}" > "${LAST_STATUS_FILE}"
  [[ "${STATUS}" != 0 ]] && STATUS=1
}

function send-packet() {
  MSG="${1}"
  PORT="${2}"

  RT_BEGIN=$(date +%s.%N)
  RES=$(python3 /srv/a2s.py "${PORT}" "${MSG}")
  RES_CODE="${?}"
  RES_STATUS="$(status-to-success "${RES_CODE}")"
  RT_END=$(date +%s.%N)
  RESPONSE_TIME="$(echo "(${RT_END}-${RT_BEGIN})" | bc)"
  RESPONSE_TIME=$(printf "%.6fs" "${RESPONSE_TIME}")

  echo "${RES_CODE} ${RES_STATUS} ${RES} ${RESPONSE_TIME}"
  [[ "${RES_STATUS}" != 0 ]] && STATUS=1
  return "${RES_CODE}"
}

function check-valheim-port() {
  log-debug "Send \"k_ESteamNetworkingUDPMsg_ConnectionClosed\" to :2456/udp"
  # shellcheck disable=SC2207
  # We actually want to split the string in this case
  RESPONSE=($(send-packet "k_ESteamNetworkingUDPMsg_ConnectionClosed" 2456))
  log-debug "Received ${RESPONSE[1]}(${RESPONSE[0]}) \"${RESPONSE[2]}\" took ${RESPONSE[3]}"
  log "Valheim UDP Port 2456 check took ${RESPONSE[3]}"

  set-status "Server" "${RESPONSE[0]}"
  log-debug "Server status Updated: $(get-status "Server")"
}

function check-steam-port() {
  log-debug "Send \"a2s_SourceEngineQuery\" to :2457/udp"
  # shellcheck disable=SC2207
  # We actually want to split the string in this case
  RESPONSE=($(send-packet "a2s_Info" 2457))
  echo "${?}" > "/status/Steam"
  log-debug "Received ${RESPONSE[1]}(${RESPONSE[0]}) \"${RESPONSE[2]}\" took ${RESPONSE[3]}"
  log "Steam Query UDP Port 2457 check took ${RESPONSE[3]}"

  set-status "Steam" "${RESPONSE[0]}"
  log-debug "Steam status Updated: $(get-status "Steam")"
}

check-valheim-port

if [ "${SERVER_PUBLIC:-1}" == "1" ]; then
  check-steam-port
fi

check-status "Steam"
check-status "DungeonDB"
check-status "Zonesystem"
check-status "Server"

echo "${STATUS}" > "${STATUS_PATH}/Health"
log-debug "Container is $(status-to-health "${STATUS}")"

exit "${STATUS}"