import 'package:isar/isar.dart';
import 'package:xpm/database/db.dart';
import 'package:xpm/database/models/package.dart';
import 'package:xpm/utils/out.dart';

/// Helper class for generating helpful error messages with suggestions.
class ErrorHelper {
  /// Shows a "package not found" error with suggestions for similar packages.
  static Future<void> packageNotFound(String packageName, {bool showTip = true}) async {
    out('{@red}Package "$packageName" not found.{@end}');

    await _showSimilarPackages(packageName);

    if (showTip) {
      out('');
      out('{@gray}Tips:{@end}');
      out('  - Run {@cyan}xpm refresh{@end} to update the package index');
      out('  - Run {@cyan}xpm search $packageName{@end} to search for packages');
      out('  - Use {@cyan}xpm install -n only $packageName{@end} to try native package manager');
    }
  }

  /// Shows suggestions for similar packages.
  static Future<void> _showSimilarPackages(String packageName) async {
    try {
      final db = await DB.instance();
      final similar = await db.packages
          .filter()
          .nameContains(packageName, caseSensitive: false)
          .or()
          .descContains(packageName, caseSensitive: false)
          .or()
          .titleContains(packageName, caseSensitive: false)
          .limit(5)
          .findAll();

      if (similar.isNotEmpty) {
        out('');
        out('{@yellow}Did you mean:{@end}');
        for (final pkg in similar) {
          final desc = pkg.title ?? pkg.desc ?? '';
          final shortDesc = desc.length > 50 ? '${desc.substring(0, 50)}...' : desc;
          out('  - {@blue}${pkg.name}{@end} - $shortDesc');
        }
      }
    } catch (e) {
      // Silently fail if database is not available
    }
  }

  /// Shows a generic error with suggestions.
  static void showError(String message, {List<String>? suggestions}) {
    out('{@red}Error: $message{@end}');

    if (suggestions != null && suggestions.isNotEmpty) {
      out('');
      out('{@yellow}Suggestions:{@end}');
      for (final suggestion in suggestions) {
        out('  - $suggestion');
      }
    }
  }

  /// Shows installation failure error with troubleshooting tips.
  static void installationFailed(String packageName, String? errorDetails) {
    out('{@red}Failed to install "$packageName".{@end}');

    if (errorDetails != null && errorDetails.isNotEmpty) {
      out('{@gray}Details: $errorDetails{@end}');
    }

    out('');
    out('{@yellow}Troubleshooting tips:{@end}');
    out('  - Check your internet connection');
    out('  - Try running {@cyan}xpm refresh{@end} to update package index');
    out('  - Try a different installation method with {@cyan}--method=<method>{@end}');
    out('  - Run with {@cyan}--verbose{@end} for more details');
  }

  /// Shows removal failure error.
  static void removalFailed(String packageName, String? errorDetails) {
    out('{@red}Failed to remove "$packageName".{@end}');

    if (errorDetails != null && errorDetails.isNotEmpty) {
      out('{@gray}Details: $errorDetails{@end}');
    }

    out('');
    out('{@yellow}Tips:{@end}');
    out('  - Try with {@cyan}--force{@end} to force removal');
    out('  - Run with {@cyan}--verbose{@end} for more details');
  }
}
