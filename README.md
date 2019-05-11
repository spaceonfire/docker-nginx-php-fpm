# spaceonfire/nginx-php-fpm

`spaceonfire/nginx-php-fpm` - Docker образ, основанный на Alpine Linux, с установленными Nginx и PHP-FPM.

## Обзор

Данный Docker образ позволяет докеризировать любое приложение на PHP. `spaceonfire/nginx-php-fpm`
из коробки предоставляет набор различных пресетов, покрывающих потребность запуска различных веб-приложений
на PHP. Доступны настройки для простых PHP приложений, а также веб-приложений на WordPress, Laravel и 1С-Битрикс.

Если у вас есть улучшения или предложения, пожалуйста,
не стесняйтесь открывать issue илл pull request на странице проекта GitHub.

### Версии ПО в образе

| Docker Tag   | Git Release   | Nginx Version | PHP Version | Alpine Version |
| ------------ | ------------- | ------------- | ----------- | -------------- |
| latest/1.3.3 | Master Branch | 1.14.0        | 7.2.10      | 3.7            |

## Быстрый старт

Спуллить образ с Docker Hub:

```
docker pull spaceonfire/nginx-php-fpm:latest
```

### Запуск простого PHP приложения

Чтобы запустить ваше простое PHP приложение, не требующее особых правил роутинга, в директории с исходным кодом выполните:

```
docker run -d -v `pwd`:/var/www/html -p 80:8080 spaceonfire/nginx-php-fpm:latest
```

После запуска контейнера вы можете открыть в браузере `http://localhost:8080/`.

Для более подробных примеров обратитесь к документации и гидам.

## Документация

-   [Архитектура образа](./docs/architecture.md)
-   [Конфигурация](./docs/configure.md)
-   [Пресеты](./docs/presets.md)
-   [Идентификаторы пользователя / группы](./docs/uid_gid.md)
-   [Настройка Nginx](./docs/nginx_configuration.md)
-   [PHP модули](./docs/php_modules.md)
-   [Xdebug](./docs/xdebug.md)
-   [Логи и ошибки](./docs/logs.md)

## Гиды

-   [Docker Compose](./docs/guides/docker_compose.md)
