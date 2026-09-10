# ----------------------
# Args
# ----------------------

COMMAND := $(firstword $(MAKECMDGOALS))
ARGS := $(wordlist 2,$(words $(MAKECMDGOALS)),$(MAKECMDGOALS))

# maximum 4 arguments after command: make up db redis backend
ifneq ($(filter 5,$(words $(ARGS))),)
  $(error Too many args)
endif

# ----------------------
# Includes
# ----------------------

# Check only variables required by the command being executed.
# Values are inspected by Make without interpolating secrets into shell commands.
define require-vars
$(foreach name,$(1),$(if $(strip $($(name))),,$(error Set $(name) in .env or pass it to make)))
endef

-include .env
-include make/*.mk

export


# ----------------------
# Help
# ----------------------

.PHONY: help
help:
	@echo ""
	@echo "======= Help ======="
	@echo "Usage: make <command> [args]"
	@echo ""
	@grep -h -E '(^##)|(^[a-zA-Z_-]+:.*?## )' $(MAKEFILE_LIST) | \
	awk 'BEGIN {FS = ":.*?## "}; \
	/^##/ {printf "\n\033[33m%s\033[0m\n", substr($$0,4); next}; \
	{printf "  \033[36m%-25s\033[0m %s\n", $$1, $$2}'

.DEFAULT_GOAL := help



# important! ignore any unknown target! must be at the end of the root Makefile!
%:
	@:

# ----------------------------------------------------------------------------------------
