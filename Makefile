DOCKER_ENV_FILES=--env-file .env

# include default env file
ifneq ("$(wildcard .env)","")
    include .env
endif

# include application env file
ifneq ("$(wildcard $(APP_PATH)/.env)","")
    include $(APP_PATH)/.env
    DOCKER_ENV_FILES=--env-file .env --env-file $(APP_PATH)/.env
endif


# Get arguments from command line. For example ARGS=value for command line: make command value
#https://stackoverflow.com/questions/6273608/how-to-pass-argument-to-makefile-from-command-line
ARGS=$(filter-out $@,$(MAKECMDGOALS))

COUNT_ARGS := $(shell echo $(ARGS) | wc -w)

# Error if arguments more then 3
ifeq ($(shell expr $(COUNT_ARGS) \> 3), 1)
 $(error Maximum 3 arguments are allowed for make command! Example 2 arg: make up php | Example 3 arg: make npm run dev)
endif


#============= Help ===============#
.PHONY: help
help:
	@echo ======= Help =======
	@echo 'You can pass the third parameter to the make command like this: make up php'
	@egrep -h '^[^[:blank:]].*\s##\s' $(MAKEFILE_LIST) | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-25s\033[0m %s\n", $$1, $$2}'

.DEFAULT_GOAL := help


#============= Init ===============#
init-dev: ## Init dev environments
	cp .env.dev .env

init-prod: ## Init prod environments
	cp .env.prod .env

#============= Start ===============#
up: ## Start all services | up one service: make up php
	docker compose $(DOCKER_ENV_FILES) up -d --build $(ARGS)

build: ## Build all services | build one service: make build php
	docker compose $(DOCKER_ENV_FILES) build --no-cache $(ARGS)

restart: ## Restart all services | restart one service: make restart php
	docker compose restart $(ARGS)

hard-restart: ## Hard restart ALL services (make down && make up)
	make down && make up

stop: ## Stop all services | stop one service: make stop php
	docker compose $(DOCKER_ENV_FILES) stop $(ARGS)

connect: ## Connect to service. Example: make connect php
	docker compose exec $(ARGS) bash

connect-root: ## Connect to service as root. Example: make connect-root php
	docker compose exec -u 0 $(ARGS) bash

logs: ## Logs all services | one service: make logs php
	docker compose logs -f --tail=20 $(ARGS)

down: ## Delete all services | one service: make down php
	docker compose down $(ARGS)

down-cont-vol: ## Delete all containers and volumes | one service: make down-cont-vol php
	docker compose down -v $(ARGS)

down-cont-img: ## Delete all containers and images | one service: make down-cont-img php
	docker compose down --rmi all $(ARGS)

down-all: ## WARNING! Delete ALL! containers / networks / images / volumes | one service: make down-all php
	docker compose down -v --rmi all $(ARGS)

ps: ## Show containers.
	docker compose $(DOCKER_ENV_FILES) ps

config: ## Show containers.
	docker compose $(DOCKER_ENV_FILES) config


#============= Laravel ===============#
laravel-install: ## Install Laravel
	docker compose exec php composer create-project laravel/laravel example-app \
	&& mv -f $(APP_PATH)/example-app/* $(APP_PATH)/ && mv -f $(APP_PATH)/example-app/.* $(APP_PATH)/ && rm -rf $(APP_PATH)/example-app

composer-install: ## composer install
	docker compose exec -u 0 php composer install --no-cache --ansi --no-interaction

tinker: ## php artisan tinker
	docker compose exec php php artisan tinker

migrate: ## php artisan migrate
	docker compose exec php php artisan migrate

php-artisan: ## php artisan commands. example: make php-artisan tinker | php artisan migrate | and others php artisan commands..
	docker compose exec php php artisan $(ARGS)

#============= NPM ===============#
npm: ## Examples: make npm install | make npm run build | make npm run dev | and others npm commands..
	docker compose exec node npm $(ARGS)

#============= Database ===============#
db-import: ## Import database from file: make db-import filepath=../db.sql
	sudo docker exec -i $(COMPOSE_PROJECT_NAME)-mysql-1 mysql -u $(DB_USERNAME) -p$(DB_PASSWORD) $(DB_DATABASE) < $(filepath)


#============= Portainer ===============#
portainer-install: ## Install portainer
	docker run -d -p 9000:9000 --name portainer --restart always -v /var/run/docker.sock:/var/run/docker.sock portainer/portainer-ce



