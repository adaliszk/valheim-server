#!/bin/bash

function add-timestamp {
  sed -u "s/^/$(date +%Y-%m-%dT%H:%M:%S%z)> /;t"
}

function valheim-console {
  /srv/valheim-console.py
}

function tee-backup {
   tee "${LOG_PATH}/backup.log" | tee-output
}

function tee-output {
   tee "${LOG_PATH}/output.log" | add-timestamp > "${LOG_PATH}/server.log"
}

function tee-exit {
  tee "${LOG_PATH}/output.log" | add-timestamp > "${LOG_PATH}/exit.log"
}

function format-output {
  valheim-console | tee-output
}

function log {
  echo "S> ${*}" | tee-output
}
