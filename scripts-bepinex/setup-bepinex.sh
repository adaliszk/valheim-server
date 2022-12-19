# Copyright © 2022 by Ádám Liszkai using BSD 2-Clause License
# https://source.adaliszk.io/valheim-server/license

#
# INITIALIZE DATA VOLUME
#

mkdir -p /data/plugins

#
# MODDING INFO
#
cat <<-MODS_INFO
	> BepInEx Version:
	> Pre-installed Plugins: $(find /server/BepInEx/plugins/ -type f -name '*.dll' -exec basename {} .po \;)
	> Added Plugins: $(find /data/plugins -type f -name '*.dll' -exec basename {} .po \;)

MODS_INFO

#
# LOAD CONFIGS
#

if [ "$(ls -A /data/configs/*.{cfg,ini,json} 2>/dev/null)" ]; then
	echo "Initialize config files from /data" | log ConfigInit
	for config in /data/config/*{cfg,ini,json}; do
		filename=$(basename "${config}")
		echo "Copy ${config} into bepinex:/config/${filename}" | log BepInExSync DEBUG
		rm -rf "/server/BepInEx/config/${filename}"
		cat "${config}" >"/server/BepInEx/config/${filename}"
	done
fi

#
# INSTALL PLUGINS
#

if [ "$(ls -A /data/plugins/* 2>/dev/null)" ]; then
	echo "Install plugins from /data" | log BepInExInit
	cp -rf /data/plugins/* /server/BepInEx/plugins
fi
