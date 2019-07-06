ARG PHP_BASEIMAGE_VERION=7.3.6
FROM php:${PHP_BASEIMAGE_VERION}-fpm-alpine

LABEL maintainer="Constantine Karnaukhov <genteelknight@gmail.com>"

# Setup some env
ENV \
	# Setup same composer home directory for all users
	COMPOSER_HOME="/usr/local/composer" \
	# Fix for iconv: https://github.com/docker-library/php/issues/240
	LD_PRELOAD="/usr/lib/preloadable_libiconv.so php"

# Install dependencies
RUN echo @testing http://dl-4.alpinelinux.org/alpine/edge/testing >> /etc/apk/repositories && \
	apk update && apk upgrade && \
	apk add --no-cache \
		nginx \
		supervisor \
		gomplate \
		ssmtp \
		mysql-client \
		apk-cron \
		bash \
		su-exec \
		git \
		openssh-client \
		wget \
		curl \
		libcurl \
		augeas-dev \
		libressl-dev \
		ca-certificates \
		dialog \
		autoconf \
		make \
		gcc \
		musl-dev \
		linux-headers \
		libmcrypt-dev \
		libpng-dev \
		icu-dev \
		libpq \
		libxslt-dev \
		libffi-dev \
		freetype-dev \
		sqlite-dev \
		libjpeg-turbo-dev \
		acl \
		libzip-dev \
		&& \
	docker-php-ext-configure gd \
		--with-gd \
		--with-freetype-dir=/usr/include/ \
		--with-png-dir=/usr/include/ \
		--with-jpeg-dir=/usr/include/ && \
	docker-php-ext-install iconv pdo_mysql pdo_sqlite mysqli gd exif intl xsl json soap dom zip opcache && \
	pecl install xdebug-2.7.2 && \
	docker-php-source delete && \
	mkdir -p $COMPOSER_HOME && \
	EXPECTED_COMPOSER_SIGNATURE=$(wget -q -O - https://composer.github.io/installer.sig) && \
	php -r "copy('https://getcomposer.org/installer', 'composer-setup.php');" && \
	php -r "if (hash_file('SHA384', 'composer-setup.php') === '${EXPECTED_COMPOSER_SIGNATURE}') { echo 'Composer.phar Installer verified'; } else { echo 'Composer.phar Installer corrupt'; unlink('composer-setup.php'); } echo PHP_EOL;" && \
	php composer-setup.php --install-dir=/usr/bin --filename=composer && \
	php -r "unlink('composer-setup.php');" && \
	apk del gcc musl-dev linux-headers libffi-dev augeas-dev make autoconf && \
	apk add --no-cache --repository http://dl-3.alpinelinux.org/alpine/edge/community gnu-libiconv && \
	composer global require hirak/prestissimo

# tweak php-fpm config
RUN echo "" > /usr/local/etc/php/conf.d/05-php.ini && \
	{ \
		echo "cgi.fix_pathinfo = 0"; \
		echo "upload_max_filesize = 100M"; \
		echo "post_max_size = 100M"; \
		echo "variables_order = \"EGPCS\""; \
		echo "memory_limit = 128M"; \
	} >> /usr/local/etc/php/conf.d/05-php.ini && \
	sed -i \
		-e "s/;catch_workers_output\s*=\s*yes/catch_workers_output = yes/g" \
		-e "s/pm.max_children = 5/pm.max_children = 4/g" \
		-e "s/pm.start_servers = 2/pm.start_servers = 3/g" \
		-e "s/pm.min_spare_servers = 1/pm.min_spare_servers = 2/g" \
		-e "s/pm.max_spare_servers = 3/pm.max_spare_servers = 4/g" \
		-e "s/;pm.max_requests = 500/pm.max_requests = 200/g" \
		-e "s/user = www-data/user = nginx/g" \
		-e "s/group = www-data/group = nginx/g" \
		-e "s/;listen.mode = 0660/listen.mode = 0666/g" \
		-e "s/;listen.owner = www-data/listen.owner = nginx/g" \
		-e "s/;listen.group = www-data/listen.group = nginx/g" \
		-e "s/listen = 127.0.0.1:9000/listen = \/var\/run\/php-fpm.sock/g" \
		-e "s/^;clear_env = no$/clear_env = no/" \
		/usr/local/etc/php-fpm.d/www.conf

EXPOSE 8080 8443

COPY ./conf/supervisord.conf /etc/

# Copy nginx config and enable default vhost
COPY ./conf/nginx/ /etc/nginx/
RUN mkdir -p /etc/nginx && \
	mkdir -p /run/nginx && \
	mkdir -p /var/log/supervisor && \
	mkdir -p /var/www/html && \
	mkdir -p /var/www/errors && \
	mkdir -p /etc/nginx/ssl/ && \
	mkdir -p /etc/nginx/vhost.common.d && \
	mkdir -p /etc/nginx/sites-enabled && \
	ln -s /etc/nginx/sites-available/default.conf /etc/nginx/sites-enabled/default.conf

# Add spaceonfire
COPY ./spaceonfire/ /opt/spaceonfire/
RUN chmod -R +x /opt/spaceonfire/bin/* && /opt/spaceonfire/bin/install.sh

CMD ["/opt/spaceonfire/bin/entrypoint.sh"]
