# Default target
.DEFAULT_GOAL := compile

CMD ?= ref

IMG ?= ubuntu
PKG ?= micro

compile:
	mkdir -p build
	dart compile exe bin/xpm.dart -o build/xpm

try:
	build/xpm $(CMD)

test:
	dart test --concurrency=12 --test-randomize-ordering-seed=random

validate:
	docker build -f docker/$(IMG)/Dockerfile -t xpm:$(IMG) .
	docker run -it xpm:$(IMG) xpm install $(PKG)

.PHONY: compile try test validate
