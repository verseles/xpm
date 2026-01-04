.PHONY: all build release test fmt clippy check precommit clean install

# Default target
all: build

# Development build
build:
	cargo build

# Release build (optimized)
release:
	cargo build --release

# Run all tests
test:
	cargo test

# Format code
fmt:
	cargo fmt

# Check formatting without modifying
fmt-check:
	cargo fmt -- --check

# Run clippy linter
clippy:
	cargo clippy -- -D warnings

# Run all checks (what CI does)
check: fmt-check clippy test
	@echo "All checks passed!"

# Pre-commit hook: run everything before pushing
precommit: fmt clippy test
	@echo ""
	@echo "✓ All pre-commit checks passed!"
	@echo "  Ready to commit and push."

# Clean build artifacts
clean:
	cargo clean

# Install to system
install: release
	sudo cp target/release/xpm /usr/local/bin/
	@echo "Installed xpm to /usr/local/bin/"

# Run the binary
run:
	cargo run --

# Run with arguments (use: make run-args ARGS="search vim")
run-args:
	cargo run -- $(ARGS)

# Watch for changes and rebuild (requires cargo-watch)
watch:
	cargo watch -x build

# Generate documentation
doc:
	cargo doc --open

# Update dependencies
update:
	cargo update

# Show outdated dependencies (requires cargo-outdated)
outdated:
	cargo outdated

# Security audit (requires cargo-audit)
audit:
	cargo audit
