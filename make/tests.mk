
# ===================
## ====== Tests =====
# ===================

check-redis:
	$(call require-vars,COMPOSE_FILE COMPOSE_PROFILES COMPOSE_PROJECT_NAME)
	docker compose exec backend sh -c "nc -zv redis 6379"

#--progress=plain → показывает stdout
test-build:
	$(call require-vars,COMPOSE_FILE COMPOSE_PROFILES COMPOSE_PROJECT_NAME)
	docker compose build --no-cache --progress=plain $(ARGS)

# создает временный контейнер и удаляет после выхода
# $(ARGS) = <image_name>
tmp-container:
	docker run --rm -it --entrypoint sh $(ARGS)

.PHONY: get-docker-ip
get-docker-ip:
	$(call require-vars,COMPOSE_PROJECT_NAME)
	docker inspect -f '{{range.NetworkSettings.Networks}}{{.IPAddress}}{{end}}' $(COMPOSE_PROJECT_NAME)-php