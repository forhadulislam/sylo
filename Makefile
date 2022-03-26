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
FIND_FILES_WITH_SPACES := $(shell find ./  | grep " ")
BRANCH_NAME := $(shell git rev-parse --abbrev-ref HEAD)
CHANGED_FILES := $(shell git diff origin/master... --name-only)
CHANGED_SERVICES := $(shell git ls-files --modified --others ${SERVICE_ROOT})
STAGED_CHANGED_FILES := $(shell git diff --cached --name-only)

UNTRACKED_FILES := $(shell git ls-files --others --exclude-standard)
DELETED_FILES_SVC := $(shell git ls-files --deleted ./services/) # TODO: List deleted files
CHANGED_SERVICES_ALL := ${CHANGED_SERVICES} ${CHANGED_FILES} # Append changed files
CHANGED_FILES_WITHOUT_DELETED = $(filter-out ${DELETED_FILES_SVC}, $(CHANGED_SERVICES_ALL)) # Remove deleted files from list
CHANGED_FILES_FOR_SERVICES = $(filter services%,$(CHANGED_FILES_WITHOUT_DELETED)) # Filter service related files only
CHANGED_SERVICES_NAMES = $(patsubst services/%/%.go,services/%/%.sdd/,$(CHANGED_FILES_FOR_SERVICES)) # TODO: filter changed service names
SERVICES_LIST := $(wildcard services/*)

ALL_CHANGED_FILES := ${CHANGED_SERVICES} ${CHANGED_FILES} ${STAGED_CHANGED_FILES}
ALL_CHANGED_FILES_MASTER := ${CHANGED_SERVICES} $(shell git diff HEAD^ HEAD --name-only)
# ALL_CHANGED_SERVICES_UNIQ := $(call _uniq, $(foreach F,$(ALL_CHANGED_FILES),$(word 2,$(subst /, ,$F)))) 
ALL_CHANGED_SERVICES ?= $(call sort, $(foreach F,$(ALL_CHANGED_FILES),$(word 2,$(subst /, ,$F))))
ALL_CHANGED_SERVICES_MASTER ?= $(call sort, $(foreach F,$(ALL_CHANGED_FILES_MASTER),$(word 2,$(subst /, ,$F)))) 
ALL_CHANGED_FILES_WITH_EXTENSIONS := $(foreach F,$(ALL_CHANGED_FILES),$(lastword $(subst /, ,$F)))
TMP_SRV := 
_uniq = $(if $1,$(firstword $1) $(call uniq,$(filter-out $(firstword $1),$1)))

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

# Previously ALL_CHANGED_SERVICES_MASTER was here but currently runnning all
# of the unit-tests in every run. Trying to figure out how to compare latest
# commit with the last in Github build 
unit-tests: find-files-with-spaces changed-files
	@echo "### Running unit tests ###";
	@echo ${SERVICES_LIST}
	@if [ "$(TMP_SRV)" = " " ]; then \
		echo "No service got changed. Skipping unit test run."; \
	fi
	@$(foreach ch_service,$(SERVICES_LIST),\
		if [ -d "$(ch_service)" ]; then \
			echo Running unit tests for service: ${ch_service}; \
			go test -v ./$(ch_service)/...; \
		fi; \
	)

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

find-files-with-spaces:
	@if [ "$(FIND_FILES_WITH_SPACES)" = "" ]; then \
		echo "All good"; \
	else \
		echo "There are directories/files named with spaces. Please fix those issues"; \
		echo ${FIND_FILES_WITH_SPACES}; \
		exit 1; \
	fi

changed-files: find-files-with-spaces	
	@if [ "$(BRANCH_NAME)" = "master" ]; then \
		$(eval TMP_SRV := ${ALL_CHANGED_SERVICES_MASTER}) \
		echo "This is master branch"; \
	else \
		echo "this is not master branch"; \
	fi \

	@echo ALL SERVICES: $(SERVICES_LIST)
	@echo CHANGED SERVICES: $(ALL_CHANGED_SERVICES)

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
	echo argument is $(argument)
	docker build ./.resources/containers/validator -t validator
	# $(eval VALIDATE_DIR=target/${*}/hart/${@F})
	# docker pull docker-registry.local/validator:latest
	@docker run --rm \
		-v "${CURDIR}/target/${*}:/workdir" \
		-e APP_NAME=${@F} \
		-e COMMIT_ID=${COMMIT_ID} \
		-e CHANGE_ID=${CHANGE_ID} \
		-e VERSION=${SVC_VERSION} \
		-e ENTRYPOINT=someshell.sh \
		validator:latest
	# @rm -rf ${VALIDATE_DIR}
	@echo $1
	@echo $(shell echo $(MAKECMDGOALS) | sed 's!^.* $@ !!')

run-go-tools:
	@echo Validating for Validator
	docker build ./.resources/containers/go-tools -t go-tools
	@docker run --rm \
		-v "${CURDIR}/target/${*}:/workdir" \
		-e APP_NAME=${@F} \
		-e COMMIT_ID=${COMMIT_ID} \
		-e CHANGE_ID=${CHANGE_ID} \
		-e VERSION=${SVC_VERSION} \
		-e ENTRYPOINT=someshell.sh \
		go-tools:latest
	# @rm -rf ${VALIDATE_DIR}

showGo: ${GO_BIN} check-go
	@echo "Required Go version: ${PREFERRED_GO_VERSION}"
	@echo "${ACTUAL_GO_VERSION}"
	@echo "${REQ_GO_MINOR_VERSION}"
	@echo "${SYSTEM_GO_MINOR_VERSION}"
