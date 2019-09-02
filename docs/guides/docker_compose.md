# Гид Docker Compose

Данный гид покажет, как быстро и просто вы можете запустить ваше веб-приложение в контейнере используя утилиту docker-compose.

## Создаем конфиг

Сойдайте файл `docker-compose.yml` в корне вашего приложения со следующим содержанием:

```yaml
version: '3'

services:
  app:
    image: spaceonfire/nginx-php-fpm:latest-7.3
    environment:
      - SOF_PRESET=wordpress
      - SKIP_CHOWN=1
      - PUID=1000
      - ENABLE_XDEBUG=1
    volumes:
      - ./:/var/www/html:Z
    ports:
      - 80:80
      - 443:443
```

Данный пример запустит контейнер с примонтированной директорией с вашим кодом
и свяжет порты 80 и 443 между хостом и контейнером, так что вы сможете в браузере увидеть ваше
веб-приложение по адресу `http://localhost`.

Если вы не хотите завязывать один проект на порты 80 и 443, то можно использовать прокси из нашего
[проекта `localhost-docker`](https://github.com/dockeronfire/localhost-docker).
Тогда конфиг `docker-compose.yml` будет выглядеть немного иначе:

```yaml
version: '3'

services:
  app:
    image: spaceonfire/nginx-php-fpm:latest-7.3
    networks:
      - default
      - localhost
    environment:
      - VIRTUAL_HOST=${DOMAIN}
      - VIRTUAL_PORT=80
      - SOF_PRESET=wordpress
      - SKIP_CHOWN=1
      - PUID=1000
      - ENABLE_XDEBUG=1
    volumes:
      - ./:/var/www/html:Z

networks:
  localhost:
    external: true

```

Вы также можете передать другие переменные окружения из раздела [Конфигурация](../configure.md) документации.

## Запуск

Чтобы запустить контейнер просто выполните: `docker-compose up -d`

## Остановка

Выполните `docker-compose down` чтобы остановить и удалить контейнер и созданную сеть.
