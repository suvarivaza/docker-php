# ====================
## ===== Laravel =====
# ====================

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


## ===== NPM =====

.PHONY: npm
npm: ## Examples: make npm install | make npm run build | make npm run dev | and others npm commands..
	docker compose exec node npm $(ARGS)