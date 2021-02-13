#!/bin/bash
set -e

if [ "$COMPOSER_HOME" = "" ] && [ ! -L "$COMPOSER_HOME" ]; then
	echo "COMPOSER_HOME not defined or not a link."
	exit 1
fi

if [ ! -d "/opt/spaceonfire/composer/$1" ]; then
	echo "Unknown composer version: $1. Try to use \"v1\" or \"v2\""
	exit 1
fi

rm -f "$COMPOSER_HOME"
ln -sf "/opt/spaceonfire/composer/$1" "$COMPOSER_HOME"
