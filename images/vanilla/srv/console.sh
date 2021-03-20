#!/bin/bash

function vhpretty {
  /srv/vhpretty.py
}

function vhtrigger {
  /srv/vhtrigger.py
}

function output-log {
  echo "${LOG_PATH}/output.log"
}

function tee-output {
   tee "$(output-log)"
}

function tee-server-raw {
  tee "${LOG_PATH}/server-raw.log"
}

function server-log {
  echo "${LOG_PATH}/server.log"
}

function tee-server {
  tee "$(server-log)"
}

function tee-backup {
   tee "${LOG_PATH}/backup.log" | tee-output
}

function tee-exit {
  tee "${LOG_PATH}/exit.log" | tee-output
}

function log {
  echo "c> ${*}" | tee-output
}

function log-env {
  for VAR in "$@"
  do
      debug-log "$VAR: ${!VAR:-(empty)}"
  done
}

function debug-log {
  echo "d> ${*}" | tee-output
}