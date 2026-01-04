//! Get (download) command implementation

use anyhow::Result;
use futures::StreamExt;
use indicatif::{ProgressBar, ProgressStyle};
use owo_colors::OwoColorize;
use std::path::Path;
use tokio::fs::File;
use tokio::io::AsyncWriteExt;
use xpm_core::os::XpmDirs;
use xpm_core::utils::checksum;
use xpm_core::utils::logger::Logger;

/// Run the get command
#[allow(clippy::too_many_arguments)]
pub async fn run(
    url: &str,
    output: Option<&str>,
    name: Option<&str>,
    user_agent: Option<&str>,
    no_user_agent: bool,
    exec: bool,
    bin: bool,
    no_progress: bool,
    md5: Option<&str>,
    sha1: Option<&str>,
    sha256: Option<&str>,
    sha512: Option<&str>,
) -> Result<()> {
    let filename = name
        .map(String::from)
        .or_else(|| output.map(String::from))
        .or_else(|| {
            url.split('/')
                .next_back()
                .filter(|s| !s.is_empty() && s.contains('.'))
                .map(String::from)
        })
        .unwrap_or_else(|| "download".to_string());

    Logger::info(&format!(
        "Downloading {} to {}...",
        url.cyan(),
        filename.green()
    ));

    let mut client_builder = reqwest::Client::builder();

    if !no_user_agent {
        let ua = user_agent.unwrap_or("xpm/1.0");
        client_builder = client_builder.user_agent(ua);
    }

    let client = client_builder.build()?;
    let response = client.get(url).send().await?;

    if !response.status().is_success() {
        anyhow::bail!("Failed to download: HTTP {}", response.status());
    }

    let total_size = response.content_length().unwrap_or(0);

    let pb = if no_progress {
        None
    } else if total_size > 0 {
        let pb = ProgressBar::new(total_size);
        pb.set_style(
            ProgressStyle::default_bar()
                .template("{spinner:.green} [{elapsed_precise}] [{bar:40.cyan/blue}] {bytes}/{total_bytes} ({bytes_per_sec})")
                .unwrap()
                .progress_chars("█▓░")
        );
        Some(pb)
    } else {
        let pb = ProgressBar::new_spinner();
        pb.set_style(
            ProgressStyle::default_spinner()
                .template("{spinner:.green} {bytes} downloaded ({bytes_per_sec})")
                .unwrap(),
        );
        Some(pb)
    };

    let mut file = File::create(&filename).await?;

    let mut stream = response.bytes_stream();
    let mut downloaded: u64 = 0;

    while let Some(chunk) = stream.next().await {
        let chunk = chunk?;
        file.write_all(&chunk).await?;
        downloaded += chunk.len() as u64;
        if let Some(ref pb) = pb {
            pb.set_position(downloaded);
        }
    }

    if let Some(pb) = pb {
        pb.finish_and_clear();
    }

    let file_path = Path::new(&filename);
    
    if let Some(expected) = md5 {
        let actual = checksum::compute_md5(file_path)?;
        if actual != expected {
            anyhow::bail!("MD5 mismatch: expected {}, got {}", expected, actual);
        }
        Logger::success("MD5 checksum verified");
    }

    if let Some(expected) = sha1 {
        let actual = checksum::compute_sha1(file_path)?;
        if actual != expected {
            anyhow::bail!("SHA1 mismatch: expected {}, got {}", expected, actual);
        }
        Logger::success("SHA1 checksum verified");
    }

    if let Some(expected) = sha256 {
        let actual = checksum::compute_sha256(file_path)?;
        if actual != expected {
            anyhow::bail!("SHA256 mismatch: expected {}, got {}", expected, actual);
        }
        Logger::success("SHA256 checksum verified");
    }

    if let Some(expected) = sha512 {
        let actual = checksum::compute_sha512(file_path)?;
        if actual != expected {
            anyhow::bail!("SHA512 mismatch: expected {}, got {}", expected, actual);
        }
        Logger::success("SHA512 checksum verified");
    }

    if exec {
        #[cfg(unix)]
        {
            use std::os::unix::fs::PermissionsExt;
            let mut perms = std::fs::metadata(&filename)?.permissions();
            perms.set_mode(perms.mode() | 0o111);
            std::fs::set_permissions(&filename, perms)?;
            Logger::success("Made file executable");
        }
    }

    if bin {
        let bin_dir = XpmDirs::bin_dir()?;
        let dest = bin_dir.join(Path::new(&filename).file_name().unwrap());
        std::fs::rename(&filename, &dest)?;
        Logger::success(&format!("Moved to {}", dest.display()));
    }

    let metadata = tokio::fs::metadata(&filename).await.ok();
    let size = metadata.map(|m| format_size(m.len())).unwrap_or_default();

    Logger::success(&format!(
        "Downloaded {} {}",
        filename.green(),
        if !size.is_empty() { format!("({})", size.cyan()) } else { String::new() }
    ));

    Ok(())
}

fn format_size(bytes: u64) -> String {
    const KB: u64 = 1024;
    const MB: u64 = KB * 1024;
    const GB: u64 = MB * 1024;

    if bytes >= GB {
        format!("{:.2} GB", bytes as f64 / GB as f64)
    } else if bytes >= MB {
        format!("{:.2} MB", bytes as f64 / MB as f64)
    } else if bytes >= KB {
        format!("{:.2} KB", bytes as f64 / KB as f64)
    } else {
        format!("{} bytes", bytes)
    }
}
