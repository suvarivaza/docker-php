
# ===================
## ====== Tests =====
# ===================

.PHONY: check-redis
check-redis:
	$(call require-vars,COMPOSE_FILE COMPOSE_PROFILES COMPOSE_PROJECT_NAME)
	docker compose exec -T php php -r '\
		$$socket = @fsockopen("redis", 6379, $$errorCode, $$errorMessage, 5); \
		if (!$$socket) { fwrite(STDERR, "Redis недоступен: $$errorMessage ($$errorCode)\n"); exit(1); } \
		fclose($$socket); echo "Redis доступен\n";'

#--progress=plain → показывает stdout
.PHONY: test-build
test-build:
	$(call require-vars,COMPOSE_FILE COMPOSE_PROFILES COMPOSE_PROJECT_NAME)
	docker compose build --no-cache --progress=plain $(ARGS)

# создает временный контейнер и удаляет после выхода
# $(ARGS) = <image_name>
.PHONY: tmp-container
tmp-container:
	docker run --rm -it --entrypoint sh $(ARGS)

.PHONY: get-docker-ip
get-docker-ip:
	$(call require-vars,COMPOSE_PROJECT_NAME)
	docker inspect -f '{{range.NetworkSettings.Networks}}{{.IPAddress}}{{end}}' $(COMPOSE_PROJECT_NAME)-php
