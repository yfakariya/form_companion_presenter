Future<dynamic> enablePubGet(
  String directory,
  List<String> dependentPackages, {
  bool runPubGet = false,
}) async {
  // Read pubspec.yaml
  // Add or uncomment dependency_overrides
  // Run pub get
}

Future<dynamic> resetEnablePubGet(
  String directory,
  List<String> dependentPackages,
) async {
  // Read pubspec.yaml
  // Comment dependency_overrides
}
