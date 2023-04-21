# Default target
.DEFAULT_GOAL := compile

CMD ?= ref
PKG ?= micro

compile:
	mkdir -p build
	dart compile exe bin/xpm.dart -o build/xpm

try:
	build/xpm $(CMD)

test:
	dart test --concurrency=12 --test-randomize-ordering-seed=random

ubuntu:
	docker build -f docker/ubuntu/Dockerfile -t xpm:ubuntu .
	docker run -it xpm xpm install $(PKG)

.PHONY: compile try test validate
