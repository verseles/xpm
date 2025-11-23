class NativePackage {
  final String name;
  final String? version;
  final String? description;
  final String? arch;
  final String? repo;
  final int? popularity;

  NativePackage({required this.name, this.version, this.description, this.arch, this.repo, this.popularity});

  /// Whether this package is from AUR
  bool get isAur => repo == 'aur';

  /// Whether this package is from official repos (extra, core, chaotic-aur)
  bool get isOfficial => repo == 'extra' || repo == 'chaotic-aur' || repo == 'core' || repo == 'community';

  @override
  String toString() {
    return 'NativePackage{name: $name, version: $version, description: $description, arch: $arch, repo: $repo, popularity: $popularity}';
  }

  /// Sorts and organizes a list of native packages for display.
  ///
  /// Returns packages in order: AUR (sorted by popularity ascending) → Official (sorted alphabetically)
  /// This order is designed for terminal output where newest messages appear at the top.
  static List<NativePackage> sortForDisplay(List<NativePackage> packages) {
    final aurPackages = <NativePackage>[];
    final extraChaoticPackages = <NativePackage>[];
    final otherOfficialPackages = <NativePackage>[];

    for (final pkg in packages) {
      if (pkg.repo == 'aur') {
        aurPackages.add(pkg);
      } else if (pkg.repo == 'extra' || pkg.repo == 'chaotic-aur') {
        extraChaoticPackages.add(pkg);
      } else {
        otherOfficialPackages.add(pkg);
      }
    }

    // Sort official packages alphabetically
    extraChaoticPackages.sort((a, b) => a.name.compareTo(b.name));
    otherOfficialPackages.sort((a, b) => a.name.compareTo(b.name));

    // Sort AUR packages by popularity (ascending - least popular first, most popular last)
    aurPackages.sort((a, b) {
      final aPop = a.popularity ?? 0;
      final bPop = b.popularity ?? 0;
      return aPop.compareTo(bPop);
    });

    // Return in order: AUR → extra/chaotic → other official
    return [...aurPackages, ...extraChaoticPackages, ...otherOfficialPackages];
  }
}
