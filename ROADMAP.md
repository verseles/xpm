# XPM - Dart to Rust Migration Roadmap

> **Status**: 🚧 **IN PROGRESS** - Completing feature parity with Dart version.

## Phase 1: Feature Parity (Script Environment)
Restore all environment variables injected into bash scripts to ensure compatibility with existing xpm-popular packages.

- [ ] **1.01 Critical: Environment Variables**
  - [ ] Add `xSUDO` (path to sudo)
  - [ ] Add `xCHANNEL` (selected installation channel)
  - [ ] Add `hasSnap` and `hasFlatpak` boolean flags
  - [ ] Verify `XPM`, `xOS`, `isWindows/isLinux/isMacOS/isAndroid`, `xARCH`, `xBIN`, `xHOME`, `xTMP` are correctly injected
- [ ] **1.02 High: Architecture Mapping**
  - [ ] Ensure all Dart aliases are supported: `amd64`, `x64`, `i686`, `i386`, `armv7`, `m1`, `m2`, `m3`, `apple`, `armv8`, `arm64v8`, `armv6l`, `ppc64le`, `ppc64el`, `s390x`

## Phase 2: Native Package Managers
Complete the implementation of native package managers supported in the original logic.

- [ ] **2.01 Critical: Missing Managers**
  - [ ] Implement Termux (`pkg`) support
  - [ ] Implement Snap support
  - [ ] Implement Flatpak support
  - [ ] Implement Chocolatey/Scoop (Windows) support
- [ ] **2.02 High: Method Fallback**
  - [ ] Refine the fallback logic: `native` -> `xpm` -> `any`
  - [ ] Support `AppImage` as a valid method/extension

## Phase 3: CLI & Command Polish
Restore missing flags and complete stubbed commands.

- [ ] **3.01 High: CLI Flags**
  - [ ] `install`: Restore `--native/-n` mode support (auto, only, off)
  - [ ] `install`: Restore `--flags/-e` multi-option for custom script flags
  - [ ] `get`: Restore hash verification flags (`--md5`, `--sha1`, `--sha224`, `--sha384`, `--sha512-224`, `--sha512-256`)
- [ ] **3.02 Medium: Implement Stubs**
  - [ ] Implement `upgrade` command logic (version comparison via semver)
  - [ ] Implement `make` command (interactive script generator)

## Phase 4: Database Optimization
Ensure search performance matches the original Isar-based implementation.

- [ ] **4.01 High: Secondary Indexes**
  - [ ] Add index for `Package.desc` (case-insensitive)
  - [ ] Add index for `Package.title` (case-insensitive)
  - [ ] Add index for `Package.arch`
  - [ ] Add index for `Package.methods`

## Phase 5: Testing & Infrastructure
Restore the comprehensive testing suite and cross-platform validation.

- [ ] **5.01 Critical: Test Suite Parity**
  - [ ] Restore `bin_folder_test`
  - [ ] Restore `delete_from_bin_test`
  - [ ] Restore `move_to_bin_test`
  - [ ] Restore `shortcut_test`
  - [ ] Restore `logger_test`
  - [ ] Restore `integration_test` (end-to-end)
- [ ] **5.02 High: Docker Infrastructure**
  - [ ] Restore Fedora Dockerfile
  - [ ] Restore openSUSE Dockerfile
  - [ ] Restore Clear Linux Dockerfile
  - [ ] Restore Homebrew/OSX Dockerfiles
  - [ ] Restore Termux Dockerfile

## Phase 6: Documentation & Cleanup
Final polish and removal of legacy Dart artifacts.

- [ ] **6.01 Cleanup**
  - [ ] Remove `dev.dart`
  - [ ] Update `AGENTS.md` (convert Dart-specific rules to Rust)
  - [ ] Update `CHANGELOG.md` with migration details
- [ ] **6.02 CI/CD**
  - [ ] Add macOS build targets (x86_64 and aarch64) to GitHub Actions
