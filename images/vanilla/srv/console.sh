#!/bin/bash

function add-timestamp {
  sed -u "s/^/$(date +%Y-%m-%dT%H:%M:%S%z)> /;t"
}

function vhpretty {
  /srv/vhpretty.py
}

function tee-server {
   tee "${LOG_PATH}/server.log"
}

function tee-server-raw {
  tee "${LOG_PATH}/server-raw.log"
}

function tee-backup {
   tee "${LOG_PATH}/backup.log" | tee-output
}

function tee-output {
   tee "${LOG_PATH}/output.log" | tee-server
}

function tee-exit {
  tee "${LOG_PATH}/output.log"
}

function format-output {
  vhpretty | tee-output
}

function log {
  echo "S> ${*}" | tee-output
}

function debug-log {
  echo "D> ${*}" | tee-output
}
