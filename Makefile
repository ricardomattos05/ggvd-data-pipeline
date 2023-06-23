SHELL=/bin/bash

.DEFAULT_GOAL := help

#################################################################################
# GLOBALS                                                                       #
#################################################################################

PROJECT_DIR := $(shell dirname $(realpath $(lastword $(MAKEFILE_LIST))))
PYTHON_INTERPRETER = python3
CONFIG_FILE=configs.ini
CONFIG_KEY_NAME=required_python

#################################################################################
# BLOCK TO TEST PYTHON INSTALLATION                                             #
#################################################################################

# Test if python is installed

ifeq (,$(shell $(PYTHON_INTERPRETER) --version))
$(error "Python is not installed!")
endif


#################################################################################
# COMMANDS                                                                      #
#################################################################################

# Verify Python Version
check_installed_python:
	$(eval INSTALLED := $(shell $(PYTHON_INTERPRETER) --version | tr -cd '[[:digit:][:punct:]]'))
	$(eval REQUIRED := $(shell [ -f $(CONFIG_FILE) ] && cat $(CONFIG_FILE) | grep -w $(CONFIG_KEY_NAME) | cut -f2 -d "="))

	@if [ -z "$(REQUIRED)" ] | [ $(shell echo -n "$(REQUIRED)" | wc -c ) -lt 3 ]; then \
		echo "Missing configurarion file or key"; \
		return 1; \
	fi

	@if { echo "$(REQUIRED)" ; echo "$(INSTALLED)"; } | sort --version-sort --check=quiet; then \
		echo "Python interpreter is up to date: required Python '$(REQUIRED)' found Python '$(INSTALLED)'"; \
	else \
		echo "Python version error: required Python '$(REQUIRED)' found Python '$(INSTALLED)'" ; \
		exit 1; \
	fi

.PHONY: help
help: ## Shows this help text
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | sort | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-30s\033[0m %s\n", $$1, $$2}'

.PHONY: init
init: clean install checkov test ## Clean environment and reinstall all dependencies

.PHONY: clean
clean: ## Removes project virtual env
	rm -rf .venv cdk.out build dist **/*.egg-info .pytest_cache node_modules .coverage

.PHONY: install
install: check_installed_python ## Install the project dependencies and pre-commit using pip.
	python3 -m venv .venv
	source .venv/bin/activate && pip install -r requirements.txt
	pip install -r requirements.txt
	pip install pre-commit
	pre-commit install --hook-type pre-commit --hook-type commit-msg --hook-type pre-push

.PHONY: test
test: ## Run tests
	python -m pytest

.PHONY: lint
lint: ## Apply linters to all files
	pre-commit run --all-files

.PHONY: synth
synth: ## Synthetize all Cdk stacks
	cdk synth

.PHONY: checkov
checkov: synth ## Run Checkov against IAC code
	checkov --config-file .checkov --baseline .checkov.baseline

.PHONY: checkov-baseline
checkov-baseline: synth ## Run checkov and create a new baseline for future checks
	checkov --config-file .checkov --create-baseline --soft-fail
	mv cdk.out/.checkov.baseline .checkov.baseline

.PHONY: build
build: ## Build the Docker image for local Lambda development
	sam build --use-container


FUNCTION_DIR ?= data_pipeline/bronze/source/table
FUNCTION_BUILD_DIR = $(FUNCTION_DIR)/build
BASE_DIR = $(firstword $(subst /, ,$(FUNCTION_DIR)))/$(word 2,$(subst /, ,$(FUNCTION_DIR)))
UTILS_DIR = $(BASE_DIR)/utils

.PHONY: package_dependencies
package_dependencies:
	docker build -t lambda-dependencies --build-arg FUNCTION_DIR=$(FUNCTION_DIR) .
	docker run --rm -v $(PWD)/$(FUNCTION_DIR):/output lambda-dependencies bash -c "mkdir /output/python && cp -r /var/lang/lib/python3.9/site-packages/* /output/python && rm -rf /output/python/pip* /output/python/setuptools* /output/python/wheel* && cd /output && zip -r python.zip python"


.PHONY: package
package: ## Package the Lambda function code for deployment. Define FUNCTION_DIR=data_pipeline/layer/source/table to package a specific function
	mkdir -p $(FUNCTION_BUILD_DIR)
	find $(FUNCTION_DIR) -type f -name "*.py" ! -name "__init__.py" ! -path "*/__pycache__/*" ! -path "*/python/*" -exec cp {} $(FUNCTION_BUILD_DIR) \;
	cp -r $(UTILS_DIR)/* $(FUNCTION_BUILD_DIR)/
	cd $(FUNCTION_BUILD_DIR) && zip -r ../package.zip * -x "*__init__.py" -x "*__pycache__/*"
	rm -r $(FUNCTION_DIR)/build

# Set FUNCTION_DIR to run the package command and create package.zip for the table you want to:
# make package FUNCTION_DIR=data_pipeline/bronze/source/table

.PHONY: build_package
build_package: package_dependencies package ## Package the Lambda function code and dependencies for deployment. Define FUNCTION_DIR=data_pipeline/layer/source/table to package a specific function
	rm -r $(FUNCTION_DIR)/python

.PHONY: invoke_bronze_function
invoke_bronze_function: ## Invoke the bronze/source/table Lambda function locally using SAM. Define FUNCTION_DIR=data_pipeline/bronze/source/table to invoke a specific function
	@echo "Invoking Lambda function $(function) locally"
	sam local invoke BronzeSourceTableFunction -e $(FUNCTION_DIR)/event.json
# add other functions for locally invoke using SAM

.PHONY: deploy
deploy: ## Deploy the Lambda function to AWS
	sam deploy --template-file packaged.yaml --stack-name $(shell cat config.json | jq -r '.stack_name') --capabilities $(shell cat config.json | jq -r '.capabilities') --profile $(shell cat config.json | jq -r '.profile')
