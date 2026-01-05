//! File operations command implementation

use crate::FileAction;
use anyhow::Result;
use owo_colors::OwoColorize;
use std::os::unix::fs::PermissionsExt;
use std::path::Path;
use std::process::Stdio;
use tokio::process::Command;
use xpm_core::{os::dirs::XpmDirs, utils::logger::Logger};

/// Run the file command
pub async fn run(action: FileAction) -> Result<()> {
    match action {
        FileAction::Copy {
            source,
            destination,
        } => copy(&source, &destination).await,
        FileAction::Move {
            source,
            destination,
        } => move_file(&source, &destination).await,
        FileAction::Delete { path } => delete(&path).await,
        FileAction::Exec { path, args } => exec(&path, &args).await,
        FileAction::Bin { path, name } => bin(&path, name.as_deref()).await,
        FileAction::Unbin { name } => unbin(&name).await,
    }
}

async fn copy(source: &str, destination: &str) -> Result<()> {
    Logger::info(&format!(
        "Copying {} to {}...",
        source.cyan(),
        destination.green()
    ));

    tokio::fs::copy(source, destination).await?;

    Logger::success("File copied successfully");
    Ok(())
}

async fn move_file(source: &str, destination: &str) -> Result<()> {
    Logger::info(&format!(
        "Moving {} to {}...",
        source.cyan(),
        destination.green()
    ));

    // Try rename first (faster if same filesystem)
    if tokio::fs::rename(source, destination).await.is_err() {
        // Fall back to copy + delete
        tokio::fs::copy(source, destination).await?;
        tokio::fs::remove_file(source).await?;
    }

    Logger::success("File moved successfully");
    Ok(())
}

async fn delete(path: &str) -> Result<()> {
    Logger::info(&format!("Deleting {}...", path.red()));

    let metadata = tokio::fs::metadata(path).await?;

    if metadata.is_dir() {
        tokio::fs::remove_dir_all(path).await?;
    } else {
        tokio::fs::remove_file(path).await?;
    }

    Logger::success("Deleted successfully");
    Ok(())
}

async fn exec(path: &str, args: &[String]) -> Result<()> {
    Logger::info(&format!("Executing {}...", path.cyan()));

    // Make executable
    let mut perms = tokio::fs::metadata(path).await?.permissions();
    perms.set_mode(0o755);
    tokio::fs::set_permissions(path, perms).await?;

    // Execute
    let status = Command::new(path)
        .args(args)
        .stdin(Stdio::inherit())
        .stdout(Stdio::inherit())
        .stderr(Stdio::inherit())
        .status()
        .await?;

    if !status.success() {
        anyhow::bail!("Execution failed with exit code: {:?}", status.code());
    }

    Ok(())
}

async fn bin(path: &str, name: Option<&str>) -> Result<()> {
    let bin_dir = XpmDirs::bin_dir()?;
    let source_path = Path::new(path);

    let dest_name = name.map(String::from).unwrap_or_else(|| {
        source_path
            .file_stem()
            .map(|s| s.to_string_lossy().to_string())
            .unwrap_or_else(|| "binary".to_string())
    });

    let dest_path = bin_dir.join(&dest_name);

    Logger::info(&format!(
        "Moving {} to bin as {}...",
        path.cyan(),
        dest_name.green()
    ));

    // Copy to bin
    tokio::fs::copy(path, &dest_path).await?;

    // Make executable
    let mut perms = tokio::fs::metadata(&dest_path).await?.permissions();
    perms.set_mode(0o755);
    tokio::fs::set_permissions(&dest_path, perms).await?;

    Logger::success(&format!(
        "Installed to {}",
        dest_path.display().to_string().green()
    ));

    Ok(())
}

async fn unbin(name: &str) -> Result<()> {
    let bin_dir = XpmDirs::bin_dir()?;
    let bin_path = bin_dir.join(name);

    if !bin_path.exists() {
        anyhow::bail!("Binary '{}' not found in {}", name, bin_dir.display());
    }

    Logger::info(&format!("Removing {} from bin...", name.red()));

    tokio::fs::remove_file(&bin_path).await?;

    Logger::success("Removed from bin");
    Ok(())
}
