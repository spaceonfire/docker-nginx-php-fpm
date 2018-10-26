#!/bin/bash
set -e

preset="default"

if [ -n "$1" ]; then
	preset="$1"
fi

presetDir="/opt/spaceonfire/presets/$preset"

if [ ! -d "$presetDir" ]; then
	echo "Preset not found"
	exit 1
fi

echo "Enable $preset preset configuration"

function cloneAndLinkRecursive() {
	local src=${1}
	local dest=${2}

	if [ -f $src ]; then
		dir=$(dirname $dest)
		mkdir -p $dir
		ln -sf $src $dest
	fi

	if [ -d $src ]; then
		for i in $src/*; do
			iSrc="$src/$(basename $i)"
			iDest="$dest/$(basename $i)"
			cloneAndLinkRecursive $iSrc $iDest
		done
	fi
}

cloneAndLinkRecursive "$presetDir/php" "/usr/local/etc/php/conf.d"

cloneAndLinkRecursive "$presetDir/nginx" "/etc/nginx"

cloneAndLinkRecursive "$presetDir/supervisor" "/etc/supervisor/conf.d"

if [ -d "$presetDir/bin" ]; then
	chmod -Rf 750 $presetDir/bin/*; sync;
	for i in $presetDir/bin/*; do $i ; done
fi
