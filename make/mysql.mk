# --------------------
## ====== Build ======
# -------------------

.PHONY: download-db
download-db: ## download db dump by ssh: make download-db SSH=root@123.456.78.90 SSH_DB_USER=dbuser SSH_DB_NAME=dbname
	$(call require-vars,SSH SSH_DB_USER SSH_DB_NAME)
	ssh $(SSH) "mysqldump -u $(SSH_DB_USER) -p $(SSH_DB_NAME) | gzip" > db.sql.gz && \
	gunzip db.sql.gz

.PHONY: download-db-dev
download-db-dev: ## make download-db-dev SSH=root@123.456.78.90 SSH_DB_USER=dbuser SSH_DB_NAME=dbname
	$(call require-vars,SSH SSH_DB_USER SSH_DB_NAME)
	ssh $(SSH) "mysqldump -u $(SSH_DB_USER) -p $(SSH_DB_NAME) --where='true limit 10000' | gzip" > db.sql.gz && \
	gunzip db.sql.gz

# Path to a plain SQL dump, relative to the current directory.
DB_FILE ?= db.sql

.PHONY: db-import
db-import: ## Replace database from SQL dump: make db-import DB_FILE=path/db.sql
	$(call require-vars,COMPOSE_FILE COMPOSE_PROFILES COMPOSE_PROJECT_NAME DB_USERNAME DB_PASSWORD DB_DATABASE DB_FILE)
	@set -eu; \
	if [ ! -f "$$DB_FILE" ] || [ ! -r "$$DB_FILE" ] || [ ! -s "$$DB_FILE" ]; then \
		printf 'Error: dump must be a readable, non-empty file: %s\n' "$$DB_FILE" >&2; exit 1; \
	fi; \
	case "$$DB_DATABASE" in \
		mysql|sys|information_schema|performance_schema|*[!a-zA-Z0-9_-]*) \
			printf 'Error: unsupported or system database name: %s\n' "$$DB_DATABASE" >&2; exit 1 ;; \
	esac; \
	exec 3< "$$DB_FILE"; \
	printf 'Replace database "%s" in project "%s" using "%s"? All current data will be deleted. Type yes: ' "$$DB_DATABASE" "$$COMPOSE_PROJECT_NAME" "$$DB_FILE"; \
	if ! IFS= read -r confirm || [ "$$confirm" != yes ]; then \
		printf 'Cancelled.\n'; exit 1; \
	fi; \
	docker compose exec -T -e MYSQL_PWD="$$DB_PASSWORD" mysql mysql -u "$$DB_USERNAME" -e 'SELECT 1' >/dev/null; \
	sql=$$(printf 'DROP DATABASE IF EXISTS `%s`; CREATE DATABASE `%s` CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;' "$$DB_DATABASE" "$$DB_DATABASE"); \
	docker compose exec -T -e MYSQL_PWD="$$DB_PASSWORD" mysql mysql -u "$$DB_USERNAME" -e "$$sql"; \
	if ! docker compose exec -T -e MYSQL_PWD="$$DB_PASSWORD" mysql mysql -u "$$DB_USERNAME" "$$DB_DATABASE" <&3; then \
		printf 'Import failed: database may contain partial data. Restore from a known-good dump.\n' >&2; exit 1; \
	fi; \
	printf 'Database imported successfully.\n'

.PHONY: db-dump
db-dump: ## dump db
	$(call require-vars,COMPOSE_FILE COMPOSE_PROFILES COMPOSE_PROJECT_NAME DB_USERNAME DB_PASSWORD DB_DATABASE)
	docker compose exec -T mysql mysqldump --no-tablespaces -u$(DB_USERNAME) -p$(DB_PASSWORD) $(DB_DATABASE) > db.sql



