#!/bin/bash
set -e

if php -i | grep -q "bcmath"; then
	echo "BCMath PHP Extension already installed"
else
	docker-php-ext-install bcmath
fi
