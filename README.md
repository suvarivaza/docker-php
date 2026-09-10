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

### Project location

Set `APP_PATH` in `docker/.env`. Relative paths are resolved from the Docker
configuration directory. Absolute paths and paths containing spaces are supported.

| Layout | APP_PATH |
| --- | --- |
| `workspace/docker` next to `workspace/src` | `../src` |
| `project/docker` inside the project | `..` |
| Project in another location | `/srv/my-project` |

Run commands from the Docker directory (`cd docker`), or use `make -C /path/to/docker`.
For existing configurations, replace `APP_DIR=src` with `APP_PATH=../src`.
`APP_WEBROOT` is a separate path inside the container; use
`/var/www/html/public` for Laravel.

When Docker is inside the application, keep its directory outside the public
webroot. The Laravel `public` directory provides this separation.

To download application files, set `SSH` and `SSH_APP_PATH` (the remote project
path), then run `make download-files`. Files are extracted into local `APP_PATH`;
existing application files may be replaced. `.env`, `.git`, directories named
`docker`, and the local Docker configuration directory are excluded.

### DEV

```
1. make init-dev
2. edit .env variables
3. make dev-setup-local-ssl (if you need SSL in DEV)
4. make up
```
Enjoy!
- App: https://myproject.localhost
- Traefik:  https://traefik.myproject.localhost
- Phpmyadmin: https://pma.myproject.localhost



### Production

```
1. make init-prod
2. edit .env variables
3. make up
```


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
