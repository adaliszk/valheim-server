#!/bin/bash
# shellcheck disable=SC1091

function copy-files {
  SOURCE_PATH="${1}"
  TARGET_PATH="${2}"

  for FILE in "${SOURCE_PATH}"/*;
    do
      FILENAME="$(basename "$FILE")"
      COPY="cp -f ${FILE} ${TARGET_PATH}/${FILENAME}"
      debug-log "$COPY"
      $COPY
    done
}

function chown-path {
  log-stdout "Change ownership for ${1}"
  log-stdout "stat ${1}> $(stat -c '%U(%u):%G(%g)' "${1}")"

  log-stdout "Updating permissions..."
  find "${1}" -not -user "${USER}" -execdir chown "${PUID:-1001}:${PGID:-1001}" {} + | sed -e 's/^/s> /' || throw-permission-error "${1}"
  log-stdout "stat ${1}> $(stat -c '%U(%u):%G(%g)' "${1}")"
}

function throw-permission-error {
  log-stdout "Failed to set permissions for ${1}"
  log-stdout "Please make sure that volumes attached to that location are possible to change permissions or they are already using 1001:1001!"
  exit 1
}