# ==================
## ===== Files =====
# ==================

# -------- Download files to local ------

.PHONY: download-files
download-files: ## download files from remote server
	$(call require-vars,SSH APP_PATH SSH_APP_PATH)
	@bash bash/download-files.sh
