
#=======================
## ===== Deploy =====
#====================

# почему не:
# git restore . && git pull
# git pull → делает fetch + merge
# В итоге:
# может получиться merge-коммит
# могут быть конфликты
# мусор (новые файлы) останется
# состояние может быть нечистым

# git fetch origin && git reset --hard origin/main; - гарантирует чистое состояние

.PHONY: ssh-agent
ssh-agent:
	eval `ssh-agent -s` && ssh-add ~/.ssh/id_rsa

.PHONY: deploy
deploy: ## hard deploy from remote Git repo. git fetch origin && git reset --hard origin/main
	@read -p "Do you want to deploy code form Git repo? All local changes will be lost!(yes/no): " confirm && \
	if [ "$$confirm" = "yes" ]; then \
		git fetch origin && git reset --hard origin/main; \
	else \
		echo "Cancelled"; \
	fi