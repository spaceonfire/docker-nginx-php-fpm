#!/bin/bash
set -e

# Make bin scripts executable and link them to /usr/local/bin
# to access them across the system
for script in /opt/spaceonfire/bin/*; do
	chmod +x $script
	ln -sf $script /usr/local/bin/
done

# Copy default error pages
for errorPage in /opt/spaceonfire/html/*.html; do
	filename=$(basename $errorPage)
	filename=${filename%.html}
	if [ ! "$filename" == "index" ]; then
		cp -f $errorPage /var/www/errors/
	fi
done

# Enable default preset
select-preset default
