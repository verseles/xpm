# Default target
.DEFAULT_GOAL := compile

# xpm command
CMD ?= ref

# ubuntu, fedora, archlinux, opensuse
IMG ?= ubuntu
# package name
PKG ?= micro
# auto, any, apt, brew, dnf, pacman, zypper
MET ?= auto

# NO CACHE
NC ?= false
# FORCE METHOD
FM ?= false

# Get latest release tag
XTAG ?=$(shell curl -sL https://api.github.com/repos/verseles/xpm/releases/latest | jq -r '.tag_name')


build:
	mkdir -p build
	dart compile exe bin/xpm.dart -o build/xpm

try:
	build/xpm $(CMD)

test: build
	dart test --concurrency=12 --test-randomize-ordering-seed=random

# Run tests with coverage
coverage:
	dart pub global activate coverage
	dart test --coverage=coverage
	dart pub global run coverage:format_coverage --lcov --in=coverage --out=coverage/lcov.info --report-on=lib
	@echo "Coverage report generated at coverage/lcov.info"

# Run tests on all platforms using docker-compose
test-all:
	docker-compose build
	docker-compose run --rm ubuntu-test
	docker-compose run --rm fedora-test
	docker-compose run --rm arch-test
	docker-compose run --rm opensuse-test

# Run tests on a specific platform
test-ubuntu:
	docker-compose build ubuntu-test
	docker-compose run --rm ubuntu-test

test-fedora:
	docker-compose build fedora-test
	docker-compose run --rm fedora-test

test-arch:
	docker-compose build arch-test
	docker-compose run --rm arch-test

test-opensuse:
	docker-compose build opensuse-test
	docker-compose run --rm opensuse-test

validate:
	echo "Validating package $(PKG) with $(MET) method on $(IMG) image... XPM"
	docker build --build-arg XTAG=$(XTAG) -t xpm:$(IMG) -f docker/$(IMG)/Dockerfile . $(if $(NC == true),--no-cache)
	docker run -it xpm:$(IMG) /bin/sh -c "xpm ref && xpm install $(PKG) -m $(MET) $(if $(FM == true),--force-method)"

validate-all:
	$(MAKE) validate IMG=ubuntu MET=apt FM=true NC=$(NC)
	$(MAKE) validate IMG=brew MET=brew FM=true NC=$(NC)
	$(MAKE) validate IMG=fedora MET=dnf FM=true NC=$(NC)
	$(MAKE) validate IMG=fedora MET=pack FM=true NC=$(NC)
	$(MAKE) validate IMG=archlinux MET=pacman FM=true NC=$(NC)
	$(MAKE) validate IMG=opensuse MET=zypper FM=true NC=$(NC)
	$(MAKE) validate IMG=clearlinux MET=swupd FM=true NC=$(NC)
	$(MAKE) validate IMG=ubuntu MET=auto NC=$(NC)
	$(MAKE) validate IMG=fedora MET=auto NC=$(NC)
	$(MAKE) validate IMG=archlinux MET=auto NC=$(NC)
	$(MAKE) validate IMG=opensuse MET=auto NC=$(NC)
	$(MAKE) validate IMG=clearlinux MET=auto NC=$(NC)
	$(MAKE) validate IMG=ubuntu MET=any NC=$(NC)

tog:
	tog * --ignore-folders=.git,.idea,.dart_tool,.vscode,build,.github


.PHONY: build try test coverage test-all test-ubuntu test-fedora test-arch test-opensuse validate validate-all
