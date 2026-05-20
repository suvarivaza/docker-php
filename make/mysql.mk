# --------------------
## ====== Build ======
# -------------------

.PHONY: download-db
download-db: ## download db dump by ssh: make download-db SSH=root@123.456.78.90 SSH_DB_USER=dbuser SSH_DB_NAME=dbname
	ssh $(SSH) "mysqldump -u $(SSH_DB_USER) -p $(SSH_DB_NAME) | gzip" > db.sql.gz && \
	gunzip db.sql.gz

.PHONY: download-db-dev
download-db-dev: ## make download-db-dev SSH=root@123.456.78.90 SSH_DB_USER=dbuser SSH_DB_NAME=dbname
	ssh $(SSH) "mysqldump -u $(SSH_DB_USER) -p $(SSH_DB_NAME) --where='true limit 10000' | gzip" > db.sql.gz && \
	gunzip db.sql.gz

.PHONY: db-import
db-import: ## Import database from file: make db-import
#	rm -r mysql/data/$(DB_USERNAME)/*
	sudo docker exec -it $(COMPOSE_PROJECT_NAME)-mysql mysql -u $(DB_USERNAME) -p$(DB_PASSWORD) -e "\
    DROP DATABASE $(DB_DATABASE); \
    CREATE DATABASE $(DB_DATABASE) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;" && \
	sudo docker exec -i $(COMPOSE_PROJECT_NAME)-mysql mysql -u $(DB_USERNAME) -p$(DB_PASSWORD) $(DB_DATABASE) < db.sql

#.PHONY: db_import
#db_import: ##
#	docker compose exec mysql mysql -u$(DB_USERNAME) -p$(DB_PASSWORD) $(DB_DATABASE) < db.sql

.PHONY: db-dump
db-dump: ## dump db
	docker compose exec -T mysql mysqldump --no-tablespaces -u$(DB_USERNAME) -p$(DB_PASSWORD) $(DB_DATABASE) > db.sql



