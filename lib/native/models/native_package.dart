class NativePackage {
  final String name;
  final String? version;
  final String? description;
  final bool isInstalled;
  final String source;

  NativePackage({
    required this.name,
    this.version,
    this.description,
    this.isInstalled = false,
    required this.source,
  });
}
