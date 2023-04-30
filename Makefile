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

# Get latest release tag
XTAG ?=$(shell curl -sL https://api.github.com/repos/verseles/xpm/releases/latest | jq -r '.tag_name')


compile:
	mkdir -p build
	dart compile exe bin/xpm.dart -o build/xpm

try:
	build/xpm $(CMD)

test:
	dart test --concurrency=12 --test-randomize-ordering-seed=random

validate:
	echo "Validating package $(PKG) with $(MET) method on $(IMG) image..."
	docker build --build-arg XTAG=$(XTAG) -t xpm:$(IMG) -f docker/$(IMG)/Dockerfile .
	docker run -it xpm:$(IMG) xpm install $(PKG) -m $(MET)

validate-all:
	$(MAKE) validate IMG=ubuntu MET=auto
	$(MAKE) validate IMG=ubuntu MET=any
	$(MAKE) validate IMG=ubuntu MET=apt
	$(MAKE) validate IMG=brew MET=auto
	$(MAKE) validate IMG=brew MET=brew
	$(MAKE) validate IMG=brew MET=any
	$(MAKE) validate IMG=fedora MET=auto
	$(MAKE) validate IMG=fedora MET=any
	$(MAKE) validate IMG=fedora MET=dnf
	$(MAKE) validate IMG=archlinux MET=auto
	$(MAKE) validate IMG=archlinux MET=any
	$(MAKE) validate IMG=archlinux MET=pacman
	$(MAKE) validate IMG=opensuse MET=auto
	$(MAKE) validate IMG=opensuse MET=any
	$(MAKE) validate IMG=opensuse MET=zypper
	$(MAKE) validate IMG=clearlinux MET=auto
	$(MAKE) validate IMG=clearlinux MET=any
	$(MAKE) validate IMG=clearlinux MET=swupd


.PHONY: compile try test validate validate-all
