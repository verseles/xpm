# Architecture Decision Records

## ADR-001: Inverted Display Order for Terminal UX

**Date:** 2025-01-05  
**Status:** Accepted  
**Context:** Search results display order in CLI

### Problem

When users run `xpm search <term>`, they see results from multiple sources (XPM, Native PM, AUR). The question: in what order should these be displayed?

Traditional GUI approach would show "most relevant first" at the top. However, CLI users interact differently with terminals.

### Decision

Display search results in **inverted relevance order**:

```
━━━ AUR Packages ━━━        ← TOP (least relevant, scrolls away)
  package-git (⭐ 12)
  package-nightly (⭐ 89)
  package-bin (⭐ 320)       ← most voted at section bottom

━━━ Native Packages ━━━     ← MIDDLE
  package [extra]

━━━ XPM Packages ━━━        ← BOTTOM (most relevant, near prompt)
  package 1.0 [installed]
$ _                          ← user prompt here
```

Within each section, items are also sorted ascending (most relevant/voted at bottom).

### Rationale

1. **Terminal reading pattern**: Users read from the prompt upward. The last thing printed is the first thing seen.

2. **Cognitive load**: After a search, the user's eye is at the prompt. Most relevant results should be immediately visible without scrolling.

3. **Section priority**: XPM packages (curated scripts) > Native (official repos) > AUR (user-contributed). Most trusted sources appear closest to where the user will type.

4. **AUR votes ascending**: Within AUR, most-voted packages appear at the bottom of the section, making them the last AUR items seen before Native packages.

### Implementation

- `search.rs`: Controls section display order and XPM relevance scoring
- `NativePackageManager::results_pre_sorted()`: Trait method indicating if PM pre-sorts results
- `PacmanPackageManager`: Sorts AUR by votes ascending, official by name

### Consequences

**Positive:**
- Optimal UX for CLI power users
- Most relevant results require zero scrolling
- Consistent with `ls`, `git log`, and other CLI tools

**Negative:**
- Counter-intuitive for users expecting "best first" at top
- Different from web search engines and GUI package managers

### Alternatives Considered

1. **Traditional top-down**: Rejected. Requires scrolling up to see best results.
2. **No sorting**: Rejected. Random order is confusing.
3. **User-configurable**: Deferred. Adds complexity, can be added later if needed.

---

## ADR-002: Dart to Rust Migration

**Date:** 2024-12-01  
**Status:** Accepted (Completed 2025-01-05)  
**Context:** Complete rewrite of xpm from Dart to Rust

### Problem

The original xpm was written in Dart. While functional, it faced several challenges:

1. **Binary size**: Dart AOT binaries are large (~15-20MB)
2. **Startup time**: Dart runtime initialization adds latency
3. **Distribution**: Requires bundling Dart runtime or AOT compilation per platform
4. **System integration**: FFI to native libraries is cumbersome in Dart
5. **Community expectations**: Package managers are traditionally written in C, Rust, or Go

### Decision

Rewrite xpm entirely in Rust, organized as a workspace with two crates:

```
xpm/
├── Cargo.toml              # Workspace
├── crates/
│   ├── xpm-core/           # Library: DB, OS abstraction, PM integrations
│   └── xpm-cli/            # Binary: CLI interface using clap
```

### Rationale

1. **Binary size**: Rust produces ~3MB static binaries (vs ~15MB Dart)
2. **Performance**: Zero-cost abstractions, no runtime overhead
3. **Single binary**: Static linking, no external dependencies
4. **System integration**: Native FFI, excellent C interop
5. **Safety**: Memory safety without garbage collection
6. **Ecosystem**: cargo, crates.io, excellent tooling

### Implementation

| Component | Dart (Before) | Rust (After) |
|-----------|---------------|--------------|
| CLI parsing | `args` package | `clap` with derive |
| Database | JSON files | `native_db` (redb backend) |
| HTTP | `http` package | `reqwest` with rustls |
| Git | Shell commands | `git2` (libgit2 bindings) |
| Async | Dart isolates | `tokio` runtime |

### Migration Strategy

1. Preserve Dart implementation in `old_dart` branch
2. Implement core library first (Phase 1-2)
3. Implement CLI commands (Phase 3)
4. Add tests and infrastructure (Phase 4-5)
5. Feature parity verification (Phase 6-7)
6. UX refinements (Phase 8)

### Consequences

**Positive:**
- 5x smaller binary size
- Faster startup and execution
- Single static binary distribution
- Better cross-compilation support
- Type-safe codebase with excellent tooling

**Negative:**
- Complete rewrite effort (~2 months)
- Learning curve for contributors familiar with Dart
- Lost some Dart-specific conveniences (null safety syntax, async/await simplicity)

### Alternatives Considered

1. **Keep Dart**: Rejected. Binary size and distribution issues.
2. **Go rewrite**: Considered. Rust chosen for better performance and safety.
3. **C rewrite**: Rejected. Development velocity too slow.
4. **Gradual migration**: Rejected. FFI bridge complexity not worth it.

---

## ADR-003: Native Package Manager Integration

**Date:** 2024-12-15  
**Status:** Accepted  
**Context:** Integrating with system package managers alongside XPM scripts

### Problem

XPM's original design used bash scripts for all installations. However:

1. Users expect to find packages from their native PM (apt, pacman, brew)
2. Native packages receive security updates automatically
3. Some software is only available via native PMs
4. Duplicating native PM functionality in scripts is wasteful

### Decision

Implement a **hybrid search and install** system:

```
┌─────────────────────────────────────────────────────────┐
│                      xpm search                         │
├─────────────────────────────────────────────────────────┤
│  XPM Scripts    │  Native PM     │  AUR (Arch only)    │
│  (curated)      │  (official)    │  (community)        │
└─────────────────────────────────────────────────────────┘
                           │
                           ▼
┌─────────────────────────────────────────────────────────┐
│                    xpm install                          │
├─────────────────────────────────────────────────────────┤
│  1. Try XPM script (if exists and preferred)           │
│  2. Fallback to native PM                               │
│  3. Fallback to "any" method in script                  │
└─────────────────────────────────────────────────────────┘
```

### Architecture

```rust
#[async_trait]
pub trait NativePackageManager: Send + Sync {
    fn name(&self) -> &str;
    async fn search(&self, query: &str, limit: Option<usize>) -> Result<Vec<NativePackage>>;
    async fn install(&self, name: &str) -> Result<()>;
    async fn remove(&self, name: &str) -> Result<()>;
    async fn is_installed(&self, name: &str) -> Result<bool>;
    async fn get(&self, name: &str) -> Result<Option<NativePackage>>;
    async fn update_db(&self) -> Result<()>;
    fn results_pre_sorted(&self) -> bool { false }
}
```

### Supported Package Managers

| PM | OS | Detection | Notes |
|----|-----|-----------|-------|
| APT | Debian/Ubuntu | `/usr/bin/apt` | Full search integration |
| Pacman | Arch Linux | `/usr/bin/pacman` | With AUR helper support |
| DNF | Fedora/RHEL | `/usr/bin/dnf` | Script-based |
| Zypper | openSUSE | `/usr/bin/zypper` | Script-based |
| Brew | macOS/Linux | `brew` in PATH | Script-based |
| Swupd | Clear Linux | `/usr/bin/swupd` | Script-based |
| Snap | Universal | `/usr/bin/snap` | Script-based |
| Flatpak | Universal | `/usr/bin/flatpak` | Script-based |

### AUR Helper Priority

For Arch Linux, xpm detects and uses AUR helpers in this order:

```
Paru → Yay → Pacman (fallback)
```

**Rationale:**
- **Paru**: Written in Rust, actively maintained, best UX
- **Yay**: Popular Go-based helper, widely installed
- **Pacman**: Always available, but no AUR access

### Consequences

**Positive:**
- Users find packages from all sources in one search
- Native packages get system updates automatically
- Reduced maintenance of XPM scripts for common packages
- Better Arch Linux experience with AUR integration

**Negative:**
- Increased complexity in search/install logic
- Different output formats per PM require parsing
- PM-specific quirks (apt needs sudo, paru doesn't)
- Testing requires multiple OS environments

### Alternatives Considered

1. **XPM scripts only**: Rejected. Too much duplication, no native PM updates.
2. **Native PM only**: Rejected. Loses XPM's cross-platform scripts.
3. **Separate commands**: Rejected. `xpm search-native` vs `xpm search` is confusing.
4. **PackageKit integration**: Considered. Too heavyweight, not available everywhere.
