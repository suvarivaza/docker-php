# include default env file
ifneq ("$(wildcard .env)","")
    include .env
endif

# if need to include one more env file
#DOCKER_ENV_FILES=--env-file .env
#
## include application env file
#ifneq ("$(wildcard $(APP_PATH)/.env)","")
#    include $(APP_PATH)/.env
#    DOCKER_ENV_FILES=--env-file .env --env-file $(APP_PATH)/.env
#endif


# Get arguments from command line. For example ARGS=value for command line: make command value
#https://stackoverflow.com/questions/6273608/how-to-pass-argument-to-makefile-from-command-line
ARGS=$(filter-out $@,$(MAKECMDGOALS))

COUNT_ARGS := $(shell echo $(ARGS) | wc -w)

# Error if arguments more then 3
ifeq ($(shell expr $(COUNT_ARGS) \> 3), 1)
 $(error Maximum 3 arguments are allowed for make command! Example 2 arg: make up php | Example 3 arg: make npm run dev)
endif


.PHONY: help
help:
	@echo ======= Help =======
	@echo 'You can pass the third parameter to the make command like this: make up php'
	@egrep -h '^[^[:blank:]].*\s##\s' $(MAKEFILE_LIST) | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-25s\033[0m %s\n", $$1, $$2}'

.DEFAULT_GOAL := help


#============= Init ===============#

.PHONY: init-dev
init-dev: ## Init dev environments
	cp .env.dev.example .env && \
	make set-userid-groupid

.PHONY: init-prod
init-prod: ## Init prod environments
	cp .env.prod.example .env && \
	make set-userid-groupid

.PHONY: set-userid-groupid
set-userid-groupid:
	echo "" >> .env && \
    echo "# Host user id and group id (for correct permissions inside docker)" >> .env && \
    echo "USER_ID=$(shell id -u)" >> .env && \
    echo "GROUP_ID=$(shell id -g)" >> .env


#============= Setup local host for DEV  ===============#

.PHONY: dev-setup
dev-setup:  ## Setup all for dev
	make set-dev-local-hosts
	make create-traefik-local-cert-config
	make create-local-ssl-cert-mkcert

.PHONY: set-dev-local-hosts
set-dev-local-hosts: ## Setup dev local hosts (use this command only for dev!)
	@if ! grep -q "^127.0.0.1 $(APP_URL)$$" /etc/hosts; then \
		echo "127.0.0.1 $(APP_URL)" | sudo tee -a /etc/hosts > /dev/null; \
	else \
		echo "↪️  Entry '127.0.0.1 $(APP_URL)' already exists in /etc/hosts"; \
	fi
	@if ! grep -q "^127.0.0.1 traefik.$(APP_URL)$$" /etc/hosts; then \
		echo "127.0.0.1 traefik.$(APP_URL)" | sudo tee -a /etc/hosts > /dev/null; \
	else \
		echo "↪️  Entry '127.0.0.1 traefik.$(APP_URL)' already exists in /etc/hosts"; \
	fi
	@if ! grep -q "^127.0.0.1 pma.$(APP_URL)$$" /etc/hosts; then \
    	echo "127.0.0.1 pma.$(APP_URL)" | sudo tee -a /etc/hosts > /dev/null; \
    else \
    	echo "↪️  Entry '127.0.0.1 pma.$(APP_URL)' already exists in /etc/hosts"; \
    fi
	tail /etc/hosts

.PHONY: create-traefik-local-cert-config
create-traefik-local-cert-config:
	@echo "tls:\n  certificates:\n  - certFile: \"/certs/$(APP_URL).crt\"\n  keyFile: \"/certs/$(APP_URL).key\"" > ./traefik/config/dev-tls.yml

.PHONY: create-local-ssl-cert-mkcert
create-local-ssl-cert-mkcert: ## Generate SSL cert for local domains with mkcert (recommend!)
	brew install mkcert && \
	mkcert -install && \
	mkcert \
      -key-file ./traefik/certs/$(APP_URL).key \
      -cert-file ./traefik/certs/$(APP_URL).crt \
      $(APP_URL) traefik.$(APP_URL) pma.$(APP_URL)

.PHONY: create-local-ssl-cert
create-local-ssl-cert:
	openssl req -x509 -nodes -newkey rsa:2048 \
      -keyout "./traefik/certs/$(APP_URL).key" \
      -out "./traefik/certs/$(APP_URL).crt" \
      -days 365 \
      -subj "/CN=$(APP_URL)"


#============= Start ===============#

.PHONY: up
up: ## Start all services | up one service: make up php
	docker compose up -d --build $(ARGS)

.PHONY: build
build: ## Build all services | build one service: make build php
	docker compose build --no-cache $(ARGS)

.PHONY: restart
restart: ## Restart all services | restart one service: make restart php
	docker compose restart $(ARGS)

.PHONY: hard-restart
hard-restart: ## Hard restart ALL services (make down && make up)
	make down && make up

.PHONY: stop
stop: ## Stop all services | stop one service: make stop php
	docker compose stop $(ARGS)

.PHONY: connect
connect: ## Connect to service. Example: make connect php
	docker compose exec $(ARGS) bash

.PHONY: connect-root
connect-root: ## Connect to service as root. Example: make connect-root php
	docker compose exec -u 0 $(ARGS) bash

.PHONY: logs
logs: ## Logs all services | one service: make logs php
	docker compose logs -f --tail=20 $(ARGS)

.PHONY: down
down: ## Delete all containers | one service: make down php
	docker compose down $(ARGS)

.PHONY: down-vol
down-vol: ## Delete all containers + volumes | one service: make down-vol php
	docker compose down -v $(ARGS)

.PHONY: down-img
down-img: ## Delete all containers + images | one service: make down-img php
	docker compose down --rmi all $(ARGS)

.PHONY: down-all
down-all: ## WARNING! Delete ALL! containers + networks + images + volumes | one service: make down-all php
	docker compose down -v --rmi all $(ARGS)

.PHONY: ps
ps: ## Show containers.
	docker compose ps

.PHONY: config
config: ## Show containers.
	docker compose config


#============= Laravel ===============#

.PHONY: laravel-install
laravel-install: ## Install Laravel
	docker compose exec php composer create-project laravel/laravel example-app \
	&& mv -f $(APP_PATH)/example-app/* $(APP_PATH)/ && mv -f $(APP_PATH)/example-app/.* $(APP_PATH)/ && rm -rf $(APP_PATH)/example-app

.PHONY: composer-install
composer-install: ## composer install
	docker compose exec -u 0 php composer install --no-cache --ansi --no-interaction

.PHONY: tinker
tinker: ## php artisan tinker
	docker compose exec php php artisan tinker

.PHONY: migrate
migrate: ## php artisan migrate
	docker compose exec php php artisan migrate

.PHONY: php-artisan
php-artisan: ## php artisan commands. example: make php-artisan tinker | php artisan migrate | and others php artisan commands..
	docker compose exec php php artisan $(ARGS)

#============= NPM ===============#

.PHONY: npm
npm: ## Examples: make npm install | make npm run build | make npm run dev | and others npm commands..
	docker compose exec node npm $(ARGS)


#============= Database ===============#

.PHONY: db-import
db-import: ## Import database from file: make db-import filepath=../db.sql
	sudo docker exec -i $(COMPOSE_PROJECT_NAME)-mysql mysql -u $(DB_USERNAME) -p$(DB_PASSWORD) $(DB_DATABASE) < $(filepath)

.PHONY: download-db
download-db: ## download db dump by ssh: make download-db SSH=root@123.456.78.90
	ssh $(SSH) "mysqldump -u $(DB_USERNAME) -p $(DB_DATABASE) | gzip" > db.sql.gz
	gunzip db.sql.gz

.PHONY: download-db-dev
download-db-dev:
	ssh $(SSH) "mysqldump -u $(DB_USERNAME) -p $(DB_DATABASE) --where='true limit 10000' | gzip" > db.sql.gz
	gunzip db.sql.gz

#============= Portainer ===============#

.PHONY: portainer-install
portainer-install: ## Install portainer
	docker run -d -p 9000:9000 --name portainer --restart always -v /var/run/docker.sock:/var/run/docker.sock portainer/portainer-ce



