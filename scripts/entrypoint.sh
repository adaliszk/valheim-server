#!/usr/bin/env bash
# Copyright © 2022 by Ádám Liszkai using BSD 2-Clause License
# https://source.adaliszk.io/valheim-server/license

cat <<-WELCOME_MESSAGE

	THANK YOU FOR USING ADALISZK/VALHEIM-SERVER!

	Copyright © 2022 by Ádám Liszkai using BSD 2-Clause License
	Documentation: https://docs.adaliszk.io/valheim-server
	Source: https://github.com/adaliszk/valheim-server

	> Valheim version: ${APP_VERSION}
	> Build: ${APP_BUILD}
	> User: $(id)
	> Workdir: $(ls -ld /tmp/valheim-server)
	> Savedir: $(ls -ld /data)

WELCOME_MESSAGE

[[ -f /logs/server.log ]] && mv /logs/server.log "/logs/$(date "+%Y-%m-%dT%H%M%S%z").log"
touch /logs/server.log

source /scripts/utils.sh
source /scripts/setup.sh

echo "Parsing Arguments: ${*:-(none)}" | capture-output ArgParser
while [[ $# -gt 0 ]]; do
  [[ $1 =~ -name(=| )(.*) ]] && export SERVER_NAME="${BASH_REMATCH[2]}"
  [[ $1 =~ -password(=| )(.*) ]] && export SERVER_PASSWORD="${BASH_REMATCH[2]}"
  [[ $1 =~ -world(=| )(.*) ]] && export SERVER_WORLD="${BASH_REMATCH[2]}"
  [[ $1 =~ -public(=| )(.*) ]] && export SERVER_PUBLIC="${BASH_REMATCH[2]}"
  [[ $1 =~ -admins(=| )(.*) ]] && export ADMIN_LIST="${BASH_REMATCH[2]}"
  [[ $1 =~ -permitted(=| )(.*) ]] && export PERMITTED_LIST="${BASH_REMATCH[2]}"
  [[ $1 =~ -banned(=| )(.*) ]] && export BANNED_LIST="${BASH_REMATCH[2]}"
  [[ $1 =~ -saveinternal(=| )(.*) ]] && export SAVE_INTERVAL="${BASH_REMATCH[2]}"
  [[ $1 =~ -backups(=| )(.*) ]] && export BACKUP_RETENTION="${BASH_REMATCH[2]}"
  [[ $1 =~ -backupshort(=| )(.*) ]] && export BACKUP_FIRST_INTERVAL="${BASH_REMATCH[2]}"
  [[ $1 =~ -backuplong(=| )(.*) ]] && export BACKUP_CYCLE_INTERVAL="${BASH_REMATCH[2]}"
  [[ $1 =~ -crossplay ]] && export SERVER_CROSSPLAY="true"
  shift
done

trap gracefully-terminate SIGQUIT
trap gracefully-terminate SIGTERM
trap gracefully-terminate SIGINT

source /scripts/server.sh
