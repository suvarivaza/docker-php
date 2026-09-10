# ====================
## ===== Laravel =====
# ====================

.PHONY: laravel-install
laravel-install: ## Install Laravel
	$(call require-vars,COMPOSE_FILE COMPOSE_PROFILES COMPOSE_PROJECT_NAME APP_PATH)
	@set -eu; \
	test -d "$$APP_PATH"; \
	docker compose exec php composer create-project laravel/laravel example-app; \
	for entry in "$$APP_PATH"/example-app/* "$$APP_PATH"/example-app/.[!.]* "$$APP_PATH"/example-app/..?*; do \
		[ -e "$$entry" ] || [ -L "$$entry" ] || continue; \
		name=$${entry##*/}; \
		if [ -e "$$APP_PATH/$$name" ] || [ -L "$$APP_PATH/$$name" ]; then \
			printf 'Destination already exists: %s\n' "$$APP_PATH/$$name" >&2; exit 1; \
		fi; \
	done; \
	for entry in "$$APP_PATH"/example-app/* "$$APP_PATH"/example-app/.[!.]* "$$APP_PATH"/example-app/..?*; do \
		[ -e "$$entry" ] || [ -L "$$entry" ] || continue; \
		mv "$$entry" "$$APP_PATH/"; \
	done; \
	rmdir "$$APP_PATH/example-app"

.PHONY: composer-install
composer-install: ## install composer packages
	$(call require-vars,COMPOSE_FILE COMPOSE_PROFILES COMPOSE_PROJECT_NAME)
	docker compose exec -u 0 php composer install --no-cache --ansi --no-interaction

.PHONY: tinker
tinker: ## make tinker = php artisan tinker
	$(call require-vars,COMPOSE_FILE COMPOSE_PROFILES COMPOSE_PROJECT_NAME)
	docker compose exec php php artisan tinker

.PHONY: migrate
migrate: ## make migrate = php artisan migrate
	$(call require-vars,COMPOSE_FILE COMPOSE_PROFILES COMPOSE_PROJECT_NAME)
	docker compose exec php php artisan migrate

.PHONY: php-artisan
php-artisan: ## example: make php-artisan tinker | php artisan migrate | and others php artisan commands..
	$(call require-vars,COMPOSE_FILE COMPOSE_PROFILES COMPOSE_PROJECT_NAME)
	docker compose exec php php artisan $(ARGS)


## ===== NPM =====

.PHONY: npm
npm: ## Examples: make npm install | make npm run build | make npm run dev | and others npm commands..
	$(call require-vars,COMPOSE_FILE COMPOSE_PROFILES COMPOSE_PROJECT_NAME)
	docker compose exec node npm $(ARGS)