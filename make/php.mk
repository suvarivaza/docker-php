# ===================
## ===== PHP =====
# ===================

.PHONY: show-installed-php-modules
show-installed-php-modules: ## show-installed-php-modules
	docker compose exec php php -m


# -------- Phpmyadmyn ------

.PHONY: open_ssh_tonel_phpmyadmin
open_ssh_tonel_phpmyadmin: ## phpmyadmin tonel from prod to http://localhost:8080/
	ssh -L 8080:127.0.0.1:8080 $(SSH)