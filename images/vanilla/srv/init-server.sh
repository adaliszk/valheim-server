#!/bin/bash
source /srv/init-env.sh

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

function list-to-file {
  log-stdout "Saving \"${1}\" into ${2}"
  echo "${1}" | tr ',' '\n' > "${DATA_PATH}/${2}"
}

list-to-file "${SERVER_ADMINS}" "adminlist.txt"
list-to-file "${SERVER_PERMITTED}" "permittedlist.txt"
list-to-file "${SERVER_BANNED}" "bannedlist.txt"


echo "Extracting Server files in $(pwd)"
# Could use `time` but for some reason `-f` wasn't working
EXTRACT_BEGIN=$(date +%s)
tar -xzf "${SERVER_PATH}/valheim_server_Data.tar.gz"
EXTRACT_END=$(date +%s)
echo "Extracting Server files took $((EXTRACT_END-EXTRACT_BEGIN))s"