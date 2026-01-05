//! URL-safe slug generation

use once_cell::sync::Lazy;
use regex::Regex;

/// Regex for non-alphanumeric characters
static NON_ALNUM: Lazy<Regex> = Lazy::new(|| Regex::new(r"[^a-zA-Z0-9]+").unwrap());

/// Regex for multiple dashes
static MULTI_DASH: Lazy<Regex> = Lazy::new(|| Regex::new(r"-+").unwrap());

/// Convert a string to a URL-safe slug
///
/// # Examples
///
/// ```
/// use xpm_core::utils::slugify;
///
/// assert_eq!(slugify("Hello World!"), "hello-world");
/// assert_eq!(slugify("https://github.com/user/repo.git"), "https-github-com-user-repo-git");
/// ```
pub fn slugify(input: &str) -> String {
    let lower = input.to_lowercase();

    // Replace non-alphanumeric with dashes
    let replaced = NON_ALNUM.replace_all(&lower, "-");

    // Collapse multiple dashes
    let collapsed = MULTI_DASH.replace_all(&replaced, "-");

    // Trim leading/trailing dashes
    collapsed.trim_matches('-').to_string()
}

/// Convert URL to a slug suitable for directory names
pub fn url_to_slug(url: &str) -> String {
    slugify(url)
}

/// Slugify with a custom separator
pub fn slugify_with_sep(input: &str, sep: char) -> String {
    let slug = slugify(input);
    slug.replace('-', &sep.to_string())
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn test_slugify_basic() {
        assert_eq!(slugify("Hello World"), "hello-world");
        assert_eq!(slugify("hello world"), "hello-world");
        assert_eq!(slugify("HELLO WORLD"), "hello-world");
    }

    #[test]
    fn test_slugify_special_chars() {
        assert_eq!(slugify("Hello, World!"), "hello-world");
        assert_eq!(slugify("Hello   World"), "hello-world");
        assert_eq!(slugify("Hello---World"), "hello-world");
    }

    #[test]
    fn test_slugify_url() {
        assert_eq!(
            slugify("https://github.com/verseles/xpm-popular.git"),
            "https-github-com-verseles-xpm-popular-git"
        );
    }

    #[test]
    fn test_slugify_edge_cases() {
        assert_eq!(slugify(""), "");
        assert_eq!(slugify("---"), "");
        assert_eq!(slugify("-hello-"), "hello");
        assert_eq!(slugify("123"), "123");
    }

    #[test]
    fn test_slugify_with_sep() {
        assert_eq!(slugify_with_sep("Hello World", '_'), "hello_world");
    }
}
