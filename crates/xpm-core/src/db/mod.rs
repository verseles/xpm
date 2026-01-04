//! Database module for XPM
//!
//! Uses native_db (powered by redb) for embedded database operations.

mod models;
mod operations;

pub use models::{Package, Repo, Setting};
pub use operations::Database;
