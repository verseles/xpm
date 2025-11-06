class NativePackage {
  final String name;
  final String? version;
  final String? description;
  final String? arch;
  final String? repo;
  final int? popularity;

  NativePackage({required this.name, this.version, this.description, this.arch, this.repo, this.popularity});

  @override
  String toString() {
    return 'NativePackage{name: $name, version: $version, description: $description, arch: $arch, repo: $repo, popularity: $popularity}';
  }
}
