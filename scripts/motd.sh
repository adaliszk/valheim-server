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
	> Workdir: /tmp/valheim-server $(stat -c '(%u:%g with %A)' /tmp/valheim-server)
	> Datadir: /data $(stat -c '(%u:%g with %A)' /data)

WELCOME_MESSAGE