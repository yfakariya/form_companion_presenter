// See LICENCE file in the root.

/// Represents configuration.
/// A configuration is specified through builder option,
/// but they can be overriden via annotation.
class Config {
  static const _suppressFieldFactoryKey = 'suppress_field_factory';
  static const _extraLibrariesKey = 'extra_libraries';

  /// Key of [asPart] in config.
  static const asPartKey = 'as_part';

  final Map<String, dynamic> _underlying;

  /// Whether field factories generation should be suppressed or not.
  /// Default is `false` and configuration key is `suppress_field_factory`.
  bool get suppressFieldFactory =>
      _underlying[_suppressFieldFactoryKey] == true;

  /// Whether the file should be generated as part of target library
  /// rather than individual library file.
  /// This means the generated source will share import directives and
  /// namespaces with input library source.
  ///
  /// Part file is convinient for users of the presenter library because they
  /// just import the presenter library only.
  /// However, it is hard for developers of the presenter library because it
  /// requires them to describe many imports with avoiding name conflicts.
  bool get asPart => _underlying[asPartKey] == true;

  /// Ordered list of extra libraries to resolve `preferredFieldType`s.
  /// Each entries must be specified as 'package:` form URI.
  List<String> get extraLibraries {
    final dynamic mayBeExtraLibraries = _underlying[_extraLibrariesKey];
    if (mayBeExtraLibraries is List) {
      return mayBeExtraLibraries.whereType<String>().toList();
    } else {
      return [];
    }
  }

  /// Initializes a new instance with values from builder options.
  const Config(this._underlying);

  /// Creates new instance from specified [Config] instance
  /// and overriding values which are specified in the annotation.
  factory Config.withOverride(
    Config source, {
    bool? suppressFieldFactory,
  }) {
    final copied = Map<String, dynamic>.from(source._underlying);
    if (suppressFieldFactory != null) {
      copied[_suppressFieldFactoryKey] = suppressFieldFactory;
    }

    return Config(copied);
  }
}
