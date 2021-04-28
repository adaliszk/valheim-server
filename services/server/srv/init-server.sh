#!/bin/bash
# shellcheck disable=SC1091
source /srv/console.sh
log-group "ServerInit"

# Extract the server data
if [[ ! -d "${SERVER_PATH}/valheim_server_Data" ]]; then
  echo "Extracting server files in ${SERVER_PATH}"

  EXTRACT_TIME=$({ time tar -xzf "${SERVER_PATH}/valheim_server_Data.tar.gz"; } 2>&1)
  echo "Extracting Server files took ${EXTRACT_TIME}"
else
  echo "Server files already extracted, skipping..."
fi

# Parse the input parameters
while [[ $# -gt 0 ]]; do
  [[ $1 =~ -name(=| )(.*) ]] && export SERVER_NAME="${BASH_REMATCH[2]}"
  [[ $1 =~ -password(=| )(.*) ]] && export SERVER_PASSWORD="${BASH_REMATCH[2]}"
  [[ $1 =~ -world(=| )(.*) ]] && export SERVER_WORLD="${BASH_REMATCH[2]}"
  [[ $1 =~ -public(=| )(.*) ]] && export SERVER_PUBLIC="${BASH_REMATCH[2]}"
  [[ $1 =~ -admins(=| )(.*) ]] && export SERVER_ADMINS="${BASH_REMATCH[2]}"
  [[ $1 =~ -permitted(=| )(.*) ]] && export SERVER_PERMITTED="${BASH_REMATCH[2]}"
  [[ $1 =~ -banned(=| )(.*) ]] && export SERVER_BANNED="${BASH_REMATCH[2]}"
  shift
done

function log-env() {
  for VAR in "$@"; do
    echo "::debug::$VAR: ${!VAR:-(empty)}"
  done
}

log-env SERVER_NAME SERVER_PASSWORD SERVER_WORLD SERVER_PUBLIC
log-env SERVER_ADMINS SERVER_PERMITTED SERVER_BANNED

function list-to-file() {
  if [[ -n "${1}" ]]; then
    echo "Saving \"${1}\" into ${2}"
    echo "${1}" | tr ',' '\n' >"${DATA_PATH}/${2}"
  fi
}

list-to-file "${SERVER_ADMINS}" "adminlist.txt"
list-to-file "${SERVER_PERMITTED}" "permittedlist.txt"
list-to-file "${SERVER_BANNED}" "bannedlist.txt"

# Print out some stats for the Metrics exporter
WORLD_SCHEMA="${DATA_PATH}/worlds/${SERVER_WORLD}.fwl"
WORLD_DATA="${DATA_PATH}/worlds/${SERVER_WORLD}.db"
echo "World file: ${WORLD_DATA}"

if [[ -f "${WORLD_SCHEMA}" ]]; then
  # shellcheck disable=SC2207
  # In this case, we actually want to split the output
  SCHEMA=($(strings -a "${WORLD_SCHEMA}"))
  MAP_NAME=$(echo "${SCHEMA[0]}" | sed -uE 's/^!//gi')
  MAP_SEED="${SCHEMA[1]}"

  echo "Map name stored in the Schema file: ${MAP_NAME}"
  echo "Map seed: ${MAP_SEED}"

  if [[ "${SERVER_WORLD}" != "${MAP_NAME}" ]]; then
    echo "::empty::"
    echo "::raw::ERROR: THE PROVIDED WORLD WAS RENAMED INCORRECTLY!"
    echo "::empty::"
    echo "::error::Renaming should be done with a dedicated tool like: https://geekstrom.de/valheim/fwl"
    echo "::error::Please, fix the problem before proceeding!"
    exit 1
  fi
else
  echo "::warning::World schema is not found, unless you are generating a fresh world this might be a problem!"
fi

if [[ -f "${WORLD_DATA}" ]]; then
  echo "World \"${SERVER_WORLD}\" is $(stat --printf="%s" "${WORLD_DATA}") bytes large"
  echo "World data is $(du --bytes "${DATA_PATH}/worlds" | cut -f1) bytes large"
else
  echo "::warning::World save is not found, unless you are generating a fresh world this might be a problem!"
fi

echo "::metric::Initializing Server took" | console-timeEnd "ServerInit"
