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

test:
	dart test --concurrency=12 --test-randomize-ordering-seed=random

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


.PHONY: build try test validate validate-all
