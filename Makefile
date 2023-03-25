SRC_DIR := lib
BIN_DIR := bin
TEST_DIR := test
BUILD_DIR := build

# Set the XPM variable to the name of the Dart file to compile
NAME := xpm

.DEFAULT_GOAL := compile

test:
	dart test

compile:
	mkdir -p $(BUILD_DIR)
	dart compile exe $(BIN_DIR)/$(NAME).dart -o $(BUILD_DIR)/$(NAME)

clean:
	rm -rf $(BUILD_DIR)

.PHONY: test compile clean
