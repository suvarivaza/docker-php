This is docker compose environment for Laravel and other PHP applications!

- Ready for development and production!
- Easy to start!
- Free Let's Encrypt SSL certificates!

Services:
- traefik https://github.com/traefik/traefik
- php https://github.com/serversideup/docker-php
- mysql 
- phpmyadmin 
- redis

### Install
```
git clone https://github.com/suvarivaza/laravel-docker-traefik.git docker
cd docker
```

### Help
```
make help
```

### Start DEV

```
make init-dev
(set .env variables)
make up
```
Do not forget set .env variables after command: make init-dev!

> - The app will be: http://localhost/
> - Phpmyadmin: http://localhost:8080/




### Production

```
make init-prod
(set .env variables)
make up
```
Do not forget set .env variables after command: make init-prod!


### Main commands:
```
make up
make build
make restart
make stop
make down
make logs
```

Specific service:
```
make up php
make build php
make restart php
make stop php
make down php
make logs php
make connect php
```

#### Laravel commands:
```
make laravel-install
make composer-install
make tinker
make migrate
make php-artisan tinker | php artisan migrate | and others php artisan commands ...
```

#### NPM commands:
```
make npm install 
make npm run build 
make npm run dev
..and others npm commands..
```



### Additionally

```
make db-import filepath=path/db.sql
make portainer-install
```


#### Laravel Vite configuration
For Laravel Vite support just add to vite.config.js:
```
server: {
            host: '0.0.0.0',
        },
```
