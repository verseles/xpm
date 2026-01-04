//! XPM CLI - Universal Package Manager
//!
//! Command-line interface for XPM.

mod commands;

use clap::{Parser, Subcommand};
use std::process::ExitCode;
use tracing_subscriber::{layer::SubscriberExt, util::SubscriberInitExt};
use xpm_core::{utils::logger::Logger, VERSION};

#[derive(Parser)]
#[command(
    name = "xpm",
    author = "Verseles",
    version = VERSION,
    about = "Universal package manager for any unix-like distro including macOS",
    long_about = None
)]
struct Cli {
    /// Enable verbose output
    #[arg(short, long, global = true)]
    verbose: bool,

    /// Output in JSON format (for scripting)
    #[arg(long, global = true)]
    json: bool,

    /// Suppress non-essential output
    #[arg(short, long, global = true)]
    quiet: bool,

    #[command(subcommand)]
    command: Commands,
}

#[derive(Subcommand)]
enum Commands {
    /// Search for packages
    #[command(aliases = ["s", "query", "q"])]
    Search {
        /// Search terms
        #[arg(required = true)]
        terms: Vec<String>,

        /// Maximum number of results
        #[arg(short, long, default_value = "30")]
        limit: usize,
    },

    /// Install a package
    #[command(alias = "i")]
    Install {
        /// Package name
        package: String,

        /// Installation method (auto, any, apt, pacman, brew, etc.)
        #[arg(short, long, default_value = "auto")]
        method: String,

        /// Release channel (stable, beta, etc.)
        #[arg(short, long)]
        channel: Option<String>,
    },

    /// Remove a package
    #[command(alias = "rm")]
    Remove {
        /// Package name
        package: String,
    },

    /// Refresh package database
    Refresh,

    /// Upgrade installed packages (stub)
    Upgrade,

    /// Download a file
    Get {
        /// URL to download
        url: String,

        /// Output filename (optional)
        #[arg(short, long)]
        output: Option<String>,
    },

    /// File operations
    File {
        #[command(subcommand)]
        action: FileAction,
    },

    /// Repository management
    Repo {
        #[command(subcommand)]
        action: RepoAction,
    },

    /// Compute checksums
    #[command(alias = "hash")]
    Checksum {
        /// File to checksum
        file: String,

        /// Algorithm (md5, sha1, sha256, sha512)
        #[arg(short, long, default_value = "sha256")]
        algorithm: String,
    },

    /// Create a desktop shortcut
    Shortcut {
        /// Name for the shortcut
        name: String,

        /// Executable path or command
        exec: String,

        /// Icon path (optional)
        #[arg(short, long)]
        icon: Option<String>,

        /// Category (optional)
        #[arg(short, long)]
        category: Option<String>,
    },

    /// Show log
    Log {
        /// Number of entries to show
        #[arg(short, long, default_value = "20")]
        count: usize,
    },

    /// Check system configuration
    Check,

    /// Make a package (stub)
    Make {
        /// Package name
        name: String,
    },
}

#[derive(Subcommand)]
pub(crate) enum FileAction {
    /// Copy a file
    Copy {
        source: String,
        destination: String,
    },
    /// Move a file
    Move {
        source: String,
        destination: String,
    },
    /// Delete a file
    Delete {
        path: String,
    },
    /// Execute a file
    Exec {
        path: String,
        #[arg(trailing_var_arg = true)]
        args: Vec<String>,
    },
    /// Move file to bin directory
    Bin {
        path: String,
        #[arg(short, long)]
        name: Option<String>,
    },
    /// Remove file from bin directory
    Unbin {
        name: String,
    },
}

#[derive(Subcommand)]
pub(crate) enum RepoAction {
    /// Add a repository
    Add {
        /// Repository URL
        url: String,
    },
    /// Remove a repository
    Remove {
        /// Repository URL
        url: String,
    },
    /// List repositories
    List,
}

fn init_logging(verbose: bool) {
    let filter = if verbose { "debug" } else { "info" };

    tracing_subscriber::registry()
        .with(tracing_subscriber::EnvFilter::try_from_default_env()
            .unwrap_or_else(|_| filter.into()))
        .with(tracing_subscriber::fmt::layer().without_time())
        .init();
}

#[tokio::main]
async fn main() -> ExitCode {
    let cli = Cli::parse();

    init_logging(cli.verbose);

    let result = run(cli).await;

    match result {
        Ok(()) => ExitCode::SUCCESS,
        Err(e) => {
            Logger::error(&format!("{}", e));
            ExitCode::FAILURE
        }
    }
}

async fn run(cli: Cli) -> anyhow::Result<()> {
    match cli.command {
        Commands::Search { terms, limit } => {
            commands::search::run(&terms, limit, cli.json).await
        }
        Commands::Install { package, method, channel } => {
            commands::install::run(&package, &method, channel.as_deref()).await
        }
        Commands::Remove { package } => {
            commands::remove::run(&package).await
        }
        Commands::Refresh => {
            commands::refresh::run().await
        }
        Commands::Upgrade => {
            commands::upgrade::run().await
        }
        Commands::Get { url, output } => {
            commands::get::run(&url, output.as_deref()).await
        }
        Commands::File { action } => {
            commands::file::run(action).await
        }
        Commands::Repo { action } => {
            commands::repo::run(action).await
        }
        Commands::Checksum { file, algorithm } => {
            commands::checksum::run(&file, &algorithm).await
        }
        Commands::Shortcut { name, exec, icon, category } => {
            commands::shortcut::run(&name, &exec, icon.as_deref(), category.as_deref()).await
        }
        Commands::Log { count } => {
            commands::log::run(count).await
        }
        Commands::Check => {
            commands::check::run().await
        }
        Commands::Make { name } => {
            commands::make::run(&name).await
        }
    }
}
