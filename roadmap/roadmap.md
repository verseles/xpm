---
feature: "XPM Dart-to-Rust Migration"
spec: |
  Complete the migration of XPM from Dart to Rust, achieving full feature parity. The Rust implementation must support all native package managers, provide identical environment variables to bash scripts, pass the same test suite, and build for all target platforms. Success criteria: all existing xpm-popular packages install correctly on all supported distros.
---

## Task List

### Feature 1: Critical: Script Environment Variables
Description: Restore all 13 environment variables that Dart injects into bash scripts. Without these, existing packages will fail to install.
- [x] 1.01 Add XPM variable (path to xpm executable) to script execution context
- [x] 1.02 Add xOS variable (linux/macos/windows/android) to script context
- [x] 1.03 Add OS boolean flags (isWindows, isLinux, isMacOS, isAndroid) to script context
- [x] 1.04 Add xARCH variable (architecture string) to script context
- [x] 1.05 Add xBIN variable (bin directory path) to script context
- [x] 1.06 Add xHOME variable (user home directory) to script context
- [x] 1.07 Add xTMP variable (temp directory for downloads) to script context
- [x] 1.08 Add hasSnap and hasFlatpak boolean flags to script context
- [x] 1.09 Update install.rs build_install_script() to inject all variables before sourcing package script

### Feature 2: Critical: Native Package Manager Support
Description: Implement missing native package managers. Currently only APT and Pacman are supported; need 8 more for full parity.
- [x] 2.01 Implement DNF package manager (Fedora/RHEL) in native_pm/dnf.rs
- [x] 2.02 Implement Zypper package manager (openSUSE) in native_pm/zypper.rs
- [x] 2.03 Implement Homebrew package manager (macOS) in native_pm/brew.rs
- [x] 2.04 Implement swupd package manager (Clear Linux) in native_pm/swupd.rs
- [ ] 2.05 Implement pkg/Termux package manager (Android) in native_pm/termux.rs
- [ ] 2.06 Implement Snap package manager support in native_pm/snap.rs
- [ ] 2.07 Implement Flatpak package manager support in native_pm/flatpak.rs
- [ ] 2.08 Implement Chocolatey/Scoop package managers (Windows) in native_pm/choco.rs
- [x] 2.09 Update detector.rs to detect all new package managers

### Feature 3: High: Architecture Mapping
Description: Add missing architecture mappings, especially for Apple Silicon Macs which are currently unsupported.
- [x] 3.01 Add m1, m2, m3 -> arm64 mappings for Apple Silicon detection
- [x] 3.02 Add apple -> arm64 mapping for generic Apple detection
- [x] 3.03 Add armv6l -> arm mapping for older ARM devices
- [x] 3.04 Add armv8, arm64v8 -> arm64 mappings
- [x] 3.05 Add ppc64el -> ppc64 mapping (alternative naming)
- [x] 3.06 Normalize s390x -> s390 to match Dart behavior

### Feature 4: High: Missing CLI Flags
Description: Restore CLI flags that were present in Dart but missing in Rust implementation.
- [x] 4.01 Add --force-method flag to install command (bypasses auto-detection)
- [x] 4.02 Add --flags/-e multi-option to install command (passes custom flags to scripts)
- [x] 4.03 Add --native/-n flag to install command with auto/only/off modes
- [x] 4.04 Add --user-agent/-u option to get command
- [x] 4.05 Add --no-user-agent flag to get command
- [x] 4.06 Add --name/-n option to get command (output filename without path)
- [x] 4.07 Add --exec/-x flag to get command (make downloaded file executable)
- [x] 4.08 Add --bin/-b flag to get command (install to system bin)
- [x] 4.09 Add --no-progress flag to get command
- [x] 4.10 Add hash verification flags (--md5, --sha224, --sha384, --sha512-224, --sha512-256) to get command

### Feature 5: High: Implement Stub Commands
Description: Complete the upgrade and make commands which are currently empty stubs.
- [x] 5.01 Implement upgrade command: fetch all installed packages from DB
- [x] 5.02 Implement upgrade command: compare installed versions with repo versions using semver
- [x] 5.03 Implement upgrade command: display upgradable packages and prompt for confirmation
- [x] 5.04 Implement upgrade command: run install for each package needing upgrade
- [x] 5.05 Implement make command: interactive package script generator
- [x] 5.06 Implement make command: validate generated script structure

### Feature 6: Medium: Database Indexes
Description: Add missing database indexes for search performance. Dart has 8 indexes; Rust has only 2.
- [ ] 6.01 Add secondary index on Package.desc field for description search
- [ ] 6.02 Add secondary index on Package.title field for title search
- [ ] 6.03 Add secondary index on Package.arch field for architecture filtering
- [ ] 6.04 Add secondary index on Package.methods field for method filtering
- [x] 6.05 Add secondary index on Package.slug field for slug queries
- [x] 6.06 Add secondary index on Package.installed_at field for installed package queries

### Feature 7: Critical: Test Suite Migration
Description: Recreate the comprehensive test suite from Dart. Currently almost no tests exist in Rust.
- [ ] 7.01 Create tests/bin_folder_test.rs - test bin directory operations
- [x] 7.02 Create tests/checksum_test.rs - test all hash algorithms (exists in utils/checksum.rs)
- [x] 7.03 Create tests/executable_test.rs - test executable detection (exists in os/executable.rs)
- [x] 7.04 Create tests/architecture_test.rs - test all arch mappings including edge cases (exists in os/arch.rs)
- [ ] 7.05 Create tests/logger_test.rs - test logging output formats
- [x] 7.06 Create tests/pacman_test.rs - test Pacman/AUR integration (exists in native_pm/pacman.rs)
- [x] 7.07 Create tests/script_test.rs - test bash script parsing and execution (exists in script/mod.rs)
- [ ] 7.08 Create tests/shortcut_test.rs - test desktop shortcut creation
- [ ] 7.09 Create tests/database_test.rs - test CRUD operations and queries
- [ ] 7.10 Create tests/integration_test.rs - end-to-end install/remove flow

### Feature 8: Critical: Docker Testing Infrastructure
Description: Restore Docker-based multi-distro testing. Essential for validating cross-platform compatibility.
- [x] 8.01 Create docker/Dockerfile.ubuntu with Rust toolchain and test dependencies
- [ ] 8.02 Create docker/fedora/Dockerfile for DNF testing
- [x] 8.03 Create docker/Dockerfile.arch for Pacman/AUR testing
- [ ] 8.04 Create docker/opensuse/Dockerfile for Zypper testing
- [ ] 8.05 Create docker/clearlinux/Dockerfile for swupd testing
- [ ] 8.06 Create docker/brew/Dockerfile for Homebrew testing (linuxbrew)
- [ ] 8.07 Create docker/android/Dockerfile for Termux testing
- [x] 8.08 Update Makefile with docker-test and test-ubuntu/arch targets
- [x] 8.09 Create podman-compose.yml for container orchestration

### Feature 9: High: CI/CD Pipeline
Description: Expand GitHub Actions to match Dart's multi-platform builds and release automation.
- [ ] 9.01 Add macOS build target to CI workflow (x86_64 and aarch64)
- [ ] 9.02 Add Windows build target to CI workflow (optional, experimental)
- [ ] 9.03 Add cross-compilation for ARM64 Linux
- [ ] 9.04 Create release workflow triggered by version tags (v*.*.*)
- [ ] 9.05 Add artifact upload step to create gzipped binaries for each platform
- [ ] 9.06 Add Docker-based validation step in CI (run validate-all)

### Feature 10: Low: Version Checking
Description: Implement auto-update notification system that checks for new XPM versions periodically.
- [ ] 10.01 Create version_checker module in xpm-core
- [ ] 10.02 Implement GitHub API call to check latest release version
- [ ] 10.03 Store last check timestamp in Setting/KV with 4-day expiration
- [ ] 10.04 Display update notification on CLI startup if new version available
