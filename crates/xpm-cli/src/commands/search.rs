//! Search command implementation

use anyhow::Result;
use owo_colors::OwoColorize;
use xpm_core::{
    db::Database,
    native_pm::{detect_native_pm, NativePackageManager},
    utils::logger::Logger,
};

/// Run the search command
pub async fn run(
    terms: &[String],
    limit: usize,
    exact: bool,
    all: bool,
    native_mode: &str,
    json: bool,
) -> Result<()> {
    // Validate input
    if terms.is_empty() && !all {
        anyhow::bail!("No search terms provided. Use --all to list all packages.");
    }

    let db = Database::instance()?;

    // Search XPM packages based on mode
    let xpm_packages = if native_mode != "only" {
        if all {
            db.get_packages_limited(limit)?
        } else if exact {
            // Exact match by name
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

    // Search native package manager (not when --all is used)
    let native_packages = if native_mode != "off" && !all {
        if let Some(pm) = detect_native_pm().await {
            // Only search native if we have few XPM results or native mode is "only"
            if native_mode == "only" || xpm_packages.len() < 6 {
                let query = terms.join(" ");
                pm.search(&query, Some(limit)).await.unwrap_or_default()
            } else {
                Vec::new()
            }
        } else {
            Vec::new()
        }
    } else {
        Vec::new()
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

    // Display XPM packages first
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

    // Display native packages
    if !native_packages.is_empty() {
        // Group by repo type
        let official: Vec<_> = native_packages.iter().filter(|p| !p.is_aur()).collect();
        let mut aur: Vec<_> = native_packages.iter().filter(|p| p.is_aur()).collect();

        // Display official packages
        if !official.is_empty() {
            println!("{}", "━━━ Native Packages ━━━".cyan().bold());
            for pkg in &official {
                let name = format!("{}", pkg.name.yellow().bold());
                let version = format!("{}", pkg.version.as_deref().unwrap_or("").dimmed());
                let repo = pkg
                    .repo
                    .as_deref()
                    .map(|r| format!("[{}]", r))
                    .unwrap_or_default();
                let installed_str = if pkg.installed {
                    format!("{}", " [installed]".green())
                } else {
                    String::new()
                };

                println!("  {} {} {} {}", name, version, repo.dimmed(), installed_str);

                if let Some(desc) = &pkg.description {
                    println!("    {}", desc.dimmed());
                }
            }
            println!();
        }

        // Display AUR packages
        if !aur.is_empty() {
            // Sort by popularity (descending)
            aur.sort_by(|a, b| b.popularity.cmp(&a.popularity));

            println!("{}", "━━━ AUR Packages ━━━".cyan().bold());
            for pkg in &aur {
                let name = format!("{}", pkg.name.magenta().bold());
                let version = format!("{}", pkg.version.as_deref().unwrap_or("").dimmed());
                let popularity = pkg
                    .popularity
                    .map(|p| format!("(⭐ {:.1})", p as f64 / 100.0))
                    .unwrap_or_default();
                let installed_str = if pkg.installed {
                    format!("{}", " [installed]".green())
                } else {
                    String::new()
                };

                println!(
                    "  {} {} {} {}",
                    name,
                    version,
                    popularity.yellow(),
                    installed_str
                );

                if let Some(desc) = &pkg.description {
                    println!("    {}", desc.dimmed());
                }
            }
            println!();
        }
    }

    Ok(())
}
