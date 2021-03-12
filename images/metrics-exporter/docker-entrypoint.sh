#!/bin/bash

MTAIL_BIN="$(command -v mtail)"
echo "S> MTAIL_BIN: ${MTAIL_BIN}"

LOG_FILE="/logs/server.log"
if [ ! -f "${LOG_FILE}" ];
  then
    touch "${LOG_FILE}"
  fi

CMD="${MTAIL_BIN} --address 0.0.0.0 --progs /etc/mtail --logs ${LOG_FILE} --poll_interval 3s --logtostderr ${*}"
echo "S> ${CMD}"
$CMD
