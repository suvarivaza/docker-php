# ==============================
# ==== SSL COMMANDS ====
# ==============================

# выполнить при первом запуске nginx! иначе nginx не запустится так как нет сертификатов
#ssl-generate-openssl: ## выполнить при первом запуске nginx! иначе nginx не запустится так как нет сертификатов
#	sudo mkdir -p $(PWD)/letsencrypt/live/${SITE_DOMAIN} && \
#	sudo openssl req -x509 -nodes -days 1 \
#	-newkey rsa:2048 \
#	-keyout $(PWD)/letsencrypt/live/${SITE_DOMAIN}/privkey.pem \
#	-out $(PWD)/letsencrypt/live/${SITE_DOMAIN}/fullchain.pem \
#	-subj "/CN=${SITE_DOMAIN}"


#ssl-certbot:
#	docker run --rm \
#		-v $(PWD)/letsencrypt:/etc/letsencrypt \
#		-v $(PWD)/certbot/www:/var/www/certbot \
#		certbot/certbot certonly --webroot \
#		-w /var/www/certbot \
#		-d $(SITE_DOMAIN) -d www.$(SITE_DOMAIN) \
#		--email 42-36-42@mail.ru \
#		--agree-tos --non-interactive


#ssl-renew-certbot:
#	docker compose run --rm certbot && docker compose restart nginx


## ======= Setup DEV SSL =======

.PHONY: dev-setup-local-ssl
dev-setup-local-ssl: ## Setup local ssl cert for dev
	@if [ ! -d ./traefik/certs ]; then \
		echo "Creating ./traefik/certs directory..."; \
		mkdir -p ./traefik/certs; \
	else \
		echo "./traefik/certs already exists, skipping creation."; \
	fi && \
	make create-local-ssl-cert-mkcert
	make add-traefik-local-cert-in-config


.PHONY: create-local-ssl-cert-mkcert
create-local-ssl-cert-mkcert: ## Generate SSL cert for local domains with mkcert (recommend!)
	echo "Creating SSL certs with mkcert";
	brew install mkcert
	mkcert -install && \
	mkcert \
      -key-file ./traefik/certs/$(APP_URL).key \
      -cert-file ./traefik/certs/$(APP_URL).crt \
      $(APP_URL) traefik.$(APP_URL) pma.$(APP_URL)

.PHONY: create-local-ssl-cert-openssl
create-local-ssl-cert-openssl:
	echo "Creating SSL certs with openssl";
	openssl req -x509 -nodes -newkey rsa:2048 \
      -keyout "./traefik/certs/$(APP_URL).key" \
      -out "./traefik/certs/$(APP_URL).crt" \
      -days 365 \
      -subj "/CN=$(APP_URL)"

# Spaces are important!
.PHONY: add-traefik-local-cert-in-config
add-traefik-local-cert-in-config:
	rm ./traefik/config/dev-tls.yml
	echo "Adding SSL certs to ./traefik/config/dev-tls.yml"; \
	echo "tls:\n  certificates:\n    - certFile: \"/certs/$(APP_URL).crt\"\n      keyFile: \"/certs/$(APP_URL).key\"" > ./traefik/config/dev-tls.yml

