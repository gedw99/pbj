# https://developer.apple.com/sample-code/app-store-connect/app-store-connect-openapi-specification.zip

OS_GO_BIN_NAME=go
ifeq ($(shell uname),Windows)
	OS_GO_BIN_NAME=go.exe
endif

OS_GO_OS=$(shell $(OS_GO_BIN_NAME) env GOOS)
# toggle to fake being windows..
#OS_GO_OS=windows

BIN_ROOT=$(PWD)/.bin
export PATH:=$(PATH):$(BIN_ROOT)
DATA_ROOT=$(PWD)/.data

BIN_MAIN_NAME=pbj
ifeq ($(OS_GO_OS),windows)
	BIN=$(BIN_MAIN_NAME)/pbj.exe
endif
BIN_MAIN=$(BIN_ROOT)/$(BIN_MAIN_NAME)
BIN_MAIN_WHICH=$(shell command -v $(BIN_MAIN_NAME))

BIN_GEN_NAME=pb-gen
ifeq ($(OS_GO_OS),windows)
	BIN=$(BIN_MAIN_NAME)/pb-gen.exe
endif
BIN_GEN_WHICH=$(shell command -v $(BIN_GEN_NAME))

BIN_GMU_NAME=go-mod-upgrade
ifeq ($(OS_GO_OS),windows)
	BIN=$(BIN_GMU_NAME)/go-mod-upgrade.exe
endif
BIN_GMU_WHICH=$(shell command -v $(BIN_GMU_NAME))


.PHONY: help
help: # Show help for each of the Makefile recipes.
	@grep -E '^[a-zA-Z0-9 -]+:.*#'  Makefile | sort | while read -r l; do printf "\033[1;32m$$(echo $$l | cut -f 1 -d':')\033[00m:$$(echo $$l | cut -f 2- -d'#')\n"; done


print:
	@echo ""
	@echo "OS_GO_BIN_NAME:   $(OS_GO_BIN_NAME)"
	@echo ""
	@echo "OS_GO_OS:         $(OS_GO_OS)"
	@echo ""
	@echo ""
	@echo "BIN_ROOT:         $(BIN_ROOT)"
	@echo "DATA_ROOT:        $(DATA_ROOT)"
	@echo ""
	@echo ""
	@echo "bin:"
	@echo "BIN_MAIN:         $(BIN_MAIN)"
	@echo "BIN_MAIN_NAME:    $(BIN_MAIN_NAME)"
	@echo "BIN_MAIN_WHICH:   $(BIN_MAIN_WHICH)"
	@echo ""
	@echo "tools:"
	@echo ""
	@echo "BIN_GEN_NAME:     $(BIN_GEN_NAME)"
	@echo "BIN_GEN_WHICH:    $(BIN_GEN_WHICH)"
	@echo ""
	@echo "BIN_GMU_NAME:     $(BIN_GMU_NAME)"
	@echo "BIN_GMU_WHICH:    $(BIN_GMU_WHICH)"
	@echo ""

ci-build: # build for ci, that can be called from Windows, MacOS or Linux
	# You can call this locally. github workflow also calls it.
	# Its calling everything in the makefile ...
	@echo ""
	@echo "CI BUILD starting ..."
	$(MAKE) help
	$(MAKE) dep-tools
	$(MAKE) print
	$(MAKE) bin-clean
	$(MAKE) data-clean
	$(MAKE) bin-build
	@echo ""
	@echo "CI BUILD ended ...."

dep-tools:
	# gens golang models of PB. 
	# https://github.com/alexisvisco/pocketpase-gen
	go install github.com/alexisvisco/pocketpase-gen/cmd/pb-gen@latest

	# https://github.com/oligot/go-mod-upgrade
	# https://github.com/oligot/go-mod-upgrade/releases/tag/v0.9.1
	go install github.com/oligot/go-mod-upgrade@v0.9.1

mod-up:
	go mod tidy
	go-mod-upgrade
	go mod tidy
mod-tidy:
	go mod tidy

config-email:
	# 1. Create a brand new regular gmail account.
	# 2. Enable 2fa (it seems required if you want to use App passwords)
	# 3. Go to https://myaccount.google.com/apppasswords and select the "Other" option from the app dropdown:
	# 4. Go to http://127.0.0.1:8090/_/#/settings/mail and use the generated password in the smtp settings:
		# host: smtp.gmail.com
		# port: 587
		# tls: auto
		# user: yourusername@gmail.com
		# pass: the generated password from step 3 ( grsz fhqh lheg grao )

bin-init:
	mkdir -p $(BIN_ROOT)
bin-clean:
	rm -rf $(BIN_ROOT)
bin-build: bin-init
	cd cmd/demo && go build -o $(BIN_MAIN) .

data-init:
	mkdir -p $(DATA_ROOT)
data-clean:
	rm -rf $(DATA_ROOT)

run-serve:
	$(BIN_MAIN_NAME) serve

	# Admin: 	http://127.0.0.1:8090/_/
	# Users: 	http://127.0.0.1:8090

	# user
	# joeblew99@gmail.com
	# password-known

run-admin:
	$(BIN_MAIN) admin
	# admin
	# gedw99@gmail.com
	# password-known

run-migrate:
	$(BIN_MAIN) migrate

run-gen:
	$(BIN_MAIN) pb-gen models

