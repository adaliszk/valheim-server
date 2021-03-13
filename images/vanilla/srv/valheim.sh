#!/bin/bash
# shellcheck disable=SC1091
source /srv/init-env.sh
source /srv/init-user.sh
source /srv/init-volumes.sh

su -c "/srv/exec.sh ${*}" - "${USER}"
