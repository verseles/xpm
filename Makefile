# Default target
.DEFAULT_GOAL := compile

CMD ?= ref

IMG ?= ubuntu # ubuntu, fedora, archlinux, opensuse
PKG ?= micro # package name
MET ?= auto # method: auto, any, apt, brew, dnf, pacman, choco, zypper, android

compile:
	mkdir -p build
	dart compile exe bin/xpm.dart -o build/xpm

try:
	build/xpm $(CMD)

test:
	dart test --concurrency=12 --test-randomize-ordering-seed=random

validate:
	docker build -f docker/$(IMG)/Dockerfile -t xpm:$(IMG) .
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


.PHONY: compile try test validate validate-all
