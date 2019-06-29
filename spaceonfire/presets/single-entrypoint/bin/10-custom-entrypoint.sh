#!/bin/bash

if [ ! -z "$ENTRYPOINT_SCRIPT" ]; then
	sed -i "s#index.php#${ENTRYPOINT_SCRIPT}#g" /etc/nginx/vhost.common.d/10-location-root.conf
fi
