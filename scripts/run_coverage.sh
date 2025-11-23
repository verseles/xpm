#!/bin/bash
# XPM Coverage Script
# This script generates test coverage reports

set -e

echo "=== XPM Coverage Report Generator ==="
echo ""

# Check if Dart is installed
if ! command -v dart &> /dev/null; then
    echo "ERROR: Dart SDK not found in PATH"
    exit 1
fi

# Install coverage package globally
echo "=== Installing coverage package ==="
dart pub global activate coverage

# Get dependencies
echo ""
echo "=== Installing dependencies ==="
dart pub get

# Run tests with coverage
echo ""
echo "=== Running tests with coverage ==="
dart test --coverage=coverage

# Format coverage report
echo ""
echo "=== Generating LCOV report ==="
dart pub global run coverage:format_coverage \
    --lcov \
    --in=coverage \
    --out=coverage/lcov.info \
    --report-on=lib

echo ""
echo "=== Coverage report generated ==="
echo "Output: coverage/lcov.info"
echo ""
echo "To view HTML report, install lcov and run:"
echo "  genhtml coverage/lcov.info -o coverage/html"
echo "  open coverage/html/index.html"
