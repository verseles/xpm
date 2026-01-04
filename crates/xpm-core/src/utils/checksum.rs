//! Checksum verification utilities

use anyhow::{Context, Result};
use digest::Digest;
use std::fs::File;
use std::io::Read;
use std::path::Path;

/// Checksum algorithm types
#[derive(Debug, Clone, Copy, PartialEq, Eq)]
pub enum ChecksumAlgorithm {
    Md5,
    Sha1,
    Sha224,
    Sha256,
    Sha384,
    Sha512,
    Sha512_224,
    Sha512_256,
}

impl ChecksumAlgorithm {
    /// Parse algorithm from string
    pub fn parse(s: &str) -> Option<Self> {
        match s.to_lowercase().as_str() {
            "md5" => Some(Self::Md5),
            "sha1" => Some(Self::Sha1),
            "sha224" => Some(Self::Sha224),
            "sha256" => Some(Self::Sha256),
            "sha384" => Some(Self::Sha384),
            "sha512" => Some(Self::Sha512),
            "sha512-224" | "sha512/224" => Some(Self::Sha512_224),
            "sha512-256" | "sha512/256" => Some(Self::Sha512_256),
            _ => None,
        }
    }

    /// Get algorithm name
    pub fn name(&self) -> &'static str {
        match self {
            Self::Md5 => "MD5",
            Self::Sha1 => "SHA1",
            Self::Sha224 => "SHA224",
            Self::Sha256 => "SHA256",
            Self::Sha384 => "SHA384",
            Self::Sha512 => "SHA512",
            Self::Sha512_224 => "SHA512/224",
            Self::Sha512_256 => "SHA512/256",
        }
    }
}

/// Checksum calculation and verification
pub struct Checksum;

impl Checksum {
    /// Calculate checksum of a file
    pub fn calculate(path: &Path, algorithm: ChecksumAlgorithm) -> Result<String> {
        let mut file =
            File::open(path).with_context(|| format!("Failed to open file: {}", path.display()))?;

        let mut buffer = Vec::new();
        file.read_to_end(&mut buffer)
            .with_context(|| format!("Failed to read file: {}", path.display()))?;

        Ok(Self::hash_bytes(&buffer, algorithm))
    }

    /// Calculate checksum of bytes
    pub fn hash_bytes(data: &[u8], algorithm: ChecksumAlgorithm) -> String {
        match algorithm {
            ChecksumAlgorithm::Md5 => {
                let hash = md5::Md5::digest(data);
                format!("{:x}", hash)
            }
            ChecksumAlgorithm::Sha1 => {
                let hash = sha1::Sha1::digest(data);
                format!("{:x}", hash)
            }
            ChecksumAlgorithm::Sha224 => {
                let hash = sha2::Sha224::digest(data);
                format!("{:x}", hash)
            }
            ChecksumAlgorithm::Sha256 => {
                let hash = sha2::Sha256::digest(data);
                format!("{:x}", hash)
            }
            ChecksumAlgorithm::Sha384 => {
                let hash = sha2::Sha384::digest(data);
                format!("{:x}", hash)
            }
            ChecksumAlgorithm::Sha512 => {
                let hash = sha2::Sha512::digest(data);
                format!("{:x}", hash)
            }
            ChecksumAlgorithm::Sha512_224 => {
                let hash = sha2::Sha512_224::digest(data);
                format!("{:x}", hash)
            }
            ChecksumAlgorithm::Sha512_256 => {
                let hash = sha2::Sha512_256::digest(data);
                format!("{:x}", hash)
            }
        }
    }

    /// Verify a file's checksum
    pub fn verify(path: &Path, expected: &str, algorithm: ChecksumAlgorithm) -> Result<bool> {
        let calculated = Self::calculate(path, algorithm)?;
        Ok(calculated.eq_ignore_ascii_case(expected))
    }

    /// Calculate checksum asynchronously
    pub async fn calculate_async(path: &Path, algorithm: ChecksumAlgorithm) -> Result<String> {
        let path = path.to_path_buf();
        tokio::task::spawn_blocking(move || Self::calculate(&path, algorithm))
            .await
            .context("Checksum task panicked")?
    }

    /// Verify checksum asynchronously
    pub async fn verify_async(
        path: &Path,
        expected: &str,
        algorithm: ChecksumAlgorithm,
    ) -> Result<bool> {
        let path = path.to_path_buf();
        let expected = expected.to_string();
        tokio::task::spawn_blocking(move || Self::verify(&path, &expected, algorithm))
            .await
            .context("Checksum task panicked")?
    }

    /// Calculate checksum from file path string and algorithm name
    pub async fn from_file(file_path: &str, algorithm: &str) -> Result<String> {
        let algo = ChecksumAlgorithm::parse(algorithm)
            .ok_or_else(|| anyhow::anyhow!("Unsupported algorithm: {}", algorithm))?;

        let path = std::path::PathBuf::from(file_path);
        Self::calculate_async(&path, algo).await
    }
}

pub fn compute_md5(path: &std::path::Path) -> Result<String> {
    Checksum::calculate(path, ChecksumAlgorithm::Md5)
}

pub fn compute_sha1(path: &std::path::Path) -> Result<String> {
    Checksum::calculate(path, ChecksumAlgorithm::Sha1)
}

pub fn compute_sha256(path: &std::path::Path) -> Result<String> {
    Checksum::calculate(path, ChecksumAlgorithm::Sha256)
}

pub fn compute_sha512(path: &std::path::Path) -> Result<String> {
    Checksum::calculate(path, ChecksumAlgorithm::Sha512)
}

#[cfg(test)]
mod tests {
    use super::*;
    use std::io::Write;
    use tempfile::NamedTempFile;

    #[test]
    fn test_md5_hash() {
        let hash = Checksum::hash_bytes(b"hello world", ChecksumAlgorithm::Md5);
        assert_eq!(hash, "5eb63bbbe01eeed093cb22bb8f5acdc3");
    }

    #[test]
    fn test_sha256_hash() {
        let hash = Checksum::hash_bytes(b"hello world", ChecksumAlgorithm::Sha256);
        assert_eq!(
            hash,
            "b94d27b9934d3e08a52e52d7da7dabfac484efe37a5380ee9088f7ace2efcde9"
        );
    }

    #[test]
    fn test_sha1_hash() {
        let hash = Checksum::hash_bytes(b"hello world", ChecksumAlgorithm::Sha1);
        assert_eq!(hash, "2aae6c35c94fcfb415dbe95f408b9ce91ee846ed");
    }

    #[test]
    fn test_file_checksum() -> Result<()> {
        let mut file = NamedTempFile::new()?;
        file.write_all(b"test content")?;

        let hash = Checksum::calculate(file.path(), ChecksumAlgorithm::Sha256)?;
        assert!(!hash.is_empty());
        assert_eq!(hash.len(), 64); // SHA256 produces 64 hex chars

        Ok(())
    }

    #[test]
    fn test_verify() -> Result<()> {
        let mut file = NamedTempFile::new()?;
        file.write_all(b"hello world")?;

        let expected = "b94d27b9934d3e08a52e52d7da7dabfac484efe37a5380ee9088f7ace2efcde9";
        assert!(Checksum::verify(
            file.path(),
            expected,
            ChecksumAlgorithm::Sha256
        )?);
        assert!(!Checksum::verify(
            file.path(),
            "wrong_hash",
            ChecksumAlgorithm::Sha256
        )?);

        Ok(())
    }

    #[test]
    fn test_algorithm_from_str() {
        assert_eq!(
            ChecksumAlgorithm::parse("sha256"),
            Some(ChecksumAlgorithm::Sha256)
        );
        assert_eq!(
            ChecksumAlgorithm::parse("MD5"),
            Some(ChecksumAlgorithm::Md5)
        );
        assert_eq!(
            ChecksumAlgorithm::parse("sha512-256"),
            Some(ChecksumAlgorithm::Sha512_256)
        );
        assert_eq!(ChecksumAlgorithm::parse("unknown"), None);
    }

    #[tokio::test]
    async fn test_async_checksum() -> Result<()> {
        let mut file = NamedTempFile::new()?;
        file.write_all(b"async test")?;

        let hash = Checksum::calculate_async(file.path(), ChecksumAlgorithm::Sha256).await?;
        assert!(!hash.is_empty());

        Ok(())
    }
}
