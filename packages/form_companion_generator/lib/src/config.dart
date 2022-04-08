// See LICENCE file in the root.

/// Represents configuration.
/// A configuration is specified through builder option,
/// but they can be overriden via annotation.
class Config {
  static const _autovalidateByDefaultKey = 'autovalidate_by_default';
  static const _extraLibrariesKey = 'extra_libraries';

  /// Key of [asPart] in config.
  static const asPartKey = 'as_part';

  final Map<String, dynamic> _underlying;

  /// Whether autovalidate for each `FormField` should be `true` when each
  /// applications of `@FormCompanion` annotations do not specify their own
  /// configuration.
  /// The default is `true`, so each `FormField` will do auto-validation as
  /// `AutovalidateMode.onUserInteraction` when form field factory callers
  /// do not specify `AutovalidateMode`.
  ///
  /// Note that this configuration and `@FormCompanion` setting do **NOT**
  /// affect `autovalidateMode` of `Form` (or `FormBuilder`) itself.
  /// You must specify it when you want to validate all fields at once rather
  /// than auto-validating each field individually.
  bool get autovalidateByDefault =>
      _underlying[_autovalidateByDefaultKey] != false;

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
  ///
  /// Dependencies in generating source is basically resolved from depdency
  /// resolution for source file, which declares presenter(s) decorated with
  /// `@formCompanion` annotation. In some situations, this stragety does not
  /// work, so resolution of `FormField` can be failed. If so, you specify this
  /// property to help generator.
  List<String> get extraLibraries {
    final dynamic mayBeExtraLibraries = _underlying[_extraLibrariesKey];
    if (mayBeExtraLibraries is String) {
      return [mayBeExtraLibraries];
    } else if (mayBeExtraLibraries is List) {
      return mayBeExtraLibraries.whereType<String>().toList();
    } else {
      return [];
    }
  }

  /// Initializes a new instance with values from builder options.
  const Config(this._underlying);
}
