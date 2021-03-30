#!/bin/bash

function ts-prefix() {
  /srv/ts-prefix.py
}

function vhpretty() {
  /srv/vhpretty.py
}

function vhwatch() {
  /srv/vhwatch.py
}

function output-log() {
  echo "${LOG_PATH}/output.log"
}

function tee-output() {
  tee "$(output-log)"
}

function server-raw-log() {
  echo "${LOG_PATH}/server-raw.log"
}

function tee-server-raw() {
  tee "$(server-raw-log)"
}

function server-log() {
  echo "${LOG_PATH}/server.log"
}

function tee-server() {
  ts-prefix >> "$(server-log)"
}

function backup-log() {
  echo "${LOG_PATH}/backup.log"
}

function tee-backup() {
  ts-prefix | tee "$(server-log)" >> "$(backup-log)"
}

function health-log() {
  echo "${LOG_PATH}/health.log"
}

function tee-health() {
  tee-output | ts-prefix >> "$(health-log)"
}

function exit-log() {
  echo "${LOG_PATH}/exit.log"
}

function tee-exit() {
  tee "$(exit-log)" | tee-output
}

function log() {
  log-info "OCI> ${*}" | tee-output
}

function log-env() {
  for VAR in "$@"; do
    log-debug "$VAR: ${!VAR:-(empty)}"
  done
}

function log-info() {
  echo "i> ${*}"
}

function log-debug() {
  if [[ ${LOG_LEVEL:-info} =~ debug|verbose ]]; then
    echo "d> ${*}"
  fi
}
