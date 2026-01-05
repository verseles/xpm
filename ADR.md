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
