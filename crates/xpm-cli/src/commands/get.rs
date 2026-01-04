//! Get (download) command implementation

use anyhow::Result;
use futures::StreamExt;
use indicatif::{ProgressBar, ProgressStyle};
use owo_colors::OwoColorize;
use tokio::fs::File;
use tokio::io::AsyncWriteExt;
use xpm_core::utils::logger::Logger;

/// Run the get command
pub async fn run(url: &str, output: Option<&str>) -> Result<()> {
    // Determine output filename
    let filename = output
        .map(String::from)
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

    // Create client
    let client = reqwest::Client::new();
    let response = client.get(url).send().await?;

    if !response.status().is_success() {
        anyhow::bail!("Failed to download: HTTP {}", response.status());
    }

    // Get content length for progress bar
    let total_size = response.content_length().unwrap_or(0);

    // Setup progress bar
    let pb = if total_size > 0 {
        let pb = ProgressBar::new(total_size);
        pb.set_style(
            ProgressStyle::default_bar()
                .template("{spinner:.green} [{elapsed_precise}] [{bar:40.cyan/blue}] {bytes}/{total_bytes} ({bytes_per_sec})")
                .unwrap()
                .progress_chars("█▓░")
        );
        pb
    } else {
        let pb = ProgressBar::new_spinner();
        pb.set_style(
            ProgressStyle::default_spinner()
                .template("{spinner:.green} {bytes} downloaded ({bytes_per_sec})")
                .unwrap(),
        );
        pb
    };

    // Create output file
    let mut file = File::create(&filename).await?;

    // Stream download
    let mut stream = response.bytes_stream();
    let mut downloaded: u64 = 0;

    while let Some(chunk) = stream.next().await {
        let chunk = chunk?;
        file.write_all(&chunk).await?;
        downloaded += chunk.len() as u64;
        pb.set_position(downloaded);
    }

    pb.finish_and_clear();

    // Get file size
    let metadata = tokio::fs::metadata(&filename).await?;
    let size = format_size(metadata.len());

    Logger::success(&format!(
        "Downloaded {} ({})",
        filename.green(),
        size.cyan()
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
