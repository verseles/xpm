# XPM - Roadmap

> **Status**: Integration Testing Phase
>
> **Note**: Dart→Rust migration completed in v0.87.0. Now validating across distributions.

## Phase 9: Integration Testing via Podman

Validate xpm works correctly on each supported distribution.

### 9.01 Rebuild Container Images
- [ ] **9.01.1** Clean old cached images (`podman image prune -a`)
- [ ] **9.01.2** Rebuild Ubuntu image (`make docker-ubuntu`)
- [ ] **9.01.3** Rebuild Arch image (`make docker-arch`)
- [ ] **9.01.4** Rebuild Fedora image (`make docker-fedora`)
- [ ] **9.01.5** Rebuild openSUSE image (`make docker-opensuse`)
- [ ] **9.01.6** Rebuild Clear Linux image (`make docker-clearlinux`)
- [ ] **9.01.7** Rebuild Homebrew image (`make docker-homebrew`)

### 9.02 Test Basic Commands
- [ ] **9.02.1** Ubuntu: `xpm --version`, `xpm check`, `xpm refresh`
- [ ] **9.02.2** Arch: `xpm --version`, `xpm check`, `xpm refresh`
- [ ] **9.02.3** Fedora: `xpm --version`, `xpm check`, `xpm refresh`
- [ ] **9.02.4** openSUSE: `xpm --version`, `xpm check`, `xpm refresh`
- [ ] **9.02.5** Clear Linux: `xpm --version`, `xpm check`, `xpm refresh`
- [ ] **9.02.6** Homebrew: `xpm --version`, `xpm check`, `xpm refresh`

### 9.03 Test Search (Native PM Integration)
- [ ] **9.03.1** Ubuntu: `xpm search neovim` (APT integration)
- [ ] **9.03.2** Arch: `xpm search neovim` (Pacman + AUR integration)
- [ ] **9.03.3** Fedora: `xpm search neovim` (DNF integration)
- [ ] **9.03.4** openSUSE: `xpm search neovim` (Zypper integration)

### 9.04 Test Install/Remove (if applicable)
- [ ] **9.04.1** Ubuntu: Install and remove a package
- [ ] **9.04.2** Arch: Install and remove a package
- [ ] **9.04.3** Fedora: Install and remove a package

---

## Progress

| Task | Status | Notes |
|------|--------|-------|
| 9.01 Rebuild Images | pending | Blocked by disk space (resolved) |
| 9.02 Basic Commands | pending | |
| 9.03 Search Tests | pending | |
| 9.04 Install/Remove | pending | |
