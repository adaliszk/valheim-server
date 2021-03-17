#!/bin/bash

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

export SteamAppId=892970

log-env SERVER_NAME SERVER_PASSWORD SERVER_WORLD SERVER_PUBLIC
log-env SERVER_ADMINS SERVER_PERMITTED SERVER_BANNED

function list-to-file {
  if [[ -z "${1}" ]];
    then
      debug-log "Saving \"${1}\" into ${2}"
      echo "${1}" | tr ',' '\n' > "${DATA_PATH}/${2}"
    fi
}

list-to-file "${SERVER_ADMINS}" "adminlist.txt"
list-to-file "${SERVER_PERMITTED}" "permittedlist.txt"
list-to-file "${SERVER_BANNED}" "bannedlist.txt"
