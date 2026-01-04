//! Desktop shortcut command implementation

use anyhow::Result;
use owo_colors::OwoColorize;
use xpm_core::utils::logger::Logger;

/// Run the shortcut command
pub async fn run(name: &str, exec: &str, icon: Option<&str>, category: Option<&str>) -> Result<()> {
    Logger::info(&format!("Creating desktop shortcut for {}...", name.green()));

    // Get applications directory using the dirs crate pattern
    let apps_dir = dirs::data_dir()
        .map(|d| d.join("applications"))
        .ok_or_else(|| anyhow::anyhow!("Could not determine applications directory"))?;

    tokio::fs::create_dir_all(&apps_dir).await?;

    // Create .desktop file
    let desktop_file = apps_dir.join(format!("{}.desktop", slugify(name)));

    let icon_line = icon
        .map(|i| format!("Icon={}", i))
        .unwrap_or_else(|| "Icon=application-x-executable".to_string());

    let category = category.unwrap_or("Utility");

    let content = format!(
        r#"[Desktop Entry]
Type=Application
Name={name}
Exec={exec}
{icon_line}
Categories={category};
Terminal=false
StartupNotify=true
"#,
        name = name,
        exec = exec,
        icon_line = icon_line,
        category = category
    );

    tokio::fs::write(&desktop_file, content).await?;

    // Make executable
    #[cfg(unix)]
    {
        use std::os::unix::fs::PermissionsExt;
        let mut perms = tokio::fs::metadata(&desktop_file).await?.permissions();
        perms.set_mode(0o755);
        tokio::fs::set_permissions(&desktop_file, perms).await?;
    }

    Logger::success(&format!(
        "Created shortcut at {}",
        desktop_file.display().to_string().green()
    ));

    // Update desktop database if available
    if let Ok(status) = tokio::process::Command::new("update-desktop-database")
        .arg(&apps_dir)
        .status()
        .await
    {
        if status.success() {
            Logger::info("Updated desktop database");
        }
    }

    Ok(())
}

fn slugify(s: &str) -> String {
    s.to_lowercase()
        .chars()
        .map(|c| if c.is_alphanumeric() || c == '-' { c } else { '-' })
        .collect::<String>()
        .trim_matches('-')
        .to_string()
}
