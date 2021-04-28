#!/bin/bash
source /srv/init-env.sh

function set-status {
  echo "${2}" > "${STATUS_PATH}/${1}"
  sleep 0.05
}

function get-status {
  CODE=$(cat "${STATUS_PATH}/${1}" || echo 999)
  echo "${CODE}"
  return "${CODE}"
}

function timestamp() {
  date "+%Y-%m-%dT%H%M%S%z"
}

function console-time {
  echo "${1}=$(date +%s.%N)" >> /tmp/LOG_TIME
}

function console-timeEnd {
  console-time "${1}"

  # We actually want it to be split by lines
  # shellcheck disable=SC2207
  TIMES=($(grep "${1}" "/tmp/LOG_TIME" | sed "s/${1}=//"))

  message=$(cat -)
  printf "%s %.6fs\n" "${message:-$1}" "$(echo "(${TIMES[1]}-${TIMES[0]})" | bc)"
}

# =============================================================================

function format-log() {
  while IFS="" read -r LINE; do
    FORMAT="${LOG_PREFIX}{message}" .format "${LINE}"
  done
}

# =============================================================================

function tee-output() {
  tee "${LOG_PATH}/output.log"
}

function tee-raw() {
  tee "${LOG_PATH}/server-raw.log"
}

function tee-exit() {
  tee-output | format-log >> "${LOG_PATH}/exit.log"
}

# =============================================================================

# shellcheck disable=SC2120
function log-group() {
  if [[ -z "${*}" ]]; then
    LOG_GROUP=$(cat /tmp/LOG_GROUP 2> /dev/null || echo "OCI")
    echo "${LOG_GROUP}"
  else
    LOG_GROUP="${*}"
    console-time "${LOG_GROUP}"
    sleep 0.1 # Wait a little for the output to catch up
    echo "${LOG_GROUP}" > /tmp/LOG_GROUP
  fi
}

skip_formatting="^::raw::"
empty_line="^::empty::$"

function .format() {
  FORMAT="${FORMAT:-$LOG_FORMAT}"

  timestamp="$(timestamp)"
  level="${LEVEL:-$LOG_LEVEL_INFO}"
  l="${level:0:1}"
  ll="${l,,}"
  group="${GROUP:-$(log-group)}"

  message="$(echo "${*}" | sed -u 's/\//\\\//g;s/#/\\#/g;t')"
  out="${message}"

  out=$(
    echo "${FORMAT}" \
      | sed -u "s/{timestamp}/${timestamp}/gi;t" \
      | sed -u "s/{level}/${level}/gi;s/{ll}/${ll}/gi;s/{l}/${l}/gi;s/{group}/${group}/gi;t" \
      | sed -u "s/{message}/${message}/gi;t" \
      | sed -uE 's/\n//gi;s/^\s+//gi;s/\s+$//gi'
    )

  [[ "${message}" =~ $skip_formatting ]] && out="${message/::raw::/}"
  [[ "${message}" =~ $empty_line ]] && out=" "
  echo "${out}"
}

function log() {
  .format "${*}"
}

function log-out() {
  .format "${*}"
}

function log-metric() {
  GROUP="${GROUP:-$(log-group)}" LEVEL="${LOG_LEVEL_METRIC}" .format "${*}"
}

function .log-debug() {
  if [[ ${LOG_LEVEL,,} =~ debug|verbose ]]; then
    LEVEL="${LOG_LEVEL_DEBUG}" .format "${*}"
  fi
}

function debug-only() {
  if [[ ${LOG_LEVEL,,} =~ debug|verbose ]]; then
    LEVEL="${LOG_LEVEL_DEBUG}" cat -
  fi
}

function log-debug() {
  .log-debug "${*}"
}

# =============================================================================

function log-server() {
  format-log >> "${LOG_PATH}/server.log"
}