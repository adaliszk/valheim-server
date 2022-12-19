#!/usr/bin/env bash
# Copyright © 2022 by Ádám Liszkai using BSD 2-Clause License
# https://source.adaliszk.io/valheim-server/license

source /scripts/motd.sh
source /scripts/utils.sh

trap gracefully-terminate SIGQUIT
trap gracefully-terminate SIGTERM
trap gracefully-terminate SIGINT

source /scripts/setup-bepinex.sh
source /scripts/setup.sh

/scripts/start-bepinex-server.sh 2>&1 | log Server
