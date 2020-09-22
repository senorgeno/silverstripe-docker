
# see https://tech.davis-hansson.com/p/make/
SHELL := bash
.ONESHELL:
# pipefail makes sure that a series of commands is treated
# as one command, i.e. if one fails, the whole series is marked as failed
.SHELLFLAGS := -u -o pipefail -c
MAKEFLAGS += --warn-undefined-variables
MAKEFLAGS += --no-builtin-rules

DOCKER_COMPOSE_DIR=./.docker
DOCKER_COMPOSE_FILE=$(DOCKER_COMPOSE_DIR)/docker-compose.yml
DEFAULT_CONTAINER=php
DOCKER_COMPOSE=docker-compose -f $(DOCKER_COMPOSE_FILE) --project-directory $(DOCKER_COMPOSE_DIR)
RUN_IN_DOCKER_USER=www-data
RUN_IN_DOCKER_CONTAINER=php

ifndef CONTAINER
	CONTAINER :=
endif

ifndef NO_BUILDKIT
	DOCKER_COMPOSE :=DOCKER_BUILDKIT=1 COMPOSE_DOCKER_CLI_BUILD=1 $(DOCKER_COMPOSE)
endif

# if the file /.dockerenv does not exist we are NOT inside a docker container
# so we must prefix any command to be executed inside the container
RUN_IN_DOCKER :=
ifeq ("$(wildcard /.dockerenv)","")
	RUN_IN_DOCKER := $(DOCKER_COMPOSE) exec -T --user $(RUN_IN_DOCKER_USER) $(RUN_IN_DOCKER_CONTAINER)
endif

ifndef NO_BUILDKIT
endif

DEFAULT_GOAL := help
help:
	@awk 'BEGIN {FS = ":.*##"; printf "\nUsage:\n  make \033[36m<target>\033[0m\n"} /^[a-zA-Z0-9_-]+:.*?##/ { printf "  \033[36m%-27s\033[0m %s\n", $$1, $$2 } /^##@/ { printf "\n\033[1m%s\033[0m\n", substr($$0, 5) } ' $(MAKEFILE_LIST)

##@ [Docker] Build / Infrastructure
.docker/.env:
	cp $(DOCKER_COMPOSE_DIR)/.env.example $(DOCKER_COMPOSE_DIR)/.env

.PHONY: docker-clean
docker-clean: ## Remove the .env file for docker
	rm -f $(DOCKER_COMPOSE_DIR)/.env

.PHONY: docker-init
docker-init: .docker/.env ## Make sure the .env file exists for docker

.PHONY: docker-build-from-scratch
docker-build-from-scratch: docker-init ## Build all docker images from scratch, without cache etc. Build a specific image by providing the service name via: make docker-build CONTAINER=<service>
	$(DOCKER_COMPOSE) rm -fs $(CONTAINER) && \
	$(DOCKER_COMPOSE) build --pull --no-cache --parallel $(CONTAINER) && \
	$(DOCKER_COMPOSE) up -d --force-recreate $(CONTAINER)

.PHONY: docker-test
docker-test: docker-init docker-up ## Run the infrastructure tests for the docker setup
	sh $(DOCKER_COMPOSE_DIR)/docker-test.sh

.PHONY: docker-build
docker-build: docker-init ## Build all docker images. Build a specific image by providing the service name via: make docker-build CONTAINER=<service>
	$(DOCKER_COMPOSE) build --parallel $(CONTAINER) && \
	$(DOCKER_COMPOSE) up -d --force-recreate $(CONTAINER)

.PHONY: docker-prune
docker-prune: ## Remove unused docker resources via 'docker system prune -a -f --volumes'
	docker system prune

.PHONY: docker-prune-all
docker-prune-all: ## Remove unused docker resources via 'docker system prune -a -f --volumes'
	docker system prune -a -f --volumes

.PHONY: docker-up
docker-up: docker-init ## Start all docker containers. To only start one container, use CONTAINER=<service>
	$(DOCKER_COMPOSE) up -d $(CONTAINER)

.PHONY: docker-down
docker-down: docker-init ## Stop all docker containers. To only stop one container, use CONTAINER=<service>
	$(DOCKER_COMPOSE) down $(CONTAINER)

.PHONY: docker-config
docker-config: docker-init ## Show the docker-compose config with resolved .env values
	$(DOCKER_COMPOSE) config

.PHONY: docker-exec-php
docker-exec-php: ## Exec into the PHP container
	docker exec -it $$(docker ps --format {{.ID}} --filter name=php) bash

.PHONY: docker-logs
docker-logs: ## Tail all containers
	$(DOCKER_COMPOSE) logs -f

##@ [Application]

.PHONY: composer
composer: ## Run composer and provide the command via ARGS="command --options"
	$(RUN_IN_DOCKER) composer $(ARGS)

.PHONY: composer-install
composer-install: ## Run composer install
	$(RUN_IN_DOCKER) composer install

.PHONY: run-test
run-test: ## Run tests inside PHP and provide the command via ARGS="./app/tests/GraphQL/UpdateBookingMutationTest.php"
	$(RUN_IN_DOCKER) ./vendor/bin/phpunit $(ARGS)

.PHONY: run-flush
run-flush: ## Run flush=1 via cli"
	$(RUN_IN_DOCKER) ./vendor/bin/sake dev/tasks flush=1

.PHONY: run-build
run-build: ## Run /dev/build via cli"
	$(RUN_IN_DOCKER) ./vendor/bin/sake dev/build flush=1

.PHONY: run-dev-task
run-dev-task: ## Run /dev/build via ARGS="dev/tasks/GenerateAvailability"
	$(RUN_IN_DOCKER) vendor/bin/sake $(ARGS)
