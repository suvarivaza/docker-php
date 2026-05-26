
# ===================
## ====== Tests =====
# ===================

check-redis:
	docker compose exec backend sh -c "nc -zv redis 6379"

#--progress=plain → показывает stdout
test-build:
	docker compose build --no-cache --progress=plain $(ARGS)

# создает временный контейнер и удаляет после выхода
# $(ARGS) = <image_name>
tmp-container:
	docker run --rm -it --entrypoint sh $(ARGS)

.PHONY: get-docker-ip
get-docker-ip:
	docker inspect -f '{{range.NetworkSettings.Networks}}{{.IPAddress}}{{end}}' $(COMPOSE_PROJECT_NAME)-php