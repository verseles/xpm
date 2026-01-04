# xpm - uniX Package Manager

[![CI](https://github.com/verseles/xpm/actions/workflows/ci.yml/badge.svg)](https://github.com/verseles/xpm/actions/workflows/ci.yml)

A universal package manager for any unix-like distro including macOS. Rewritten in **Rust** for maximum performance and portability.

## What is xpm?

XPM is a package manager for unix systems like Linux, BSD, MacOS, etc. It can be a wrapper for native package managers or a package manager itself by using its way of installing packages. For the list of packages available, see [xpm-popular](https://github.com/verseles/xpm-popular).

### Our key values

- Easy to install, update, upgrade, remove, search (and filter)
- No questions asked, can run in a non-interactive way
- Easy to create new installers or a full repository
- Be agnostic, following unix standards and relying on very known tools
- Include many popular distros, including macOS and Android (termux)
- Prefer native pm way and falls back to xpm way

## Features

- **Universal**: Works on Linux (Arch, Debian, Ubuntu, Fedora, openSUSE), macOS, and Android/Termux
- **Fast**: Built with Rust for maximum performance (~3MB static binary)
- **Unified**: Search and install packages from XPM repositories AND native package managers
- **AUR Support**: Full AUR helper support (paru, yay) on Arch Linux
- **Offline-first**: Local database with cached package metadata
- **Script-based packages**: Simple bash scripts for package installation

## Supported Operating Systems & Package Managers

### 🎯 **Integrated Support** (Native PM with formatted search)
- **Debian/Ubuntu** & derivatives → **APT**
- **Arch Linux** → **Pacman** (with AUR support via **Paru** and **Yay**)

These systems get full native package manager integration with intelligent search, metadata extraction, and clean formatted output.

### 📜 **Script-Based Support** (via installers)
For other systems, XPM provides script-based installation through the [xpm-popular](https://github.com/verseles/xpm-popular) repository:

**Linux Distributions:**
- **Fedora** → DNF
- **openSUSE** → Zypper
- **Clear Linux** → swupd
- **Android (Termux)** → pkg
- **Alpine Linux** → via custom scripts

**macOS** → Homebrew (brew) - via scripts

## Installation

### From Source

```bash
# Clone the repository
git clone https://github.com/verseles/xpm.git
cd xpm

# Build
cargo build --release

# Install to /usr/local/bin
sudo cp target/release/xpm /usr/local/bin/
```

### From Cargo

```bash
cargo install --git https://github.com/verseles/xpm.git
```

## Quick Start

```bash
# Check your system
xpm check

# Add the default repository (pulls from xpm-popular)
xpm refresh

# Search for packages (searches XPM + native PM)
xpm search neovim

# Install a package
xpm install neovim

# Remove a package
xpm remove neovim
```

## Commands

| Command | Alias | Description |
|---------|-------|-------------|
| `search` | `s` | Search for packages (XPM + native PM) |
| `install` | `i` | Install a package |
| `remove` | `rm` | Remove a package |
| `refresh` | - | Refresh package database |
| `upgrade` | - | Upgrade installed packages (coming soon) |
| `get` | - | Download a file |
| `file` | - | File operations (copy, move, delete, bin) |
| `repo` | - | Repository management |
| `checksum` | `hash` | Compute file checksums |
| `shortcut` | - | Create desktop shortcuts |
| `log` | - | Show installed packages |
| `check` | - | Check system configuration |
| `make` | - | Create a package (coming soon) |

### Search Examples

```bash
# Basic search
xpm search vim

# Multiple terms
xpm search text editor

# Limit results
xpm search rust --limit 10

# JSON output (for scripts)
xpm search go --json
```

## Architecture

XPM is built as a Rust workspace with two crates:

- **xpm-core**: Core library with database, OS abstraction, and package management
- **xpm-cli**: Command-line interface

### Key Components

- **Native DB**: Fast, embedded database using native_db (redb backend)
- **Async I/O**: Full async support with Tokio
- **Git integration**: Uses git2 for repository management
- **Native PM integration**: Seamless integration with apt, pacman, paru, yay

## Creating Packages

Packages are bash scripts with metadata headers:

```bash
#!/bin/bash
readonly xNAME="my-package"
readonly xVERSION="1.0.0"
readonly xTITLE="My Package"
readonly xDESC="Description of my package"
readonly xURL="https://example.com"

xARCHS=(x86_64 aarch64)
xDEFAULT=(any)

install_any() {
    # Installation logic
    echo "Installing..."
}

remove_any() {
    # Removal logic
    echo "Removing..."
}

validate() {
    # Validation - return 0 if installed correctly
    which my-package >/dev/null
}
```

Save as `my-package/my-package.bash` in your repository.

## Repository Structure

```
my-xpm-repo/
├── package1/
│   └── package1.bash
├── package2/
│   └── package2.bash
└── ...
```

## Building from Source

```bash
# Development build
cargo build

# Release build (optimized)
cargo build --release

# Run tests
cargo test

# Run with verbose output
cargo run -- --verbose check

# Pre-commit checks (format + lint + test)
make precommit
```

## Container Testing

Test xpm on different distributions using Podman:

```bash
# Build and test on Ubuntu
make test-ubuntu

# Build and test on Arch Linux
make test-arch

# Build and test all distros
make docker-test

# Clean container images
make docker-clean
```

## Contributing

Contributions are welcome! Please:

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Run `cargo test` and `cargo clippy`
5. Submit a pull request

## License

BSD-4-Clause

## Credits

Built with ❤️ by [Verseles](https://verseles.com)
