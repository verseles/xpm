.PHONY: all build release test fmt clippy check precommit clean install docker-ubuntu docker-arch docker-fedora docker-opensuse docker-clearlinux docker-homebrew docker-test

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

# === Container Testing (Podman) ===

# Build Ubuntu test container
docker-ubuntu:
	podman-compose -f docker/podman-compose.yml build ubuntu

# Build Arch test container
docker-arch:
	podman-compose -f docker/podman-compose.yml build arch

# Build Fedora test container
docker-fedora:
	podman-compose -f docker/podman-compose.yml build fedora

# Build openSUSE test container
docker-opensuse:
	podman-compose -f docker/podman-compose.yml build opensuse

# Build Clear Linux test container
docker-clearlinux:
	podman-compose -f docker/podman-compose.yml build clearlinux

# Build Homebrew test container
docker-homebrew:
	podman-compose -f docker/podman-compose.yml build homebrew

# Build all test containers
docker-build: docker-ubuntu docker-arch docker-fedora docker-opensuse docker-clearlinux docker-homebrew

# Test on Ubuntu
test-ubuntu:
	podman-compose -f docker/podman-compose.yml run --rm ubuntu

# Test on Arch
test-arch:
	podman-compose -f docker/podman-compose.yml run --rm arch

# Test on Fedora
test-fedora:
	podman-compose -f docker/podman-compose.yml run --rm fedora

# Test on openSUSE
test-opensuse:
	podman-compose -f docker/podman-compose.yml run --rm opensuse

# Test on Clear Linux
test-clearlinux:
	podman-compose -f docker/podman-compose.yml run --rm clearlinux

# Test on Homebrew
test-homebrew:
	podman-compose -f docker/podman-compose.yml run --rm homebrew

# Test on all distros
docker-test: docker-build test-ubuntu test-arch test-fedora test-opensuse test-clearlinux test-homebrew
	@echo ""
	@echo "✓ All container tests completed!"

# Clean container images
docker-clean:
	podman-compose -f docker/podman-compose.yml down --rmi all 2>/dev/null || true
