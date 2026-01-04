//! Checksum command implementation

use anyhow::Result;
use owo_colors::OwoColorize;
use xpm_core::utils::{checksum::Checksum, logger::Logger};

/// Run the checksum command
pub async fn run(file: &str, algorithm: &str) -> Result<()> {
    let algo = algorithm.to_lowercase();
    let supported = ["md5", "sha1", "sha256", "sha512"];

    if !supported.contains(&algo.as_str()) {
        anyhow::bail!(
            "Unsupported algorithm: {}. Supported: {}",
            algorithm,
            supported.join(", ")
        );
    }

    Logger::info(&format!(
        "Computing {} checksum for {}...",
        algo.cyan(),
        file.green()
    ));

    let hash = Checksum::from_file(file, &algo).await?;

    println!();
    println!("{}  {}", hash.green().bold(), file);
    println!();

    Ok(())
}
