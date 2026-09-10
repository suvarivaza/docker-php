# ==================
## ===== Files =====
# ==================

# -------- Download files to local ------

.PHONY: download-files
download-files: ## download files from remote server
	$(call require-vars,SSH APP_DIR)
	ssh $(SSH)  "cd ../$(APP_DIR) && tar --exclude='.env' -vczf - ./" | tar  xzf -


