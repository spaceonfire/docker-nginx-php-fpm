FROM php:7.2.10-fpm-alpine

LABEL maintainer="Constantine Karnaukhov <genteelknight@gmail.com>"

# resolves gitlab.com/ric_harvey/nginx-php-fpm#166
ENV LD_PRELOAD /usr/lib/preloadable_libiconv.so php
RUN apk add --no-cache --repository http://dl-3.alpinelinux.org/alpine/edge/testing gnu-libiconv

# Install nginx
RUN NGINX_VERSION=1.14.0 \
	&& LUA_MODULE_VERSION=0.10.13 \
	&& DEVEL_KIT_MODULE_VERSION=0.3.0 \
	&& GPG_KEYS=B0F4253373F8F6F510D42178520A9993A1C052F8 \
	&& CONFIG="\
		--prefix=/etc/nginx \
		--sbin-path=/usr/sbin/nginx \
		--modules-path=/usr/lib/nginx/modules \
		--conf-path=/etc/nginx/nginx.conf \
		--error-log-path=/var/log/nginx/error.log \
		--http-log-path=/var/log/nginx/access.log \
		--pid-path=/var/run/nginx.pid \
		--lock-path=/var/run/nginx.lock \
		--http-client-body-temp-path=/var/cache/nginx/client_temp \
		--http-proxy-temp-path=/var/cache/nginx/proxy_temp \
		--http-fastcgi-temp-path=/var/cache/nginx/fastcgi_temp \
		--http-uwsgi-temp-path=/var/cache/nginx/uwsgi_temp \
		--http-scgi-temp-path=/var/cache/nginx/scgi_temp \
		--user=nginx \
		--group=nginx \
		--with-http_ssl_module \
		--with-http_realip_module \
		--with-http_addition_module \
		--with-http_sub_module \
		--with-http_dav_module \
		--with-http_flv_module \
		--with-http_mp4_module \
		--with-http_gunzip_module \
		--with-http_gzip_static_module \
		--with-http_random_index_module \
		--with-http_secure_link_module \
		--with-http_stub_status_module \
		--with-http_auth_request_module \
		--with-http_xslt_module=dynamic \
		--with-http_image_filter_module=dynamic \
		--with-http_geoip_module=dynamic \
		--with-http_perl_module=dynamic \
		--with-threads \
		--with-stream \
		--with-stream_ssl_module \
		--with-stream_ssl_preread_module \
		--with-stream_realip_module \
		--with-stream_geoip_module=dynamic \
		--with-http_slice_module \
		--with-mail \
		--with-mail_ssl_module \
		--with-compat \
		--with-file-aio \
		--with-http_v2_module \
		--add-module=/usr/src/ngx_devel_kit-$DEVEL_KIT_MODULE_VERSION \
		--add-module=/usr/src/lua-nginx-module-$LUA_MODULE_VERSION \
	" \
	&& export LUAJIT_LIB=/usr/lib \
	&& export LUAJIT_INC=/usr/include/luajit-2.1 \
	&& addgroup -S nginx \
	&& adduser -D -S -h /var/cache/nginx -s /sbin/nologin -G nginx nginx \
	&& apk add --no-cache --virtual .build-deps \
		autoconf \
		gcc \
		libc-dev \
		make \
		libressl-dev \
		pcre-dev \
		zlib-dev \
		linux-headers \
		curl \
		gnupg \
		libxslt-dev \
		gd-dev \
		geoip-dev \
		perl-dev \
		luajit-dev \
	&& curl -fSL http://nginx.org/download/nginx-$NGINX_VERSION.tar.gz -o nginx.tar.gz \
	&& curl -fSL http://nginx.org/download/nginx-$NGINX_VERSION.tar.gz.asc -o nginx.tar.gz.asc \
	&& curl -fSL https://github.com/simpl/ngx_devel_kit/archive/v$DEVEL_KIT_MODULE_VERSION.tar.gz -o ndk.tar.gz \
	&& curl -fSL https://github.com/openresty/lua-nginx-module/archive/v$LUA_MODULE_VERSION.tar.gz -o lua.tar.gz \
	&& export GNUPGHOME="$(mktemp -d)" \
	&& found=''; \
	for server in \
		ha.pool.sks-keyservers.net \
		hkp://keyserver.ubuntu.com:80 \
		hkp://p80.pool.sks-keyservers.net:80 \
		pgp.mit.edu \
	; do \
		echo "Fetching GPG key $GPG_KEYS from $server"; \
		gpg --keyserver "$server" --keyserver-options timeout=10 --recv-keys "$GPG_KEYS" && found=yes && break; \
	done; \
	test -z "$found" && echo >&2 "error: failed to fetch GPG key $GPG_KEYS" && exit 1; \
	gpg --batch --verify nginx.tar.gz.asc nginx.tar.gz \
	#&& rm -r "$GNUPGHOME" nginx.tar.gz.asc \
	&& mkdir -p /usr/src \
	&& tar -zxC /usr/src -f nginx.tar.gz \
	&& tar -zxC /usr/src -f ndk.tar.gz \
	&& tar -zxC /usr/src -f lua.tar.gz \
	&& rm nginx.tar.gz nginx.tar.gz.asc ndk.tar.gz lua.tar.gz \
	&& cd /usr/src/nginx-$NGINX_VERSION \
	&& ./configure $CONFIG --with-debug \
	&& make -j$(getconf _NPROCESSORS_ONLN) \
	&& mv objs/nginx objs/nginx-debug \
	&& mv objs/ngx_http_xslt_filter_module.so objs/ngx_http_xslt_filter_module-debug.so \
	&& mv objs/ngx_http_image_filter_module.so objs/ngx_http_image_filter_module-debug.so \
	&& mv objs/ngx_http_geoip_module.so objs/ngx_http_geoip_module-debug.so \
	&& mv objs/ngx_http_perl_module.so objs/ngx_http_perl_module-debug.so \
	&& mv objs/ngx_stream_geoip_module.so objs/ngx_stream_geoip_module-debug.so \
	&& ./configure $CONFIG \
	&& make -j$(getconf _NPROCESSORS_ONLN) \
	&& make install \
	&& rm -rf /etc/nginx/html/ \
	&& mkdir /etc/nginx/conf.d/ \
	&& mkdir -p /usr/share/nginx/html/ \
	&& install -m644 html/index.html /usr/share/nginx/html/ \
	&& install -m644 html/50x.html /usr/share/nginx/html/ \
	&& install -m755 objs/nginx-debug /usr/sbin/nginx-debug \
	&& install -m755 objs/ngx_http_xslt_filter_module-debug.so /usr/lib/nginx/modules/ngx_http_xslt_filter_module-debug.so \
	&& install -m755 objs/ngx_http_image_filter_module-debug.so /usr/lib/nginx/modules/ngx_http_image_filter_module-debug.so \
	&& install -m755 objs/ngx_http_geoip_module-debug.so /usr/lib/nginx/modules/ngx_http_geoip_module-debug.so \
	&& install -m755 objs/ngx_http_perl_module-debug.so /usr/lib/nginx/modules/ngx_http_perl_module-debug.so \
	&& install -m755 objs/ngx_stream_geoip_module-debug.so /usr/lib/nginx/modules/ngx_stream_geoip_module-debug.so \
	&& ln -s ../../usr/lib/nginx/modules /etc/nginx/modules \
	&& strip /usr/sbin/nginx* \
	&& strip /usr/lib/nginx/modules/*.so \
	&& rm -rf /usr/src/nginx-$NGINX_VERSION \
	\
	# Bring in gettext so we can get `envsubst`, then throw
	# the rest away. To do this, we need to install `gettext`
	# then move `envsubst` out of the way so `gettext` can
	# be deleted completely, then move `envsubst` back.
	&& apk add --no-cache --virtual .gettext gettext \
	&& mv /usr/bin/envsubst /tmp/ \
	\
	&& runDeps="$( \
		scanelf --needed --nobanner /usr/sbin/nginx /usr/lib/nginx/modules/*.so /tmp/envsubst \
			| awk '{ gsub(/,/, "\nso:", $2); print "so:" $2 }' \
			| sort -u \
			| xargs -r apk info --installed \
			| sort -u \
	)" \
	&& apk add --no-cache --virtual .nginx-rundeps $runDeps \
	&& apk del .build-deps \
	&& apk del .gettext \
	&& mv /tmp/envsubst /usr/local/bin/ \
	\
	# forward request and error logs to docker log collector
	&& ln -sf /dev/stdout /var/log/nginx/access.log \
	&& ln -sf /dev/stderr /var/log/nginx/error.log

# Configure php-fpm
RUN echo @testing http://nl.alpinelinux.org/alpine/edge/testing >> /etc/apk/repositories && \
	echo /etc/apk/respositories && \
	apk update && apk upgrade &&\
	apk add --no-cache \
		bash \
		openssh-client \
		wget \
		supervisor \
		curl \
		libcurl \
		git \
		python \
		python-dev \
		py-pip \
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
		ssmtp \
		apk-cron && \
	docker-php-ext-configure gd \
		--with-gd \
		--with-freetype-dir=/usr/include/ \
		--with-png-dir=/usr/include/ \
		--with-jpeg-dir=/usr/include/ && \
	docker-php-ext-install iconv pdo_mysql pdo_sqlite mysqli gd exif intl xsl json soap dom zip opcache && \
	pecl install xdebug-2.6.0 && \
	docker-php-source delete && \
	EXPECTED_COMPOSER_SIGNATURE=$(wget -q -O - https://composer.github.io/installer.sig) && \
	php -r "copy('https://getcomposer.org/installer', 'composer-setup.php');" && \
	php -r "if (hash_file('SHA384', 'composer-setup.php') === '${EXPECTED_COMPOSER_SIGNATURE}') { echo 'Composer.phar Installer verified'; } else { echo 'Composer.phar Installer corrupt'; unlink('composer-setup.php'); } echo PHP_EOL;" && \
	php composer-setup.php --install-dir=/usr/bin --filename=composer && \
	php -r "unlink('composer-setup.php');" && \
	composer global require hirak/prestissimo && \
	pip install -U pip && \
	pip install -U certbot && \
	mkdir -p /etc/letsencrypt/webrootauth && \
	apk del gcc musl-dev linux-headers libffi-dev augeas-dev python-dev make autoconf

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

EXPOSE 80 443

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
RUN chmod +x /opt/spaceonfire/init.sh && /opt/spaceonfire/init.sh

CMD ["sof-start"]
