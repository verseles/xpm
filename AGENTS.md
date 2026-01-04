# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

If not specified, the request is for the **xpm/** directory.

## Project Overview

This is **xpm** (uniX Package Manager) - a universal package manager for Unix-like systems (Linux, BSD, macOS) with experimental Windows support. It's written in Dart and can act as a wrapper for native package managers or install packages using its own method.

- **Repository**: https://github.com/verseles/xpm
- **Version**: 0.76.0
- **License**: BSD 4-Clause "Original"

## Quick Start

```bash
# Install dependencies
dart pub get

# Format code
dart format --fix .

# Run static analysis
dart analyze

# Run tests
dart test --concurrency=12 --test-randomize-ordering-seed=random

# Build the binary
dart compile exe bin/xpm.dart -o build/xpm
```

## Common Commands

### Development Workflow
```bash
# Complete workflow (from README)
dart pub get && dart format --fix . && dart analyze && dart test

# Build the binary
make build
# or
dart compile exe bin/xpm.dart -o build/xpm

# Test the built binary
./build/xpm <command>
# or
make try CMD=<command>

# Run tests
make test
# or
dart test --concurrency=12 --test-randomize-ordering-seed=random
```

### Testing in Different Environments

The project includes Docker containers for testing across different distributions:

```bash
# Validate a specific package with a specific method on a specific distro
make validate IMG=ubuntu PKG=micro MET=apt

# Validate using auto method
make validate IMG=ubuntu PKG=micro MET=auto

# Validate using generic "any" method
make validate IMG=ubuntu PKG=micro MET=any

# Validate against all distros and methods
make validate-all

# Force method (bypass method detection)
make validate IMG=ubuntu PKG=micro MET=apt FM=true

# No cache build
make validate IMG=ubuntu PKG=micro MET=apt NC=true
```

Available distros: `ubuntu`, `fedora`, `archlinux`, `opensuse`, `brew`, `clearlinux`, `android`, `osx`

Available methods: `auto`, `any`, `apt`, `pacman`, `dnf`, `brew`, `choco`, `zypper`, `termux`, `swupd`, `flatpak`, `snap`

## Architecture

### Directory Structure

- **`bin/xpm.dart`**: Main entry point - initializes commands and sets up the CLI
- **`lib/commands/`**: Command implementations split into two categories:
  - **`humans/`**: User-facing commands (install, remove, search, refresh, upgrade)
  - **`devs/`**: Developer utilities (get, checksum, file, repo, log, make, check, shortcut)
- **`lib/os/`**: OS-level utilities (bash scripts, file operations, architecture detection, shortcuts)
- **`lib/database/`**: Isar database for storing packages and repositories
  - `models/`: Data models (Package, Repo, KV)
- **`lib/native_is_for_everyone/`**: Native package manager detection and handling
  - `distro_managers/`: Implementation for different package managers
  - `models/`: Native package data structures
- **`lib/utils/`**: General utilities (logger, JSON, version checker, etc.)
- **`test/`**: Unit tests
- **`docker/`**: Docker configurations for testing on different distros
- **`makefile`**: Build automation

### Key Components

1. **Command System**: Uses `package:args/command_runner.dart` for CLI argument parsing
2. **Database**: Isar (NoSQL) for storing package metadata and repository indices
3. **Bash Integration**: Executes bash-based installer scripts that follow the xpm spec
4. **OS Detection**: Automatically detects the operating system and package manager
5. **Method Selection**: Chooses the best installation method (native PM → xpm way)

### Package Installer Scripts

XPM uses bash scripts for package installation following the [xpm spec](https://github.com/verseles/xpm-popular). The main repository for installer scripts is https://github.com/verseles/xpm-popular.

Required function: `validate()`
Optional functions: `install_any()`, `remove_any()`, `install_apt()`, `remove_apt()`, etc.

## Important Files

- **`pubspec.yaml`**: Dependencies and project metadata
- **`analysis_options.yaml`**: Linting rules (uses `package:lints/recommended.yaml`)
- **`dart_test.yaml`**: Test tags configuration (sudo, skip-ci, not-tested, dpp)
- **`.github/workflows/global.yml`**: CI/CD pipeline (test, build, publish)

## Code Style

- Uses Dart's recommended lints (`package:lints/recommended.yaml`)
- Lines longer than 80 chars are allowed
- Formatted with `dart format`

## Testing Strategy

- Unit tests in `/test` directory
- Docker-based integration testing via `make validate` and `make validate-all`
- Test tags: `sudo`, `skip-ci`, `not-tested`, `dpp`
- Concurrency: 12 parallel tests

## Build System

The project uses:
- **Dart compiler**: `dart compile exe` to create standalone binaries
- **Make**: For common tasks (build, test, validate)
- **GitHub Actions**: For CI/CD (automated testing and releases)

Binary outputs are created in `build/` directory with platform-specific naming.

## Notable Features

1. **Fallback Mechanism**: If native package manager not available, falls back to generic "any" method
2. **Multiple PM Support**: apt, pacman, dnf, brew, choco, zypper, termux, swupd, flatpak, snap
3. **Architecture Mapping**: Translates xpm architecture names to platform-specific names
4. **Channel Support**: stable, beta, nightly channels for packages
5. **Non-interactive**: Designed to work without user prompts

## Dependencies

Key dependencies:
- `args`: CLI argument parsing
- `process_run`: Process execution
- `dio`: HTTP client
- `isar`: Database
- `pub_semver`: Version parsing
- `console`: Terminal UI
- `all_exit_codes`: Exit code management

## Release Process

Releases are automatically built and published via GitHub Actions when a tag matching `v*.*.*` is pushed. Binaries are created for Linux, macOS (and Windows in commented matrix).
