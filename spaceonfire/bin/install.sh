#!/bin/bash
set -e

# Copy default error pages
for errorPage in /opt/spaceonfire/html/*.html; do
	filename=$(basename $errorPage)
	filename=${filename%.html}
	if [ ! "$filename" == "index" ]; then
		cp -f $errorPage /var/www/errors/
	fi
done

# Enable default preset
/opt/spaceonfire/bin/select-preset.sh default
