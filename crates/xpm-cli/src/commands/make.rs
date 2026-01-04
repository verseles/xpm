use anyhow::Result;
use owo_colors::OwoColorize;
use std::io::{self, Write};
use xpm_core::utils::logger::Logger;

pub async fn run(name: &str) -> Result<()> {
    Logger::info(&format!("Creating package script for '{}'...", name.cyan()));

    print!("Package title [{}]: ", name);
    io::stdout().flush()?;
    let mut title = String::new();
    io::stdin().read_line(&mut title)?;
    let title = title.trim();
    let title = if title.is_empty() { name } else { title };

    print!("Version [1.0.0]: ");
    io::stdout().flush()?;
    let mut version = String::new();
    io::stdin().read_line(&mut version)?;
    let version = version.trim();
    let version = if version.is_empty() { "1.0.0" } else { version };

    print!("Description: ");
    io::stdout().flush()?;
    let mut desc = String::new();
    io::stdin().read_line(&mut desc)?;
    let desc = desc.trim();

    print!("Homepage URL: ");
    io::stdout().flush()?;
    let mut url = String::new();
    io::stdin().read_line(&mut url)?;
    let url = url.trim();

    print!(
        "Validation command (e.g., 'which {}') [which {}]: ",
        name, name
    );
    io::stdout().flush()?;
    let mut validate_cmd = String::new();
    io::stdin().read_line(&mut validate_cmd)?;
    let validate_cmd = validate_cmd.trim();
    let validate_cmd = if validate_cmd.is_empty() {
        format!("which {}", name)
    } else {
        validate_cmd.to_string()
    };

    let script = format!(
        r#"#!/bin/bash

readonly xNAME="{name}"
readonly xVERSION="{version}"
readonly xTITLE="{title}"
readonly xDESC="{desc}"
readonly xURL="{url}"

xARCHS=(x86_64 aarch64 arm)
xDEFAULT=(any)

install_any() {{
    local sudo="${{1:-}}"
    
    echo "Installing {name}..."
    
    # Add your installation logic here
    # Available variables:
    #   $XPM       - Path to xpm executable
    #   $xSUDO     - sudo command (empty on Android)
    #   $xCHANNEL  - Installation channel (stable/beta/nightly)
    #   $xOS       - Operating system (linux/macos/windows/android)
    #   $xARCH     - CPU architecture (x86_64/aarch64/arm/etc)
    #   $xBIN      - Binary installation directory
    #   $xHOME     - User home directory
    #   $xTMP      - Temporary directory for this package
    #   $hasSnap   - true if snap is available
    #   $hasFlatpak - true if flatpak is available
    
    echo "{name} installed successfully"
}}

remove_any() {{
    local sudo="${{1:-}}"
    
    echo "Removing {name}..."
    
    # Add your removal logic here
    
    echo "{name} removed successfully"
}}

validate() {{
    {validate_cmd} >/dev/null 2>&1
}}
"#,
        name = name,
        version = version,
        title = title,
        desc = desc,
        url = url,
        validate_cmd = validate_cmd,
    );

    let filename = format!("{}.bash", name);
    std::fs::write(&filename, &script)?;

    Logger::success(&format!("Created {}", filename.green()));
    Logger::info("Next steps:");
    println!("  1. Edit {} to add installation logic", filename.cyan());
    println!("  2. Move it to your repository's packages/ directory");
    println!("  3. Run {} to update the index", "xpm refresh".cyan());

    Ok(())
}
