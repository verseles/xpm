# XPM - Dart to Rust Conversion Roadmap

> **Objective**: Convert XPM CLI from Dart to Rust with improved performance, better UX, and modern architecture.

## Phase 1: Project Setup & Cleanup

- [ ] Remove all Dart source files
- [ ] Remove Dart configuration files (pubspec.yaml, analysis_options.yaml, etc.)
- [ ] Remove Dart-specific directories (.dart_tool, build, etc.)
- [ ] Create Cargo workspace structure
- [ ] Setup xpm-core crate
- [ ] Setup xpm-cli crate
- [ ] Configure workspace dependencies
- [ ] Create .gitignore for Rust

## Phase 2: Core Library (xpm-core)

### 2.1 Database Layer
- [ ] Setup native_db with redb backend
- [ ] Define Package model with indexes
- [ ] Define Repo model with indexes
- [ ] Define KV (settings) model with expiration
- [ ] Implement database initialization
- [ ] Implement database migrations support

### 2.2 OS Abstraction
- [ ] Implement OS detection (Linux, macOS, Windows)
- [ ] Implement architecture detection (x86_64, aarch64, etc.)
- [ ] Implement executable finder (which equivalent)
- [ ] Implement XDG directory support
- [ ] Implement bin directory detection
- [ ] Implement file operations (copy, move, delete, chmod)

### 2.3 Script Parsing
- [ ] Implement bash script reader
- [ ] Implement variable extraction (readonly pattern)
- [ ] Implement array extraction
- [ ] Implement function detection
- [ ] Implement script content caching

### 2.4 Native Package Managers
- [ ] Define NativePackageManager trait
- [ ] Implement APT package manager
- [ ] Implement Pacman package manager (with Paru/Yay support)
- [ ] Implement AUR search and parsing
- [ ] Implement popularity sorting for AUR

### 2.5 Utilities
- [ ] Implement logger with colors (owo-colors)
- [ ] Implement checksum verification (MD5, SHA1, SHA256, SHA512, etc.)
- [ ] Implement JSON serialization helpers
- [ ] Implement slugify for URLs
- [ ] Implement version checker (GitHub releases)
- [ ] Implement output formatter with color codes

### 2.6 Repository Management
- [ ] Implement git clone/pull operations (git2)
- [ ] Implement repository indexing
- [ ] Implement package script discovery
- [ ] Implement base.bash loading

### 2.7 Settings System
- [ ] Implement key-value storage with expiration
- [ ] Implement in-memory caching
- [ ] Implement lazy writes
- [ ] Implement expired settings cleanup

## Phase 3: CLI Application (xpm-cli)

### 3.1 CLI Framework
- [ ] Setup clap with derive API
- [ ] Configure global flags (--version, --verbose)
- [ ] Setup subcommand structure
- [ ] Implement custom error handling
- [ ] Implement graceful exit

### 3.2 Human Commands
- [ ] Implement `search` command with native PM integration
- [ ] Implement `install` command with method selection
- [ ] Implement `remove` command
- [ ] Implement `refresh` command
- [ ] Implement `upgrade` command (stub)

### 3.3 Developer Commands
- [ ] Implement `get` command (download with progress)
- [ ] Implement `file` command group (copy, move, delete, exec, bin, unbin)
- [ ] Implement `repo` command group (add, remove, list)
- [ ] Implement `checksum` command
- [ ] Implement `shortcut` command
- [ ] Implement `log` command
- [ ] Implement `check` command
- [ ] Implement `make` command (stub)

### 3.4 Installation Preparation
- [ ] Implement method detection (apt, pacman, dnf, etc.)
- [ ] Implement method fallback logic
- [ ] Implement script generation with environment variables
- [ ] Implement channel selection
- [ ] Implement validation execution

## Phase 4: Optimizations

### 4.1 Performance
- [ ] Implement parallel downloads
- [ ] Implement connection pooling (reqwest Client reuse)
- [ ] Implement aggressive caching
- [ ] Implement lazy database loading
- [ ] Optimize startup time

### 4.2 UX Improvements
- [ ] Add spinners for long operations
- [ ] Add multi-progress bars for parallel ops
- [ ] Improve error messages with suggestions
- [ ] Add --quiet mode
- [ ] Add --json output mode for scripting

## Phase 5: Testing

### 5.1 Unit Tests
- [ ] Test database operations
- [ ] Test settings with expiration
- [ ] Test executable detection
- [ ] Test checksum verification
- [ ] Test bash script parsing
- [ ] Test OS/arch detection
- [ ] Test slugify
- [ ] Test version comparison
- [ ] Test file operations

### 5.2 Integration Tests
- [ ] Test search command
- [ ] Test install flow (with mock)
- [ ] Test remove flow (with mock)
- [ ] Test refresh command
- [ ] Test get command
- [ ] Test repo management
- [ ] Test native PM detection

### 5.3 Cross-Platform Tests
- [ ] Verify Linux x86_64 build
- [ ] Verify Linux aarch64 build
- [ ] Verify macOS x86_64 build
- [ ] Verify macOS aarch64 build
- [ ] Verify Windows x86_64 build

## Phase 6: CI/CD

### 6.1 GitHub Actions
- [ ] Setup Rust toolchain
- [ ] Configure cargo fmt check
- [ ] Configure cargo clippy
- [ ] Configure cargo test
- [ ] Setup cross-compilation matrix
- [ ] Configure artifact upload (7 days retention)
- [ ] Configure release on semver tags
- [ ] Add caching for faster builds

### 6.2 Release Automation
- [ ] Generate binaries for all platforms
- [ ] Create checksums for releases
- [ ] Update installer.bash for Rust binary
- [ ] Add CHANGELOG generation

## Phase 7: Documentation

- [ ] Update README.md
- [ ] Add CONTRIBUTING.md
- [ ] Add inline documentation
- [ ] Add examples

## Progress Tracking

| Phase | Status | Progress |
|-------|--------|----------|
| Phase 1: Setup | 🔄 In Progress | 0/8 |
| Phase 2: Core | ⏳ Pending | 0/31 |
| Phase 3: CLI | ⏳ Pending | 0/18 |
| Phase 4: Optimizations | ⏳ Pending | 0/9 |
| Phase 5: Testing | ⏳ Pending | 0/17 |
| Phase 6: CI/CD | ⏳ Pending | 0/9 |
| Phase 7: Docs | ⏳ Pending | 0/4 |

**Total: 0/96 tasks completed**

---

## Technical Decisions

### Dependencies (Cargo.toml)

```toml
# Workspace dependencies
[workspace.dependencies]
tokio = { version = "1", features = ["full"] }
clap = { version = "4", features = ["derive", "env"] }
reqwest = { version = "0.12", features = ["json", "stream"] }
native_db = "0.8"
native_model = "0.4"
git2 = "0.19"
serde = { version = "1", features = ["derive"] }
serde_json = "1"
dirs = "5"
owo-colors = "4"
indicatif = "0.17"
sha2 = "0.10"
md5 = "0.7"
semver = "1"
thiserror = "2"
anyhow = "1"
tracing = "0.1"
tracing-subscriber = "0.3"
regex = "1"
slug = "0.1"
futures = "0.3"
```

### Directory Structure (XDG Compliant)

| Purpose | Path |
|---------|------|
| Config | `~/.config/xpm/` |
| Data | `~/.local/share/xpm/` |
| Cache | `~/.cache/xpm/` |
| Database | `~/.local/share/xpm/db/` |
| Repos | `~/.local/share/xpm/repos/` |

### Compatibility

- Maintains full compatibility with xpm-popular repository scripts
- Same CLI commands and flags as Dart version
- Improved UX with better progress indicators and error messages
