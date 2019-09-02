#!/bin/bash
set -e

if [ ! -x /usr/local/bin/wp ]; then
	echo "Install WP-CLI"
	curl -O https://raw.githubusercontent.com/wp-cli/builds/gh-pages/phar/wp-cli.phar
	chmod +x wp-cli.phar
	mv wp-cli.phar /usr/local/bin/wp
else
	echo "WP-CLI already installed"
fi
