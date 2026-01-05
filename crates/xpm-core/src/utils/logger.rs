//! Logging utilities with colored output

use owo_colors::OwoColorize;
use std::io::{self, Write};

/// Log level for messages
#[derive(Debug, Clone, Copy, PartialEq, Eq)]
pub enum LogLevel {
    Info,
    Success,
    Warning,
    Error,
    Tip,
    Debug,
}

/// Logger with colored output
pub struct Logger;

impl Logger {
    /// Log a message with prefix
    pub fn log(message: &str) {
        eprintln!("{} {}", "[xpm]".dimmed(), message);
    }

    /// Log an info message (blue)
    pub fn info(message: &str) {
        eprintln!(
            "{} {}",
            "[info]".blue().bold(),
            Self::format_colors(message)
        );
    }

    /// Log a success message (green)
    pub fn success(message: &str) {
        eprintln!("{} {}", "[ok]".green().bold(), Self::format_colors(message));
    }

    /// Log a warning message (yellow)
    pub fn warning(message: &str) {
        eprintln!(
            "{} {}",
            "[warn]".yellow().bold(),
            Self::format_colors(message)
        );
    }

    /// Log an error message (red) and optionally exit
    pub fn error(message: &str) {
        eprintln!(
            "{} {}",
            "[error]".red().bold(),
            Self::format_colors(message)
        );
    }

    /// Log an error and exit with code
    pub fn error_exit(message: &str, code: i32) -> ! {
        Self::error(message);
        std::process::exit(code);
    }

    /// Log a tip message (cyan)
    pub fn tip(message: &str) {
        eprintln!("{} {}", "[tip]".cyan().bold(), Self::format_colors(message));
    }

    /// Log a debug message (dimmed)
    pub fn debug(message: &str) {
        if std::env::var("XPM_DEBUG").is_ok() {
            eprintln!("{} {}", "[debug]".dimmed(), message.dimmed());
        }
    }

    /// Print to stdout (for actual output, not logs)
    pub fn print(message: &str) {
        println!("{}", Self::format_colors(message));
    }

    /// Print to stdout without newline
    pub fn print_inline(message: &str) {
        print!("{}", Self::format_colors(message));
        let _ = io::stdout().flush();
    }

    /// Format color codes in message
    /// Supports: {@green}, {@blue}, {@red}, {@yellow}, {@cyan}, {@end}
    pub fn format_colors(message: &str) -> String {
        let mut result = message.to_string();

        // Color mappings
        let colors = [
            ("{@green}", "\x1b[32m"),
            ("{@blue}", "\x1b[34m"),
            ("{@red}", "\x1b[31m"),
            ("{@yellow}", "\x1b[33m"),
            ("{@cyan}", "\x1b[36m"),
            ("{@magenta}", "\x1b[35m"),
            ("{@white}", "\x1b[37m"),
            ("{@bold}", "\x1b[1m"),
            ("{@dim}", "\x1b[2m"),
            ("{@gold}", "\x1b[38;5;214m"),
            ("{@end}", "\x1b[0m"),
        ];

        // Check if terminal supports colors
        if !Self::supports_color() {
            // Strip color codes
            for (code, _) in &colors {
                result = result.replace(code, "");
            }
            return result;
        }

        // Replace color codes
        for (code, ansi) in &colors {
            result = result.replace(code, ansi);
        }

        result
    }

    /// Check if terminal supports colors
    pub fn supports_color() -> bool {
        // Check NO_COLOR env
        if std::env::var("NO_COLOR").is_ok() {
            return false;
        }

        // Check FORCE_COLOR env
        if std::env::var("FORCE_COLOR").is_ok() {
            return true;
        }

        // Check if stdout is a tty
        #[cfg(unix)]
        {
            unsafe { libc::isatty(libc::STDOUT_FILENO) != 0 }
        }

        #[cfg(windows)]
        {
            // On Windows, assume color support in modern terminals
            true
        }

        #[cfg(not(any(unix, windows)))]
        {
            false
        }
    }

    /// Create a formatted package found message
    pub fn package_found(name: &str, version: Option<&str>, desc: Option<&str>) -> String {
        let version_str = version
            .map(|v| format!(" {}", v.green()))
            .unwrap_or_default();
        let desc_str = desc.map(|d| format!(" - {}", d)).unwrap_or_default();
        format!("{}{}{}", name.blue(), version_str, desc_str)
    }
}

/// Output a formatted message (replacement for Dart's out() function)
pub fn out(message: &str) {
    println!("{}", Logger::format_colors(message));
}

/// Output to stderr
pub fn err(message: &str) {
    eprintln!("{}", Logger::format_colors(message));
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn test_format_colors() {
        let input = "{@green}success{@end}";
        let output = Logger::format_colors(input);
        // Should contain ANSI codes or be stripped based on terminal support
        assert!(output.contains("success"));
    }

    #[test]
    fn test_package_found() {
        let output = Logger::package_found("test-pkg", Some("1.0.0"), Some("A test package"));
        assert!(output.contains("test-pkg"));
    }
}
