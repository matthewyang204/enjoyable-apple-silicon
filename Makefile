APP_NAME := Enjoyable
PROJECT := Enjoyable.xcodeproj
SCHEME := Enjoyable
CONFIGURATION ?= Debug
DERIVED_DATA ?= build
INSTALL_DIR ?= $(HOME)/Applications
APP_PATH := $(DERIVED_DATA)/Build/Products/$(CONFIGURATION)/$(APP_NAME).app
INSTALLED_APP_PATH := $(INSTALL_DIR)/$(APP_NAME).app
XCODEBUILD := xcodebuild -project $(PROJECT) -scheme $(SCHEME) -configuration $(CONFIGURATION) -derivedDataPath $(DERIVED_DATA)

.PHONY: help build debug release run open app install install-release clean

help:
	@echo "make build    Build the Debug app"
	@echo "make run      Build and launch the Debug app"
	@echo "make open     Launch the last built app"
	@echo "make app      Alias for make open"
	@echo "make install  Build and install the app to ~/Applications"
	@echo "make install-release  Build Release and install it to ~/Applications"
	@echo "make release  Build the Release app"
	@echo "make clean    Remove build artifacts"
	@echo ""
	@echo "Overrides:"
	@echo "  CONFIGURATION=Debug|Release"
	@echo "  DERIVED_DATA=build"
	@echo "  INSTALL_DIR=$(HOME)/Applications"

build: debug

debug:
	$(XCODEBUILD) build

release:
	$(MAKE) build CONFIGURATION=Release

open:
	@if [ ! -d "$(APP_PATH)" ]; then \
		echo "App not found at $(APP_PATH). Run 'make build' first."; \
		exit 1; \
	fi
	open "$(APP_PATH)"

app: open

run: build open

install: build
	@mkdir -p "$(INSTALL_DIR)"
	@rm -rf "$(INSTALLED_APP_PATH)"
	ditto "$(APP_PATH)" "$(INSTALLED_APP_PATH)"
	@echo "Installed to $(INSTALLED_APP_PATH)"

install-release:
	$(MAKE) install CONFIGURATION=Release

clean:
	rm -rf "$(DERIVED_DATA)"
