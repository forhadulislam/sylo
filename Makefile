PREFERRED_GO_VERSION?=1.17.0
ACTUAL_GO_VERSION := $(shell go version | cut -d ' ' -f3)
REQ_GO_MINOR_VERSION := $(shell echo ${PREFERRED_GO_VERSION} | cut -d '.' -f2)
SYSTEM_GO_MINOR_VERSION  := $(shell echo ${ACTUAL_GO_VERSION} | cut -d '.' -f2)



SERVICE_ROOT = "./services/"
PACKAGE_ROOT = "./packages/"
RESOURCES_ROOT = "./.resources/"
SERVICE_TEMPLATE_DIR = $(RESOURCES_ROOT)service-template/*
PACKAGE_TEMPLATE_DIR = $(RESOURCES_ROOT)package-template/*

GO_BIN?=/snap/bin/go

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

showGo: ${GO_BIN} check-go
	@echo "Required Go version: ${PREFERRED_GO_VERSION}"
	@echo "${ACTUAL_GO_VERSION}"
	@echo "${REQ_GO_MINOR_VERSION}"
	@echo "${SYSTEM_GO_MINOR_VERSION}"
