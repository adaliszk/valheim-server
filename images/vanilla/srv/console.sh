#!/bin/bash

function add-timestamp {
  sed -u "s/^/$(date +%Y-%m-%dT%H:%M:%S%z)> /;t"
}

function vhpretty {
  /srv/vhpretty.py
}

function tee-output {
   tee "${LOG_PATH}/output.log"
}

function tee-server-raw {
  tee "${LOG_PATH}/server-raw.log"
}

function tee-backup {
   tee "${LOG_PATH}/backup.log" | tee-output
}

function tee-exit {
  tee "${LOG_PATH}/exit.log" | tee-output
}

function server-log {
   tee-output | add-timestamp > "${LOG_PATH}/server.log"
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

function join_by {
  local d=$1; shift; local f=$1; shift; printf %s "$f" "${@/#/$d}"
}