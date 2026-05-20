# ==================
## ===== Files =====
# ==================

# -------- Download files to local ------

.PHONY: download-files
download-files: ## download files from remote server
	ssh $(SSH)  "cd $(APP_PATH) && tar --exclude='.env' -vczf - ./" | tar  xzf -


