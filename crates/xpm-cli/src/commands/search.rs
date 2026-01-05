//! Search command implementation

use anyhow::Result;
use owo_colors::OwoColorize;
use xpm_core::{
    db::{Database, Package},
    native_pm::{detect_native_pm, NativePackage, NativePackageManager},
    utils::logger::Logger,
};

/// Calculate relevance score for a package based on search terms
fn calculate_relevance(pkg: &Package, terms: &[String]) -> i32 {
    let name_lower = pkg.name.to_lowercase();
    let mut score = 0;

    for term in terms {
        let term_lower = term.to_lowercase();
        if name_lower == term_lower {
            score += 1000;
        } else if name_lower.starts_with(&term_lower) {
            score += 100;
        } else if name_lower.contains(&term_lower) {
            score += 30;
        }
        if let Some(title) = &pkg.title {
            if title.to_lowercase().contains(&term_lower) {
                score += 10;
            }
        }
    }
    score
}

/// Run the search command
pub async fn run(
    terms: &[String],
    limit: usize,
    exact: bool,
    all: bool,
    native_mode: &str,
    json: bool,
) -> Result<()> {
    if terms.is_empty() && !all {
        anyhow::bail!("No search terms provided. Use --all to list all packages.");
    }

    let db = Database::instance()?;

    let mut xpm_packages = if native_mode != "only" {
        if all {
            db.get_packages_limited(limit)?
        } else if exact {
            let mut results = Vec::new();
            for term in terms {
                if let Some(pkg) = db.find_package_by_name(term)? {
                    results.push(pkg);
                }
            }
            results
        } else {
            db.search_packages(terms, limit)?
        }
    } else {
        Vec::new()
    };

    // Sort XPM by relevance (ascending: most relevant at bottom)
    if !all && !exact && !terms.is_empty() {
        xpm_packages.sort_by_key(|pkg| calculate_relevance(pkg, terms));
    }

    let (native_packages, pm_pre_sorted) = if native_mode != "off" && !all {
        if let Some(pm) = detect_native_pm().await {
            if native_mode == "only" || xpm_packages.len() < 6 {
                let query = terms.join(" ");
                let packages = pm.search(&query, Some(limit)).await.unwrap_or_default();
                let pre_sorted = pm.results_pre_sorted();
                (packages, pre_sorted)
            } else {
                (Vec::new(), false)
            }
        } else {
            (Vec::new(), false)
        }
    } else {
        (Vec::new(), false)
    };

    if json {
        let result = serde_json::json!({
            "xpm": xpm_packages.iter().map(|p| {
                serde_json::json!({
                    "name": p.name,
                    "version": p.version,
                    "description": p.desc,
                    "installed": p.is_installed()
                })
            }).collect::<Vec<_>>(),
            "native": native_packages.iter().map(|p| {
                serde_json::json!({
                    "name": p.name,
                    "version": p.version,
                    "description": p.description,
                    "repo": p.repo,
                    "installed": p.installed
                })
            }).collect::<Vec<_>>()
        });
        println!("{}", serde_json::to_string_pretty(&result)?);
        return Ok(());
    }

    let has_results = !xpm_packages.is_empty() || !native_packages.is_empty();

    if !has_results {
        Logger::warning("No packages found");
        return Ok(());
    }

    let total = xpm_packages.len() + native_packages.len();
    println!("{}", format!("Found {} packages:", total).cyan().bold());
    println!();

    // Group native packages
    let mut official: Vec<_> = native_packages.iter().filter(|p| !p.is_aur()).collect();
    let mut aur: Vec<_> = native_packages.iter().filter(|p| p.is_aur()).collect();

    // Sort AUR by votes ascending (most voted at bottom, near prompt)
    aur.sort_by(|a, b| a.popularity.cmp(&b.popularity));

    // Invert official if not pre-sorted
    if !pm_pre_sorted && !official.is_empty() {
        official.reverse();
    }

    // Display order: AUR (top) → Native (middle) → XPM (bottom, closest to prompt)

    // Display AUR packages first (top, least important)
    if !aur.is_empty() {
        println!("{}", "━━━ AUR Packages ━━━".cyan().bold());
        for pkg in &aur {
            print_native_package(pkg, true);
        }
        println!();
    }

    // Display official/native packages (middle)
    if !official.is_empty() {
        println!("{}", "━━━ Native Packages ━━━".cyan().bold());
        for pkg in &official {
            print_native_package(pkg, false);
        }
        println!();
    }

    // Display XPM packages last (bottom, closest to prompt - most relevant)
    if !xpm_packages.is_empty() {
        println!("{}", "━━━ XPM Packages ━━━".cyan().bold());
        for pkg in &xpm_packages {
            let name = format!("{}", pkg.name.green().bold());
            let version = format!("{}", pkg.version.as_deref().unwrap_or("").dimmed());
            let installed_str = if pkg.is_installed() {
                format!("{}", " [installed]".green())
            } else {
                String::new()
            };

            println!("  {} {} {}", name, version, installed_str);

            if let Some(desc) = &pkg.desc {
                println!("    {}", desc.dimmed());
            }
        }
        println!();
    }

    Ok(())
}

fn print_native_package(pkg: &NativePackage, is_aur: bool) {
    let name = if is_aur {
        format!("{}", pkg.name.magenta().bold())
    } else {
        format!("{}", pkg.name.yellow().bold())
    };
    let version = format!("{}", pkg.version.as_deref().unwrap_or("").dimmed());

    let extra = if is_aur {
        pkg.popularity
            .map(|p| format!("(⭐ {})", p))
            .unwrap_or_default()
    } else {
        pkg.repo
            .as_deref()
            .map(|r| format!("[{}]", r))
            .unwrap_or_default()
    };

    let installed_str = if pkg.installed {
        format!("{}", " [installed]".green())
    } else {
        String::new()
    };

    if is_aur {
        println!(
            "  {} {} {} {}",
            name,
            version,
            extra.yellow(),
            installed_str
        );
    } else {
        println!(
            "  {} {} {} {}",
            name,
            version,
            extra.dimmed(),
            installed_str
        );
    }

    if let Some(desc) = &pkg.description {
        println!("    {}", desc.dimmed());
    }
}

#[cfg(test)]
mod tests {
    use super::*;

    fn create_test_package(name: &str, title: Option<&str>) -> Package {
        let mut pkg = Package::new(name);
        pkg.title = title.map(|t| t.to_string());
        pkg
    }

    #[test]
    fn test_calculate_relevance_exact_match() {
        let pkg = create_test_package("vim", None);
        let terms = vec!["vim".to_string()];
        assert_eq!(calculate_relevance(&pkg, &terms), 1000);
    }

    #[test]
    fn test_calculate_relevance_starts_with() {
        let pkg = create_test_package("vim-airline", None);
        let terms = vec!["vim".to_string()];
        assert_eq!(calculate_relevance(&pkg, &terms), 100);
    }

    #[test]
    fn test_calculate_relevance_contains() {
        let pkg = create_test_package("neovim", None);
        let terms = vec!["vim".to_string()];
        assert_eq!(calculate_relevance(&pkg, &terms), 30);
    }

    #[test]
    fn test_calculate_relevance_title_match() {
        let pkg = create_test_package("something-else", Some("Vim-fork editor"));
        let terms = vec!["vim".to_string()];
        assert_eq!(calculate_relevance(&pkg, &terms), 10);
    }

    #[test]
    fn test_calculate_relevance_multiple_terms() {
        let pkg = create_test_package("vim", Some("Text editor"));
        let terms = vec!["vim".to_string(), "editor".to_string()];
        // vim exact match (1000) + editor in title (10)
        assert_eq!(calculate_relevance(&pkg, &terms), 1010);
    }

    #[test]
    fn test_calculate_relevance_no_match() {
        let pkg = create_test_package("emacs", None);
        let terms = vec!["vim".to_string()];
        assert_eq!(calculate_relevance(&pkg, &terms), 0);
    }

    #[test]
    fn test_calculate_relevance_case_insensitive() {
        let pkg = create_test_package("VIM", None);
        let terms = vec!["vim".to_string()];
        assert_eq!(calculate_relevance(&pkg, &terms), 1000);

        let pkg2 = create_test_package("vim", None);
        let terms2 = vec!["VIM".to_string()];
        assert_eq!(calculate_relevance(&pkg2, &terms2), 1000);
    }
}
