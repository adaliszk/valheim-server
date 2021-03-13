#!/bin/bash
# shellcheck disable=SC1091

source /srv/init-env.sh
source /srv/init-user.sh
source /srv/init-volumes.sh

export > /env

log-stdout "Exec with ${USER}"
su -m "${USER}" -c "/srv/exec.sh ${*}"

