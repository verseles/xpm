//! OS abstraction module
//!
//! Provides cross-platform OS detection, architecture detection,
//! executable finding, and file operations.

pub mod arch;
pub mod dirs;
pub mod executable;
pub mod file_ops;
pub mod os_info;

pub use arch::{get_architecture, Architecture};
pub use dirs::XpmDirs;
pub use executable::Executable;
pub use file_ops::FileOps;
pub use os_info::{get_os_info, OsInfo, OsType};
