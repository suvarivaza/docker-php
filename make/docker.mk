# ===================
## ===== DOCKER =====
# ===================

.PHONY: up
up: ## Start services: docker compose up -d $(ARGS)
	docker compose up -d $(ARGS)

.PHONY: stop
stop: ## Stop services: docker compose stop $(ARGS)
	docker compose stop $(ARGS)

.PHONY: restart
restart: ## Restart services: docker compose restart $(ARGS)
	docker compose restart $(ARGS)

# --------------------
## Reset
# -------------------

.PHONY: reset
reset: ## Clear reset ALL services (containers + network): docker compose down && docker compose up -d
	docker compose down
	docker compose up -d

.PHONY: clear-reset
clear-reset: ## Clear reset with build --no-cache:  docker compose down && docker compose build --no-cache && docker compose up -d
	docker compose down
	docker compose build --no-cache
	docker compose up -d


# --------------------
## Build
# -------------------

.PHONY: build
build: ## Build services: docker compose build $(ARGS)
	docker compose build $(ARGS)

.PHONY: clear-build
clear-build: ## Build services --no-cache: docker compose build --no-cache $(ARGS)
	docker compose build --no-cache $(ARGS)

.PHONY: rebuild
rebuild: ## Build with cache and start (use if files changed): docker compose up -d --build $(ARGS)
	docker compose up -d --build $(ARGS)

.PHONY: clear-rebuild
clear-rebuild: ##
	docker compose build --no-cache $(ARGS)
	docker compose up -d $(ARGS)

.PHONY: recreate
recreate:  ## recreate containers with no build (use if .env file changed): docker compose up -d --force-recreate $(ARGS)
	docker compose up -d --force-recreate $(ARGS)

.PHONY: build-debug
build-debug: ## rebuild with debug mode: docker compose build --no-cache $(ARGS) --progress=plain
	docker compose build --no-cache $(ARGS) --progress=plain


# --------------------
## Remove / Cleanup
# -------------------

.PHONY: down
down: ## Stop and remove containers + networks: docker compose down
	docker compose down

.PHONY: down-images
down-images: ## Remove containers + networks + images: docker compose down --rmi all
	docker compose down --rmi all

.PHONY: down-volumes
down-volumes: ## Remove containers + networks + volumes (DANGER): docker compose down -v
	@read -p "⚠️  This will DELETE containers + networks + volumes!!! Continue? (yes/no): " confirm && \
	if [ "$$confirm" = "yes" ]; then \
		docker compose down -v; \
	else \
		echo "Cancelled"; \
	fi

.PHONY: rm
rm: ## strict remove (fails if running): docker compose rm $(ARGS)
	docker compose rm $(ARGS)

.PHONY: rm-force
rm-force: ## stop + remove: docker compose rm -s $(ARGS)
	docker compose rm -s $(ARGS)

.PHONY: rm-volumes
rm-volumes: ## Remove containers + volumes (DANGER): docker compose rm -v $(ARGS)
	@read -p "⚠️  This will DELETE containers + volumes!!! Continue? (yes/no): " confirm && \
	if [ "$$confirm" = "yes" ]; then \
		docker compose rm -v $(ARGS); \
	else \
		echo "Cancelled"; \
	fi


# --------------------
## Connect
# -------------------

.PHONY: shell
shell: ## Connect to service: docker compose exec $(ARGS) sh
	docker compose exec $(ARGS) sh

.PHONY: shell-root
shell-root: ## Connect to service as root: docker compose exec -u 0 $(ARGS) sh
	docker compose exec -u 0 $(ARGS) sh

.PHONY: connect
connect: shell

.PHONY: sh
connect: shell

# --------------------
## Docker System
# -------------------

.PHONY: logs
logs: ## Logs: docker compose logs -f --tail=100 $(ARGS)
	docker compose logs -f --tail=100 $(ARGS)

.PHONY: ps
ps: ## Show containers: docker compose ps
	docker compose ps

.PHONY: config
config: ## Compose config: docker compose config
	docker compose config

.PHONY: stats
stats: ## Show detail docker stats like command top/htop: docker stats
	docker stats


# --------------------
## Docker clear
# -------------------

.PHONY: docker-size
docker-size: ## Show Docker size: docker system df -v
	docker system df -v

.PHONY: docker-dir-size
docker-dir-size:
	sudo sh -c 'du -sh /var/lib/docker/*' | sort -h

.PHONY: docker-overlay2-size
docker-overlay2-size:
	sudo sh -c 'du -sh /var/lib/docker/overlay2/*' | sort -h

.PHONY: docker-overlay-count
docker-overlay-count:
	sudo sh -c 'ls /var/lib/docker/overlay2/*' | wc -l

.PHONY: find-big-logfiles
find-big-logfiles: ## Find big docker log files
	sudo find /var/lib/docker/containers -type f -name "*-json.log" -printf '%s %p\n' | sort -n | tail -n 10

.PHONY: docker-clear
docker-clear: ## Waring! Remove unused containers/networks (safe): docker system prune
	docker system prune

.PHONY: docker-hard-clear
docker-hard-clear: # Remove ALL! (DANGER!): docker system prune -a --volumes
	@read -p "⚠️  This will DELETE ALL Docker data with volumes!!! Continue? (yes/no): " confirm && \
	if [ "$$confirm" = "yes" ]; then \
		docker system prune -a --volumes; \
	else \
		echo "Cancelled"; \
	fi

# Docker danger commands #######

# Жесткая перезагрузка docker и проекта (чистый запуск)
# Если нужно удалить все лишнее. Осеротевшие слои, кэш и тд.
# Жестко - но зато чисто! Проверено - работает отлично!
.PHONY: clear-start-delete-docker
clear-start-delete-docker: # DANGER! Delete ALL docker!!!
	@read -p "⚠️  Вы точно уверены? Это УДАЛИТ docker с сервера целиком!!! $(DB_NAME)! (yes/no): " confirm && \
	if [ "$$confirm" = "yes" ]; then \
		systemctl stop docker && \
		rm -rf /var/lib/docker && \
		systemctl start docker && \
		$(MAKE) up; \
	else \
		echo "Отменено"; \
	fi


# остановить все запущенные контейнеры
.PHONY: docker-stop-all-containers
docker-stop-all-containers:
	docker stop $(docker ps -q)

# удалить все незапущенные контейнеры
.PHONY: docker-rm-all-containers
docker-rm-all-containers:
	docker rm $(docker ps -a -q)

# удалить все образы
.PHONY: docker-rm-all-images
docker-rm-all-images:
	docker rmi $(docker images -q)

.PHONY: docker-delete-all-volumes
docker-delete-all-volumes:
	docker volume prune -f


# --------------------
## Portainer
# -------------------

.PHONY: portainer-install
portainer-install: ## Install portainer
	docker run -d -p 9000:9000 --name portainer --restart always -v /var/run/docker.sock:/var/run/docker.sock portainer/portainer-ce
