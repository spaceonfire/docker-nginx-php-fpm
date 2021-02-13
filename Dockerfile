ARG PHP_BASEIMAGE_VERSION=8.0.2
FROM php:${PHP_BASEIMAGE_VERSION}-fpm-alpine

LABEL maintainer="Constantine Karnaukhov <genteelknight@gmail.com>"

# Setup some env
ENV \
	# Setup same composer home directory for all users
	COMPOSER_HOME="/usr/local/composer" \
	# Fix for iconv: https://github.com/docker-library/php/issues/240
	LD_PRELOAD="/usr/lib/preloadable_libiconv.so php"

ARG XDEBUG_VERSION=3.0.2
ARG PHP_EXTENSIONS="dom exif gd iconv intl mysqli opcache pdo_mysql pdo_sqlite soap xsl zip"

# Install dependencies
RUN apk add --update \
		acl \
		apk-cron \
		augeas-dev \
		autoconf \
		bash \
		curl \
		ca-certificates \
		dialog \
		freetype-dev \
		gomplate \
		git \
		gcc \
		icu-dev \
		libcurl \
		libffi-dev \
		libgcrypt-dev \
		libjpeg-turbo-dev \
		libmcrypt-dev \
		libpng-dev \
		libpq \
		libressl-dev \
		libxslt-dev \
		libzip-dev \
		linux-headers \
		make \
		musl-dev \
		mysql-client \
		nginx \
		openssh-client \
		ssmtp \
		sqlite-dev \
		supervisor \
		su-exec \
		wget \
		gnu-libiconv \
		&& \
	docker-php-ext-configure gd \
		--with-gd \
		--with-freetype-dir=/usr/include/ \
		--with-png-dir=/usr/include/ \
		--with-jpeg-dir=/usr/include/ \
		--enable-option-checking \
		--with-freetype \
		--with-jpeg && \
	docker-php-ext-install $PHP_EXTENSIONS && \
	git clone -b $XDEBUG_VERSION https://github.com/xdebug/xdebug.git /tmp/xdebug && \
	cd /tmp/xdebug && phpize && ./configure --enable-xdebug && make && make install && cd - && \
	rm -rf /tmp/xdebug && \
	docker-php-source delete && \
	apk del gcc musl-dev linux-headers libffi-dev augeas-dev make autoconf && \
	rm -rf /var/cache/apk/*

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
ENV PATH="${PATH}:${COMPOSER_HOME}/bin:${COMPOSER_HOME}/vendor/bin"
COPY ./spaceonfire/ /opt/spaceonfire/
RUN chmod -R +x /opt/spaceonfire/bin/* && /opt/spaceonfire/bin/install.sh

CMD ["/opt/spaceonfire/bin/entrypoint.sh"]
