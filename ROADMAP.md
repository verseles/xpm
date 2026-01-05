# XPM - Dart to Rust Migration Roadmap

> **Status**: ✅ **COMPLETE** - All phases implemented successfully.

## Phase 1: Feature Parity (Script Environment) ✅
Restore all environment variables injected into bash scripts to ensure compatibility with existing xpm-popular packages.

- [x] **1.01 Critical: Environment Variables**
  - [x] Add `xSUDO` (path to sudo)
  - [x] Add `xCHANNEL` (selected installation channel)
  - [x] Add `hasSnap` and `hasFlatpak` boolean flags
  - [x] Add `xFLAGS` (custom flags from --flags/-e)
  - [x] Verify `XPM`, `xOS`, `isWindows/isLinux/isMacOS/isAndroid`, `xARCH`, `xBIN`, `xHOME`, `xTMP` are correctly injected
- [x] **1.02 High: Architecture Mapping**
  - [x] All aliases supported: `amd64`, `x64`, `i686`, `i386`, `armv7`, `m1`, `m2`, `m3`, `apple`, `armv8`, `arm64v8`, `armv6l`, `ppc64le`, `ppc64el`, `s390x`, `riscv64`

## Phase 2: Native Package Managers ✅
Complete the implementation of native package managers supported in the original logic.

- [x] **2.01 Critical: Missing Managers**
  - [x] Implement Termux (`pkg`) support
  - [x] Implement Snap support
  - [x] Implement Flatpak support
  - [x] Implement Chocolatey/Scoop (Windows) support
- [x] **2.02 High: Method Fallback**
  - [x] Refine the fallback logic: `native` -> `xpm` -> `any`
  - [x] Support `--native/-n` mode (skip xpm scripts, use native PM only)
  - [x] AppImage support via script methods

## Phase 3: CLI & Command Polish ✅
Restore missing flags and complete stubbed commands.

- [x] **3.01 High: CLI Flags**
  - [x] `install`: Restore `--native/-n` mode support
  - [x] `install`: Restore `--flags/-e` for custom script flags (exported as `xFLAGS`)
  - [x] `get`: All hash verification flags available (`--md5`, `--sha1`, `--sha256`, `--sha512`)
- [x] **3.02 Medium: Implement Stubs**
  - [x] Implement `upgrade` command logic (version comparison)
  - [x] Implement `make` command (script template generator)

## Phase 4: Database Optimization ✅
Ensure search performance matches the original Isar-based implementation.

- [x] **4.01 High: Secondary Indexes**
  - [x] Add index for `Package.desc` (case-insensitive via `desc_lower`)
  - [x] Add index for `Package.title` (case-insensitive via `title_lower`)
  - [x] Existing indexes: `name`, `installed`, `method`, `channel`, `repo_id`

## Phase 5: Testing & Infrastructure ✅
Restore the comprehensive testing suite and cross-platform validation.

- [x] **5.01 Critical: Test Suite**
  - [x] 11 tests passing (arch, checksum, flatpak, snap, termux, choco, scoop parsing)
- [x] **5.02 High: Docker Infrastructure**
  - [x] Ubuntu Dockerfile
  - [x] Arch Linux Dockerfile
  - [x] Fedora Dockerfile
  - [x] openSUSE Dockerfile
  - [x] Clear Linux Dockerfile
  - [x] Homebrew (Linux) Dockerfile

## Phase 6: Documentation & Cleanup ✅
Final polish and removal of legacy Dart artifacts.

- [x] **6.01 Cleanup**
  - [x] Remove `dev.dart`
  - [x] Update `AGENTS.md` (converted to Rust)
  - [x] Update CI/CD workflow
- [x] **6.02 CI/CD**
  - [x] Linux x86_64 and aarch64 builds
  - [x] macOS x86_64 and aarch64 builds
  - [x] Automated releases on tag push
