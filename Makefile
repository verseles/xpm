.DEFAULT_GOAL := compile

test:
	dart test

ci:
	dart pub get
	dart format --output=none --set-exit-if-changed .
	dart analyze
	dart test

compile:
	mkdir -p ./build
	dart compile exe $(BIN_DIR)/xpm.dart -o ./build/xpm

clean:
	rm -rf ./build

.PHONY: test compile clean ci
