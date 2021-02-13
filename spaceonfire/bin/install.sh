#!/bin/bash
set -e

# Install composer
EXPECTED_COMPOSER_SIGNATURE=$(wget -q -O - https://composer.github.io/installer.sig)
wget -q -O /tmp/composer-setup.php https://getcomposer.org/installer
php -r "if (hash_file('SHA384', '/tmp/composer-setup.php') !== '${EXPECTED_COMPOSER_SIGNATURE}') { throw new Exception('Composer.phar Installer corrupt'); }"
COMPOSER_HOME=/opt/spaceonfire/composer/v1 php /tmp/composer-setup.php --1 --install-dir=/opt/spaceonfire/composer/v1/bin --filename=composer
COMPOSER_HOME=/opt/spaceonfire/composer/v2 php /tmp/composer-setup.php --2 --install-dir=/opt/spaceonfire/composer/v2/bin --filename=composer
rm -f /tmp/composer-setup.php
/opt/spaceonfire/bin/select-composer.sh v1
composer global require hirak/prestissimo

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
