#!/bin/bash
source /srv/init-env.sh

if [[ ! -d "${SERVER_PATH}/valheim_server_Data" ]];
  then
    echo "Extracting Server files in ${SERVER_PATH}"

    # @TODO: Should use `time` but `-f` wasn't working, so this is a quick and dirty solution
    EXTRACT_BEGIN=$(date +%s.%N)
    tar -xzvf "${SERVER_PATH}/valheim_server_Data.tar.gz"
    EXTRACT_END=$(date +%s.%N)

    echo "Extracting Server files took $(bc -l <<< "(${EXTRACT_END}-${EXTRACT_BEGIN})*1000")ms"
  else
    echo "Server files already extracted, skipping..."
  fi

# Print out some stats for the Metrics exporter
WORLD_FILE="${DATA_PATH}/worlds/${SERVER_WORLD}.db"
if [ -f "${WORLD_FILE}" ];
  then
    echo "World \"${SERVER_WORLD}\" is $(stat --printf="%s" "${WORLD_FILE}") bytes large"
    echo "Worlds are $(du --bytes "${DATA_PATH}/worlds" | cut -f1) bytes large"
  fi

log "Creating Log files..."
touch "${LOG_PATH}"/{server-raw,server,output,error,backup,restore,health,exit}.log

while [[ $# -gt 0 ]]
do
  [[ $1 =~ -name(=| )(.*) ]] && export SERVER_NAME="${BASH_REMATCH[2]}"
  [[ $1 =~ -password(=| )(.*) ]] && export SERVER_PASSWORD="${BASH_REMATCH[2]}"
  [[ $1 =~ -world(=| )(.*) ]] && export SERVER_WORLD="${BASH_REMATCH[2]}"
  [[ $1 =~ -public(=| )(.*) ]] && export SERVER_PUBLIC="${BASH_REMATCH[2]}"
  [[ $1 =~ -admins(=| )(.*) ]] && export SERVER_ADMINS="${BASH_REMATCH[2]}"
  [[ $1 =~ -permitted(=| )(.*) ]] && export SERVER_PERMITTED="${BASH_REMATCH[2]}"
  [[ $1 =~ -banned(=| )(.*) ]] && export SERVER_BANNED="${BASH_REMATCH[2]}"
  shift
done

log-env SERVER_NAME SERVER_PASSWORD SERVER_WORLD SERVER_PUBLIC
log-env SERVER_ADMINS SERVER_PERMITTED SERVER_BANNED

function list-to-file {
  if [[ -n "${1}" ]];
    then
      debug-log "Saving \"${1}\" into ${2}"
      echo "${1}" | tr ',' '\n' > "${DATA_PATH}/${2}"
    fi
}

list-to-file "${SERVER_ADMINS}" "adminlist.txt"
list-to-file "${SERVER_PERMITTED}" "permittedlist.txt"
list-to-file "${SERVER_BANNED}" "bannedlist.txt"