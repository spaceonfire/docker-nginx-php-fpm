# spaceonfire/nginx-php-fpm

[![Latest Version][ico-version]][link-docker-hub]
[![Image Size][ico-image-size]][link-docker-hub]
[![Software License][ico-license]](LICENSE.md)
[![Pipeline Status][ico-pipeline-status]][link-gitlab-pipelines]

[`spaceonfire/nginx-php-fpm`][link-docker-hub] -
Docker образ, основанный на Alpine Linux, с установленными Nginx и PHP-FPM.

## Обзор

Данный Docker образ позволяет докеризировать любое приложение на PHP. `spaceonfire/nginx-php-fpm`
из коробки предоставляет набор различных пресетов, покрывающих потребность запуска различных веб-приложений
на PHP. Доступны настройки для простых PHP приложений, а также веб-приложений на WordPress, Laravel и 1С-Битрикс.

Если у вас есть улучшения или предложения, пожалуйста,
не стесняйтесь открывать issue или pull request на странице проекта GitHub.

### Версии ПО в образе

| Docker Tag                            | PHP Version |
| ------------------------------------- | ----------- |
| `latest` / `latest-8.0` / `2.5.0-8.0` | 8.0.2       |
| `latest-7.4` / `2.5.0-7.4`            | 7.4.15      |
| `latest-7.3` / `2.5.0-7.3`            | 7.3.27      |
| `latest-7.2` / `2.5.0-7.2`            | 7.2.34      |

## Быстрый старт

Скачать образ с Docker Hub:

```
docker pull spaceonfire/nginx-php-fpm:latest
```

### Запуск простого PHP приложения

Чтобы запустить ваше простое PHP приложение, не требующее особых правил роутинга, в директории с исходным кодом выполните:

```
docker run -d -v `pwd`:/var/www/html -p 8080:8080 spaceonfire/nginx-php-fpm:latest
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

[ico-image-size]: https://img.shields.io/microbadger/image-size/spaceonfire/nginx-php-fpm
[ico-pipeline-status]: https://gitlab.com/spaceonfire/open-source/nginx-php-fpm/badges/master/pipeline.svg
[ico-version]: https://img.shields.io/github/v/tag/spaceonfire/docker-nginx-php-fpm?sort=semver
[ico-license]: https://img.shields.io/github/license/spaceonfire/docker-nginx-php-fpm
[link-gitlab-pipelines]: https://gitlab.com/spaceonfire/open-source/nginx-php-fpm/pipelines
[link-docker-hub]: https://hub.docker.com/r/spaceonfire/nginx-php-fpm
