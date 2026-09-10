# ===================
## ===== Init =====
# ===================

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
	$(call require-vars,TRAEFIK_DOMAIN_EMAIL)
	@sed -i '' 's|email: .*|email: "$(TRAEFIK_DOMAIN_EMAIL)"|' ./traefik/config/traefik-prod.yml
	@echo "✅ Email Traefik updated $(TRAEFIK_DOMAIN_EMAIL)"


.PHONY: set-dev-local-hosts
set-dev-local-hosts: ## Setup dev local hosts (use this command only for dev!)
	$(call require-vars,APP_URL)
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