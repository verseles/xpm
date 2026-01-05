# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

If not specified, the request is for the **xpm/** directory.

## Project Overview

This is **xpm** (uniX Package Manager) - a universal package manager for Unix-like systems (Linux, BSD, macOS) with experimental Windows support. Written in **Rust** as a workspace with two crates.

- **Repository**: https://github.com/verseles/xpm
- **License**: BSD 4-Clause "Original"

## Quick Start

```bash
# Build debug
cargo build

# Build release
cargo build --release

# Run tests
cargo test

# Format code
cargo fmt

# Lint
cargo clippy

# Full precommit check
make precommit
```

## Common Commands

### Development Workflow
```bash
# Complete workflow
make precommit

# Build release binary
make release

# Install locally
make install

# Run tests
make test
```

### Testing in Different Environments

The project includes Podman containers for testing across different distributions:

```bash
# Test on Ubuntu
make test-ubuntu

# Test on Arch Linux
make test-arch

# Test on Fedora
make test-fedora

# Test on openSUSE
make test-opensuse

# Test on Clear Linux
make test-clearlinux

# Test on Homebrew (Linux)
make test-homebrew

# Test all distros
make test-all
```

Available distros: `ubuntu`, `arch`, `fedora`, `opensuse`, `clearlinux`, `homebrew`

## Architecture

### Directory Structure

```
xpm/
├── Cargo.toml              # Workspace definition
├── crates/
│   ├── xpm-cli/            # CLI frontend
│   │   └── src/
│   │       ├── main.rs     # Entry point (Clap)
│   │       └── commands/   # CLI commands
│   └── xpm-core/           # Core library
│       └── src/
│           ├── db/         # Database (native_db/redb)
│           ├── native_pm/  # Package manager integrations
│           ├── os/         # OS utilities
│           ├── script/     # Bash script parsing
│           ├── repo/       # Git-based repositories
│           └── utils/      # Utilities
├── docker/                 # Container test configs
└── Makefile               # Build automation
```

### Key Components

1. **Command System**: Uses `clap` for CLI argument parsing
2. **Database**: `native_db` with `redb` backend for package metadata
3. **Bash Integration**: Executes bash-based installer scripts following xpm spec
4. **OS Detection**: Compile-time and runtime OS/architecture detection
5. **Method Selection**: Chooses best installation method (native PM → xpm → any)

### Native Package Managers Supported

- **apt** (Debian/Ubuntu)
- **pacman** (Arch Linux, with AUR via paru/yay)
- **dnf** (Fedora/RHEL)
- **zypper** (openSUSE)
- **brew** (macOS/Linux)
- **swupd** (Clear Linux)
- **snap** (Universal)
- **flatpak** (Universal)
- **termux/pkg** (Android)
- **choco/scoop** (Windows)

### Package Installer Scripts

XPM uses bash scripts for package installation following the [xpm spec](https://github.com/verseles/xpm-popular).

Required function: `validate()`
Optional functions: `install_any()`, `remove_any()`, `install_apt()`, `remove_apt()`, etc.

### Environment Variables Injected to Scripts

| Variable | Description |
|----------|-------------|
| `XPM` | Path to xpm executable |
| `xSUDO` | Path to sudo (empty on Android) |
| `xCHANNEL` | stable/beta/nightly |
| `xOS` | linux/macos/windows/android |
| `xARCH` | Normalized architecture |
| `xBIN` | Binary install directory |
| `xHOME` | Home directory |
| `xTMP` | Temp directory |
| `xFLAGS` | Custom flags from --flags/-e |
| `isLinux`, `isMacOS`, `isWindows`, `isAndroid` | Boolean flags |
| `hasSnap`, `hasFlatpak` | Package manager availability |

## Important Files

- **`Cargo.toml`**: Workspace and dependencies
- **`.github/workflows/global.yml`**: CI/CD pipeline (test, build, release)
- **`docker/podman-compose.yml`**: Container test orchestration

## Code Style

- Rust 2021 edition
- Formatted with `cargo fmt`
- Linted with `cargo clippy`

## Testing Strategy

- Unit tests via `cargo test`
- Container-based integration testing via `make test-*`
- CI runs on Linux and macOS (x86_64 + aarch64)

## Build System

- **Cargo**: Rust build system
- **Make**: Common task automation
- **GitHub Actions**: CI/CD with cross-platform releases

## Notable Features

1. **Fallback Mechanism**: native PM → xpm method → generic "any" method
2. **Multiple PM Support**: 10+ package managers
3. **Architecture Mapping**: Normalizes arch names (amd64, x64, m1, m2, m3 → standard)
4. **Channel Support**: stable, beta, nightly
5. **Non-interactive**: Designed for automation
6. **Native mode**: `--native/-n` forces native PM only
7. **Custom flags**: `--flags/-e` passes flags to scripts

## Dependencies

Key dependencies:
- `clap`: CLI parsing
- `tokio`: Async runtime
- `native_db`: Embedded database
- `git2`: Git operations
- `reqwest`: HTTP client
- `anyhow`: Error handling
- `colored`: Terminal colors

## Release Process

Releases are automatically built via GitHub Actions when a tag matching `v*.*.*` is pushed. Binaries are created for:
- Linux x86_64
- Linux aarch64
- macOS x86_64
- macOS aarch64 (Apple Silicon)
