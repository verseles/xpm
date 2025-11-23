#!/bin/bash
# XPM Test Runner Script
# This script runs all tests for XPM

set -e

echo "=== XPM Test Runner ==="
echo ""

# Check if Dart is installed
if ! command -v dart &> /dev/null; then
    echo "ERROR: Dart SDK not found in PATH"
    echo ""
    echo "Please install Dart SDK:"
    echo "  - Ubuntu/Debian: sudo apt install dart"
    echo "  - Arch Linux: sudo pacman -S dart"
    echo "  - macOS: brew install dart"
    echo "  - Or download from: https://dart.dev/get-dart"
    exit 1
fi

echo "Dart version: $(dart --version)"
echo ""

# Get dependencies
echo "=== Installing dependencies ==="
dart pub get

# Run build_runner if needed
if [ -f "build.yaml" ]; then
    echo ""
    echo "=== Running build_runner ==="
    dart run build_runner build --delete-conflicting-outputs
fi

# Run tests
echo ""
echo "=== Running tests ==="
dart test --concurrency=12 --test-randomize-ordering-seed=random "$@"

echo ""
echo "=== Tests completed ==="
