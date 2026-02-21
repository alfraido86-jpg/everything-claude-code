.DEFAULT_GOAL := help
SHELL         := /usr/bin/env bash
.SHELLFLAGS   := -euo pipefail -c

# --------------------------------------------------------------------------- #
# Directories
# --------------------------------------------------------------------------- #
DIST_DIR  := dist
LOGS_DIR  := logs
LOG_FILE  := $(LOGS_DIR)/run-$(shell date +%Y%m%d-%H%M%S).log

# --------------------------------------------------------------------------- #
# Targets
# --------------------------------------------------------------------------- #

.PHONY: help setup validate build package update logs clean

## help: Show this help message
help:
	@grep -E '^## ' $(MAKEFILE_LIST) | sed 's/## //' | column -t -s ':'

## setup: Idempotent full environment setup (install deps, configure .env, build Docker)
setup:
	@echo "==> Installing Node dependencies..."
	@npm ci --prefer-offline 2>/dev/null || npm install
	@if [ ! -f .env ] && [ -f .env.example ]; then \
		cp .env.example .env; \
		echo "==> Copied .env.example → .env (fill in your secrets)"; \
	fi
	@if command -v docker >/dev/null 2>&1 && [ -f docker-compose.yml ]; then \
		echo "==> Building Docker images..."; \
		docker compose build --quiet; \
	fi
	@echo "==> Setup complete."

## validate: Run the full smoke-test suite and write a timestamped log
validate:
	@mkdir -p $(LOGS_DIR)
	@echo "==> Running validation (log: $(LOG_FILE))..."
	@node tests/run-all.js 2>&1 | tee $(LOG_FILE)
	@echo "==> Validation complete. Log saved to $(LOG_FILE)"

## build: Build artifacts (Node bundle / Docker image) into dist/
build:
	@mkdir -p $(DIST_DIR)
	@echo "==> Building artifacts..."
	@GIT_SHA=$$(git rev-parse --short HEAD 2>/dev/null || echo "unknown"); \
	BUNDLE=$(DIST_DIR)/everything-claude-code-$$GIT_SHA; \
	echo "  Artifact prefix: $$BUNDLE"; \
	if command -v docker >/dev/null 2>&1 && [ -f docker-compose.yml ]; then \
		docker compose build; \
	fi
	@echo "==> Build complete."

## package: Zip dist/ output into a release bundle named with the current git SHA
package: build
	@mkdir -p $(DIST_DIR)
	@GIT_SHA=$$(git rev-parse --short HEAD 2>/dev/null || echo "unknown"); \
	BUNDLE=$(DIST_DIR)/everything-claude-code-$$GIT_SHA.zip; \
	echo "==> Packaging → $$BUNDLE"; \
	zip -r "$$BUNDLE" . \
		--exclude "$(DIST_DIR)/*" \
		--exclude "$(LOGS_DIR)/*" \
		--exclude "node_modules/*" \
		--exclude ".git/*" \
		--exclude ".env" \
		--exclude ".env.*" \
		--exclude "*.key" \
		--exclude "*.pem"; \
	echo "==> Package ready: $$BUNDLE"

## update: Pull latest changes (rebase) and re-run setup
update:
	@echo "==> Pulling latest changes..."
	@git pull --rebase
	@$(MAKE) setup
	@echo "==> Update complete."

## logs: Tail the most recent log file in logs/
logs:
	@LATEST=$$(ls -t $(LOGS_DIR)/*.log 2>/dev/null | head -1); \
	if [ -z "$$LATEST" ]; then \
		echo "No log files found in $(LOGS_DIR)/"; \
	else \
		echo "==> Tailing $$LATEST"; \
		tail -f "$$LATEST"; \
	fi

## clean: Remove dist/, logs/, node_modules/, and venv/
clean:
	@echo "==> Cleaning build artifacts and dependencies..."
	@rm -rf $(DIST_DIR) $(LOGS_DIR) node_modules venv
	@echo "==> Clean complete."
