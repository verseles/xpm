//! Desktop shortcut command implementation

use anyhow::Result;
use owo_colors::OwoColorize;
use xpm_core::utils::logger::Logger;

/// Run the shortcut command
#[allow(clippy::too_many_arguments)]
pub async fn run(
    name: &str,
    exec: Option<&str>,
    icon: Option<&str>,
    category: Option<&str>,
    description: Option<&str>,
    terminal: bool,
    shortcut_type: &str,
    mime: Option<&str>,
    startup: bool,
    remove: bool,
) -> Result<()> {
    // Get applications directory
    let apps_dir = dirs::data_dir()
        .map(|d| d.join("applications"))
        .ok_or_else(|| anyhow::anyhow!("Could not determine applications directory"))?;

    let desktop_file = apps_dir.join(format!("{}.desktop", slugify(name)));

    // Handle removal
    if remove {
        if desktop_file.exists() {
            tokio::fs::remove_file(&desktop_file).await?;
            Logger::success(&format!(
                "Removed shortcut: {}",
                desktop_file.display().to_string().green()
            ));

            // Update desktop database
            update_desktop_database(&apps_dir).await;
        } else {
            Logger::warning(&format!("Shortcut not found: {}", name));
        }
        return Ok(());
    }

    // For creation, exec is required
    let exec = exec.ok_or_else(|| anyhow::anyhow!("Executable path is required"))?;

    Logger::info(&format!(
        "Creating desktop shortcut for {}...",
        name.green()
    ));

    tokio::fs::create_dir_all(&apps_dir).await?;

    // Build icon line
    let icon_line = icon
        .map(|i| format!("Icon={}", i))
        .unwrap_or_else(|| "Icon=application-x-executable".to_string());

    // Build category (ensure it ends with semicolon)
    let categories = category
        .map(|c| {
            if c.ends_with(';') {
                c.to_string()
            } else {
                format!("{};", c)
            }
        })
        .unwrap_or_else(|| "Utility;".to_string());

    // Build optional lines
    let comment_line = description
        .map(|d| format!("Comment={}\n", d))
        .unwrap_or_default();

    let mime_line = mime
        .map(|m| {
            if m.ends_with(';') {
                format!("MimeType={}\n", m)
            } else {
                format!("MimeType={};\n", m)
            }
        })
        .unwrap_or_default();

    let content = format!(
        r#"[Desktop Entry]
Type={shortcut_type}
Name={name}
Exec={exec}
{icon_line}
Categories={categories}
Terminal={terminal}
StartupNotify={startup}
{comment_line}{mime_line}"#,
        shortcut_type = shortcut_type,
        name = name,
        exec = exec,
        icon_line = icon_line,
        categories = categories,
        terminal = terminal,
        startup = startup,
        comment_line = comment_line,
        mime_line = mime_line
    );

    // Remove trailing whitespace and extra newlines
    let content = content.trim_end().to_string() + "\n";

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

    // Update desktop database
    update_desktop_database(&apps_dir).await;

    Ok(())
}

async fn update_desktop_database(apps_dir: &std::path::Path) {
    if let Ok(status) = tokio::process::Command::new("update-desktop-database")
        .arg(apps_dir)
        .status()
        .await
    {
        if status.success() {
            Logger::info("Updated desktop database");
        }
    }
}

fn slugify(s: &str) -> String {
    s.to_lowercase()
        .chars()
        .map(|c| {
            if c.is_alphanumeric() || c == '-' {
                c
            } else {
                '-'
            }
        })
        .collect::<String>()
        .trim_matches('-')
        .to_string()
}
