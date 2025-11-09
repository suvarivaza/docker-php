# include default env file
ifneq ("$(wildcard .env)","")
    include .env
endif

# Get arguments from command line. For example ARGS=value for command line: make command value
# https://stackoverflow.com/questions/6273608/how-to-pass-argument-to-makefile-from-command-line
ARGS=$(filter-out $@,$(MAKECMDGOALS))
COUNT_ARGS := $(shell echo $(ARGS) | wc -w)

# Error if arguments more then 3
ifeq ($(shell expr $(COUNT_ARGS) \> 3), 1)
 $(error Maximum 3 arguments are allowed for make command! Example 2 arg: make up php | Example 3 arg: make npm run dev)
endif


#============= Init ===============#

.PHONY: init-dev
init-dev: ## Init dev environments and hosts
	@if [ ! -f .env ]; then \
		echo "Creating .env from example..."; \
		cp .env.dev.example .env && \
		make set-userid-groupid && \
		make set-dev-local-hosts; \
	else \
		echo ".env already exists, skipping init."; \
	fi

.PHONY: init-prod
init-prod: ## Init prod environments
	@if [ ! -f .env ]; then \
		echo "Creating .env from example..."; \
		cp .env.prod.example .env && \
		make set-userid-groupid && \
		make set-traefik-prod-email; \
	else \
		echo ".env already exists, skipping init."; \
	fi

.PHONY: set-userid-groupid
set-userid-groupid:
	echo "" >> .env && \
    echo "# Host user id and group id (for correct permissions inside docker)" >> .env && \
    echo "USER_ID=$(shell id -u)" >> .env && \
    echo "GROUP_ID=$(shell id -g)" >> .env

.PHONY: set-traefik-prod-email
set-traefik-prod-email:
	@sed -i '' 's|email: .*|email: "$(TRAEFIK_DOMAIN_EMAIL)"|' ./traefik/config/traefik-prod.yml
	@echo "✅ Email Traefik updated $(TRAEFIK_DOMAIN_EMAIL)"



#============= Main comands ===============#

.PHONY: start up
up: ## Start services
	docker compose up -d --build $(ARGS)
start: ## Start services
	docker compose up -d --build $(ARGS)

.PHONY: stop
stop: ## Stop services
	docker compose stop $(ARGS)

.PHONY: connect
connect: ## Connect service. Example: make connect php
	docker compose exec $(ARGS) sh

.PHONY: connect-root
connect-root: ## Connect to service as root. Example: make connect-root php
	docker compose exec -u 0 $(ARGS) sh

.PHONY: logs
logs: ## Logs services
	docker compose logs -f --tail=20 $(ARGS)


#============= Restart ===============#

.PHONY: restart
restart: ## Restart services
	docker compose restart $(ARGS)

.PHONY: hard-restart
hard-restart: ## Clear restart ALL services (docker compose down && docker compose up -d)
	docker compose down && docker compose up -d


#============= Build ===============#

.PHONY: recreate
recreate:  ## recreate containers with no build (if .env changed)
	docker compose up -d --force-recreate $(ARGS)

.PHONY: build
build: ## Build services
	docker compose build $(ARGS)

.PHONY: rebuild
rebuild: ## Build services
	docker compose build --no-cache $(ARGS)



#============= Delete ===============#

.PHONY: delete
delete: ## Delete container mysql: make delete mysql
	docker compose rm -s $(ARGS)

.PHONY: delete-all
delete-all: ## Delete all mysql: container + Volumes: make delete-all mysql
	docker compose rm -s -v $(ARGS)

.PHONY: down
down: ## Delete all containers
	docker compose down

.PHONY: downv
downv: ## Delete all containers + volumes
	docker compose down -v

.PHONY: downi
downi: ## Delete all containers + images
	docker compose down --rmi all

.PHONY: down-all
down-all: ## WARNING! Delete ALL! containers + networks + images + volumes
	docker compose down -v --rmi all




#============= Docker service commands ===============#

.PHONY: ps
ps: ## Show containers.
	docker compose ps

.PHONY: config
config: ## compose config
	docker compose config

.PHONY: show-image-layers
show-image-layers: ##
	docker compose build --no-cache $(ARGS) --progress=plain


# -------- Docker clear system ------

.PHONY: docker_size
docker_size: ## Docker size
	docker system df -v

.PHONY: find_big_logfiles
find_big_logfiles: ## Find big docker log files
	sudo find /var/lib/docker/containers -type f -name "*-json.log" -printf '%s %p\n' | sort -n | tail -n 10

.PHONY: docker_clear
docker_clear: ## Waring! Delete all not used containers and images!
	docker system prune

.PHONY: docker_hard_clear
docker_hard_clear: ## Внимание!!! Удалит ВСЕ вместе с данными! тома volumes!!! / остановленные контейнеры / образы, на которые не ссылается ни один контейнер / которые не используются ни одним контейнером
	docker system prune -a --volumes -f



#============= Laravel ===============#

.PHONY: laravel-install
laravel-install: ## Install Laravel
	docker compose exec php composer create-project laravel/laravel example-app \
	&& mv -f $(APP_PATH)/example-app/* $(APP_PATH)/ && mv -f $(APP_PATH)/example-app/.* $(APP_PATH)/ && rm -rf $(APP_PATH)/example-app

.PHONY: composer-install
composer-install: ## install composer packages
	docker compose exec -u 0 php composer install --no-cache --ansi --no-interaction

.PHONY: tinker
tinker: ## make tinker = php artisan tinker
	docker compose exec php php artisan tinker

.PHONY: migrate
migrate: ## make migrate = php artisan migrate
	docker compose exec php php artisan migrate

.PHONY: php-artisan
php-artisan: ## example: make php-artisan tinker | php artisan migrate | and others php artisan commands..
	docker compose exec php php artisan $(ARGS)


#============= PHP ===============#

.PHONY: show-installed-php-modules
show-installed-php-modules:
	docker compose exec php php -m


#============= NPM ===============#

.PHONY: npm
npm: ## Examples: make npm install | make npm run build | make npm run dev | and others npm commands..
	docker compose exec node npm $(ARGS)



#============= Database ===============#

.PHONY: download-db
download-db: ## download db dump by ssh: make download-db SSH=root@123.456.78.90 SSH_DB_USER=dbuser SSH_DB_NAME=dbname
	ssh $(SSH) "mysqldump -u $(SSH_DB_USER) -p $(SSH_DB_NAME) | gzip" > db.sql.gz && \
	gunzip db.sql.gz

.PHONY: download-db-dev
download-db-dev: ## make download-db-dev SSH=root@123.456.78.90 SSH_DB_USER=dbuser SSH_DB_NAME=dbname
	ssh $(SSH) "mysqldump -u $(SSH_DB_USER) -p $(SSH_DB_NAME) --where='true limit 2000' | gzip" > db.sql.gz && \
	gunzip db.sql.gz

.PHONY: db-import
db-import: ## Import database from file: make db-import DB_FILE=db.sql
	sudo docker exec -i $(COMPOSE_PROJECT_NAME)-mysql mysql -u $(DB_USERNAME) -p$(DB_PASSWORD) $(DB_DATABASE) < $(DB_FILE)

#.PHONY: db_import
#db_import: ##
#	docker compose exec mysql mysql -u$(DB_USERNAME) -p$(DB_PASSWORD) $(DB_DATABASE) < db.sql

.PHONY: db_dump
db_dump: ## dump db
	docker compose exec -T mysql mysqldump --no-tablespaces -u$(DB_USERNAME) -p$(DB_PASSWORD) $(DB_DATABASE) > db.sql



#============= Setup DEV Hosts  ===============#

.PHONY: set-dev-local-hosts
set-dev-local-hosts: ## Setup dev local hosts (use this command only for dev!)
	echo "==== Setup dev local hosts ===="
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


#============= Setup DEV SSL ===============#

.PHONY: dev-setup-ssl
dev-setup-ssl: ## Setup local ssl cert for dev
	@if [ ! -d ./traefik/certs ]; then \
		echo "Creating ./traefik/certs directory..."; \
		mkdir -p ./traefik/certs; \
	else \
		echo "./traefik/certs already exists, skipping creation."; \
	fi && \
	make create-local-ssl-cert-mkcert && \
	make add-traefik-local-cert-in-config


.PHONY: create-local-ssl-cert-mkcert
create-local-ssl-cert-mkcert: ## Generate SSL cert for local domains with mkcert (recommend!)
	echo "Creating SSL certs with mkcert"; \
	brew install mkcert && \
	mkcert -install && \
	mkcert \
      -key-file ./traefik/certs/$(APP_URL).key \
      -cert-file ./traefik/certs/$(APP_URL).crt \
      $(APP_URL) traefik.$(APP_URL) pma.$(APP_URL)

.PHONY: create-local-ssl-cert
create-local-ssl-cert:
	echo "Creating SSL certs with openssl"; \
	openssl req -x509 -nodes -newkey rsa:2048 \
      -keyout "./traefik/certs/$(APP_URL).key" \
      -out "./traefik/certs/$(APP_URL).crt" \
      -days 365 \
      -subj "/CN=$(APP_URL)"

# Spaces are important!
.PHONY: add-traefik-local-cert-in-config
add-traefik-local-cert-in-config:
	echo "Adding SSL certs to ./traefik/config/dev-tls.yml"; \
	@echo "tls:\n  certificates:\n    - certFile: \"/certs/$(APP_URL).crt\"\n      keyFile: \"/certs/$(APP_URL).key\"" > ./traefik/config/dev-tls.yml




# -------- Phpmyadmyn ------

.PHONY: open_ssh_tonel_phpmyadmin
open_ssh_tonel_phpmyadmin: ## phpmyadmin tonel from prod to http://localhost:8080/
	ssh -L 8080:127.0.0.1:8080 $(SSH)


# -------- Download files to local ------

.PHONY: download-files
download-files: ## download files from remote server
	ssh $(SSH)  "cd $(APP_PATH) && tar --exclude='.env' -vczf - ./" | tar  xzf -


#============= Portainer ===============#

.PHONY: portainer-install
portainer-install: ## Install portainer
	docker run -d -p 9000:9000 --name portainer --restart always -v /var/run/docker.sock:/var/run/docker.sock portainer/portainer-ce




.PHONY: help
help:
	@echo ======= Help =======
	@echo 'You can pass the third parameter to the make command like this: make up php'
	@egrep -h '^[^[:blank:]].*\s##\s' $(MAKEFILE_LIST) | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-25s\033[0m %s\n", $$1, $$2}'

.DEFAULT_GOAL := help
