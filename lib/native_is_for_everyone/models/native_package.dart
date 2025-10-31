class NativePackage {
  final String name;
  final String? version;
  final String? description;
  final String? arch;

  NativePackage({required this.name, this.version, this.description, this.arch});

  @override
  String toString() {
    return 'NativePackage{name: $name, version: $version, description: $description, arch: $arch}';
  }
}
