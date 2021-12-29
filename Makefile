PREFERRED_GO_VERSION?=1.17.0
ACTUAL_GO_VERSION := $(shell go version | cut -d ' ' -f3)
REQ_GO_MINOR_VERSION := $(shell echo ${PREFERRED_GO_VERSION} | cut -d '.' -f2)
SYSTEM_GO_MINOR_VERSION  := $(shell echo ${ACTUAL_GO_VERSION} | cut -d '.' -f2)

SERVICE_ROOT = "./services/"
PACKAGE_ROOT = "./packages/"
RESOURCES_ROOT = "./.resources/"
SERVICE_TEMPLATE_DIR = $(RESOURCES_ROOT)service-template/*
PACKAGE_TEMPLATE_DIR = $(RESOURCES_ROOT)package-template/*
ALL_PACKAGES_WITH_OPENAPI := $(patsubst pkg/%/api_codegen.go,pkg/%,$(wildcard pkg/*/api_codegen.go))
ALL_SERVICES_WITH_DB := $(patsubst svc/%/migrations/db,svc/%,$(wildcard svc/*/migrations/db)) # instead of db it can be something else i.e mysql 
CHANGED_FILES := $(shell git diff origin/master... --name-only)
CHANGED_SERVICES := $(shell git ls-files --modified --others ./services/)
DELETED_FILES_SVC := $(shell git ls-files --deleted ./services/) # TODO: List deleted files
CHANGED_SERVICES_ALL := ${CHANGED_SERVICES} ${CHANGED_FILES} # Append changed files
CHANGED_FILES_WITHOUT_DELETED = $(filter-out ${DELETED_FILES_SVC}, $(CHANGED_SERVICES_ALL)) # Remove deleted files from list
CHANGED_FILES_FOR_SERVICES = $(filter services%,$(CHANGED_FILES_WITHOUT_DELETED)) # Filter service related files only
CHANGED_SERVICES_NAMES = $(patsubst services/%/%.go,services/%/%.sdd/,$(CHANGED_FILES_FOR_SERVICES)) # TODO: filter changed service names

GO_BIN?=/snap/bin/go # Go Binary

DUPS:=a b a a c

objects = main.o foo.o bar.o utils.o
objects += another.o

ifeq ($(OS),Windows_NT)
	@echo "this is windows"
endif

check-go:
	@echo "Actual go version is ${ACTUAL_GO_VERSION}"

new-service:
	@read -p "Enter Service Name: " SERVICE_NAME; \
	if [ -d "$(SERVICE_ROOT)$$SERVICE_NAME" ]; then \
        echo "'$$SERVICE_NAME' service exists. Please try again with an unique service name."; \
		exit; \
    fi; \
	mkdir -p $(SERVICE_ROOT)$$SERVICE_NAME; \
	cp -r $(SERVICE_TEMPLATE_DIR) "$(SERVICE_ROOT)$$SERVICE_NAME"; \
	echo "Your service '$$SERVICE_NAME' created!"; \

new-package:
	@read -p "Enter Package Name: " PACKAGE_NAME; \
	if [ -d "$(PACKAGE_ROOT)$$PACKAGE_NAME" ]; then \
        echo "'$$PACKAGE_NAME' package exists. Please try again with an unique package name."; \
		exit; \
    fi; \
	mkdir -p $(PACKAGE_ROOT)$$PACKAGE_NAME; \
	cp -r $(PACKAGE_TEMPLATE_DIR) "$(PACKAGE_ROOT)$$PACKAGE_NAME"; \
	echo $(PACKAGE_ROOT)$$PACKAGE_NAME"/package.go"; \
	sed -i -e "s/#PACKAGE_TITLE#/$$PACKAGE_NAME/g" $(PACKAGE_ROOT)$$PACKAGE_NAME"/package.go"; \
	sed -i -e "s/#PACKAGE_TITLE#/$$PACKAGE_NAME/g" $(PACKAGE_ROOT)$$PACKAGE_NAME"/package_test.go"; \
	echo "Your package '$$PACKAGE_NAME' created!"; \

delete-service:
	@echo "Deleting service: $(service)"
	
tests:
	@echo "### Running tests -"

trash:
	@read -p "Enter Service Name:" SERVICE_NAME; \
	echo "Trashing service: " $$SERVICE_NAME
	
clean:
	docker-compose down -v
	
start-up:
	docker-compose down -v
	docker-compose up
	
up:
	docker-compose up -V --remove-orphans --always-recreate-deps dependencies
	
down:
	docker-compose down --volumes --remove-orphans

changed-files:
	@echo "Changed files"
	@echo ${CHANGED_FILES}

changed-services: changed-files
	@echo "Changed services"
	@echo ${CHANGED_SERVICES}

loop-changed-services:
	echo "sBss"	
	echo ${objects}

changed-services-all:
	@echo "ALL Changed services "
	@echo ${CHANGED_SERVICES_ALL}
	@echo "Deleted files for services"
	@echo ${DELETED_FILES_SVC}
	@echo "Changed files without deleted"
	@echo ${CHANGED_FILES_FOR_SERVICES}
	@echo "CHANGED_SERVICES_NAMES"
	@echo ${CHANGED_SERVICES_NAMES}

run-bash:
	NAME=samid ./cli.sh functionA blah
	@export NAME=somethingelse
	echo $(NAME)
	echo $$NAME

validate:
	# @echo Validating for ${@F}
	@echo Validating for Validator
	docker build ./.resources/containers/validator -t validator
	# $(eval VALIDATE_DIR=target/${*}/hart/${@F})
	# docker pull docker-registry.local/validator:latest
	@docker run --rm \
		-v "${CURDIR}/target/${*}:/workdir" \
		-e APP_NAME=${@F} \
		-e COMMIT_ID=${COMMIT_ID} \
		-e CHANGE_ID=${CHANGE_ID} \
		-e VERSION=${SVC_VERSION} \
		validator:latest
	# @rm -rf ${VALIDATE_DIR}
	@echo $?

showGo: ${GO_BIN} check-go
	@echo "Required Go version: ${PREFERRED_GO_VERSION}"
	@echo "${ACTUAL_GO_VERSION}"
	@echo "${REQ_GO_MINOR_VERSION}"
	@echo "${SYSTEM_GO_MINOR_VERSION}"
