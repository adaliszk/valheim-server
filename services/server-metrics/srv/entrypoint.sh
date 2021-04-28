#!/bin/bash

MTAIL_BIN="$(command -v mtail)"

CMD=(
  "${MTAIL_BIN}"
  "--address" "0.0.0.0"
  "--progs" "/etc/mtail"
  "--logs" "/logs/output.log"
  "--logs" "/logs/server.log"
  "--logs" "/logs/health.log"
  "--logs" "/logs/exit.log"
  "--poll_interval" "5s"
  "--logtostderr"
)

echo "${CMD[@]}"
"${CMD[@]}"
