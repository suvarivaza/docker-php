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

### Install
```
git clone https://github.com/suvarivaza/docker-php.git docker
cd docker
```

### Help
```
make help
```


### Start DEV

```
make init-dev
# edit .env variables.
make dev-setup
make up
```


### Production

```
make init-prod
# edit .env variables
# change email in traefik/config/traefik-prod.yml
make up
```

Enjoy!

> - App: https://myproject.local
> - Traefik:  https://traefik.myproject.local
> - Phpmyadmin: https://pma.myproject.local


### Some commands:
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
