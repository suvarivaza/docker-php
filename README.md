This is docker compose environment for Laravel and other PHP websites and applications!

- Ready for development and production!
- Easy to start!
- Free Let's Encrypt SSL certificates!
- Secure for phpmyadmin in production!


Services:
- traefik https://github.com/traefik/traefik
- php https://github.com/serversideup/docker-php
- mysql 
- phpmyadmin 
- redis
- node

### Install
```
git clone https://github.com/suvarivaza/docker-php.git docker
cd docker
make help
```

### Production

```
1. make init-prod
2. edit .env variables
3. make up
```


### DEV

```
1. make init-dev
2. edit .env variables
3. make up
```
if you need SSL in DEV just do: make dev-setup-ssl

- App: https://myproject.local
- Traefik:  https://traefik.myproject.local
- Phpmyadmin: https://pma.myproject.local


### Some commands:
```
make up
make stop
make restart
make down
make logs
```

You can use specific service:
```
make up php
make stop php
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
make db-import DB_FILE=path/db.sql
make portainer-install
```


#### Laravel Vite configuration
For Laravel Vite support just add to vite.config.js:
```
server: {
            host: '0.0.0.0',
        },
```
