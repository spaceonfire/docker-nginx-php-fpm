# Xdebug

Xdebug предустановлен в образ `spaceonfire/nginx-php-fpm`.
Чтобы включить отладку через xdebug вам необходимо передать несколько переменных окружения:

-   `ENABLE_XDEBUG=1` это добавит xdebug.ini в ваши расширения PHP.
-   `XDEBUG_REMOTE_HOST=you.local.ip.here` устанавливает настройку `xdebug.remote_host`.
    Здесь необходимо указать IP адрес хоста Docker. Если не указывать берется значение `default` из `ip route`,
    что отлично работает на Linux.
-   `XDEBUG_IDEKEY=youridekey` устанавливает настройку `xdebug.idekey`.
