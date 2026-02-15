.PHONY: help build up down status logs provision init auth-sync validate

SHELL := /bin/bash
ROOT_DIR := $(shell dirname $(realpath $(firstword $(MAKEFILE_LIST))))

help:
	@echo "OpenClaw - Make Commands"
	@echo "======================="
	@echo "make build         Build Docker image"
	@echo "make up            Start container"
	@echo "make down          Stop container"
	@echo "make status        Show container status"
	@echo "make logs          Follow container logs"
	@echo "make init          Initialize config (first time)"
	@echo "make provision     Provision and restart"
	@echo "make auth-sync     Sync Clippy + Whoop auth"
	@echo "make validate      Validate environment"
	@echo ""
	@echo "Azure VM:"
	@echo "make deploy        Full deploy on Azure VM"

build:
	docker compose build

up:
	docker compose up -d

down:
	docker compose down

status:
	docker ps --filter name=openclaw

logs:
	docker logs -f openclaw

init:
	@echo "Initializing config..."
	@if [ ! -f .env ]; then \
		echo "ERROR: .env file not found. Copy .env_example to .env and configure it."; \
		exit 1; \
	fi
	@if [ ! -f data/.openclaw/openclaw.json ]; then \
		mkdir -p data/.openclaw data/workspace data/clippy data/whoop; \
		cp config/openclaw.json.example data/.openclaw/openclaw.json; \
		chmod 600 data/.openclaw/openclaw.json; \
		echo "Config initialized."; \
	else \
		echo "Config already exists."; \
	fi

provision: init
	@echo "Provisioning..."
	@./scripts/provision.sh

auth-sync:
	@echo "Syncing auth..."
	@./scripts/sync-auth.sh

validate:
	@echo "Validating..."
	@./scripts/check/validate-prereqs.sh
	@./scripts/check/validate-env.sh
	@echo "Validation passed."
