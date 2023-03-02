// See LICENCE file in the root.

import 'package:analyzer/dart/element/element.dart';
import 'package:analyzer/exception/exception.dart';
import 'package:form_companion_generator/src/config.dart';
import 'package:pub_semver/pub_semver.dart';
import 'package:test/test.dart';

final ver2_15 = LibraryLanguageVersion(
  package: Version(2, 15, 0),
  override: Version(2, 15, 0),
);

final ver2_15_0_pre = LibraryLanguageVersion(
  package: Version(2, 15, 0, pre: '-pre'),
  override: Version(2, 15, 0, pre: '-pre'),
);
final ver2_15_1_pre = LibraryLanguageVersion(
  package: Version(2, 15, 1, pre: '-pre'),
  override: Version(2, 15, 1, pre: '-pre'),
);

final ver2_15_withBuild = LibraryLanguageVersion(
  package: Version(2, 15, 0, build: 'DEADBEEF'),
  override: Version(2, 15, 0, build: 'DEADBEEF'),
);

final ver2_14_999 = LibraryLanguageVersion(
  package: Version(2, 14, 999),
  override: Version(2, 14, 999),
);

void main() {
  test('constructor and defaults', () {
    final target = Config(<String, dynamic>{});
    expect(target.asPart, isFalse);
    expect(target.autovalidateByDefault, isTrue);
    expect(target.extraLibraries, isEmpty);
  });

  group('asPart', () {
    test('true - true', () {
      final target = Config(<String, dynamic>{'as_part': true});
      expect(target.asPart, isTrue);
    });

    test('false - false', () {
      final target = Config(<String, dynamic>{'as_part': false});
      expect(target.asPart, isFalse);
    });

    test('invalid casing -- ignored', () {
      final target = Config(<String, dynamic>{'As_Part': true});
      expect(target.asPart, isFalse);
    });

    test('non boolean -- ignored', () {
      final target = Config(<String, dynamic>{'as_part': 'true'});
      expect(target.asPart, isFalse);
    });
  });

  group('autovalidateByDefault', () {
    test('true - true', () {
      final target = Config(<String, dynamic>{'autovalidate_by_default': true});
      expect(target.autovalidateByDefault, isTrue);
    });

    test('false - false', () {
      final target =
          Config(<String, dynamic>{'autovalidate_by_default': false});
      expect(target.autovalidateByDefault, isFalse);
    });

    test('invalid casing -- ignored', () {
      final target = Config(<String, dynamic>{'autoValidate_by_default': true});
      expect(target.autovalidateByDefault, isTrue);
    });

    test('non boolean -- ignored', () {
      final target =
          Config(<String, dynamic>{'autovalidate_by_default': 'true'});
      expect(target.autovalidateByDefault, isTrue);
    });
  });

  group('usesEnumName', () {
    test('true - true', () {
      final target = Config(const <String, dynamic>{'uses_enum_name': true});
      expect(target.getUsesEnumName(ver2_15), isTrue);
    });

    test('false - false', () {
      final target = Config(const <String, dynamic>{'uses_enum_name': false});
      expect(target.getUsesEnumName(ver2_15), isFalse);
    });

    test('undefined, 2.15 -- true', () {
      final target = Config(const <String, dynamic>{});
      expect(target.getUsesEnumName(ver2_15), isTrue);
    });

    test('undefined, 2.14.999 -- false', () {
      final target = Config(const <String, dynamic>{});
      expect(target.getUsesEnumName(ver2_14_999), isFalse);
    });

    test('undefined, 2.15.0-pre -- false', () {
      final target = Config(const <String, dynamic>{});
      expect(target.getUsesEnumName(ver2_15_0_pre), isFalse);
    });

    test('undefined, 2.15.1-pre -- true', () {
      final target = Config(const <String, dynamic>{});
      expect(target.getUsesEnumName(ver2_15_1_pre), isTrue);
    });

    test('undefined, 2.15+DEADBEAF -- true', () {
      final target = Config(const <String, dynamic>{});
      expect(target.getUsesEnumName(ver2_15_withBuild), isTrue);
    });

    test('invalid casing -- default', () {
      final target = Config(const <String, dynamic>{'uses_enum_name': true});
      expect(target.getUsesEnumName(ver2_15), isTrue);
    });

    test('non boolean -- error', () {
      final target = Config(const <String, dynamic>{'uses_enum_name': 'true'});
      expect(
        () => target.getUsesEnumName(ver2_15),
        throwsA(
          isA<AnalysisException>().having(
            (e) => e.message,
            'message',
            "Unexpected value type of 'uses_enum_name'. Value must be bool or null, but string.",
          ),
        ),
      );
    });
  });

  group('extraLibraries', () {
    test('1 extra_libraries - recognized', () {
      final target =
          Config(<String, dynamic>{'extra_libraries': 'package:foo/foo.dart'});
      expect(target.extraLibraries, ['package:foo/foo.dart']);
    });

    test('2 extra_libraries - recognized', () {
      final target = Config(<String, dynamic>{
        'extra_libraries': ['package:foo/foo.dart', 'package:bar/bar.dart']
      });
      expect(
        target.extraLibraries,
        ['package:foo/foo.dart', 'package:bar/bar.dart'],
      );
    });

    test('0 extra_libraries - empty', () {
      final target = Config(<String, dynamic>{'extra_libraries': <String>[]});
      expect(target.extraLibraries, isEmpty);
    });

    test('invalid casing -- ignored', () {
      final target = Config(<String, dynamic>{
        'Extra_Libraries': ['package:foo/foo.dart', 'package:bar/bar.dart']
      });
      expect(target.extraLibraries, isEmpty);
    });

    test('non sequence -- error', () {
      final target = Config(<String, dynamic>{'extra_libraries': true});
      expect(
        () => target.extraLibraries,
        throwsA(
          isA<AnalysisException>().having(
            (e) => e.message,
            'message',
            "Unexpected value type of 'extra_libraries'. Value must be list of string, but bool.",
          ),
        ),
      );
    });

    test('hetero types -- all errors are reported', () {
      final target = Config(<String, dynamic>{
        'extra_libraries': [
          'package:foo/foo.dart',
          true,
          ['package:bar/bar.dart'],
          'package:boo/boo.dart',
        ]
      });
      expect(
        () => target.extraLibraries,
        throwsA(
          isA<AnalysisException>().having(
            (e) => e.message,
            'message',
            "Unexpected item type at index 1 in 'extra_libraries'. Items must be string, but bool.\n"
                "Unexpected item type at index 2 in 'extra_libraries'. Items must be string, but sequence of string.",
          ),
        ),
      );
    });
  });

  group('named_templates', () {
    test('string maps can be parsed', () {
      final target = Config(<String, dynamic>{
        'named_templates': {'key': 'VALUE'},
      });
      final result = target.namedTemplates['KEY'];
      expect(result, isNotNull);
      expect(result!.value, 'VALUE');
      expect(result.imports, isEmpty);
    });

    test('empty maps is harmless', () {
      final target = Config(<String, dynamic>{
        'named_templates': <String, String>{},
      });
      expect(
        target.namedTemplates.isEmpty,
        isTrue,
      );
    });

    test('non map causes error', () {
      final target = Config(<String, dynamic>{
        'named_templates': 0,
      });
      expect(
        () => target.namedTemplates,
        throwsA(
          isA<AnalysisException>().having(
            (e) => e.message,
            'message',
            "Unexpected value type of 'named_templates'. "
                'Value must be mapping of string key and NamedTemplate value, but int.',
          ),
        ),
      );
    });

    test('error message is cached', () {
      final target = Config(<String, dynamic>{
        'named_templates': 0,
      });
      late final AnalysisException firstError;
      late final StackTrace firstStackTrace;
      try {
        final _ = target.namedTemplates;
      } on AnalysisException catch (e, s) {
        firstError = e;
        firstStackTrace = s;
      }

      try {
        final _ = target.namedTemplates;
      } on AnalysisException catch (e, s) {
        expect(e.message, firstError.message);
        expect(s.toString(), isNot(firstStackTrace.toString()));
      }
    });

    test('non string keys cause error', () {
      final target = Config(<String, dynamic>{
        'named_templates': {
          0: '0',
        },
      });
      expect(
        () => target.namedTemplates.isEmpty,
        throwsA(
          isA<AnalysisException>().having(
            (e) => e.message,
            'message',
            "Unexpected key type of '0' property of 'named_templates'. Keys must be string, but int.",
          ),
        ),
      );
    });

    test('non string values cause error', () {
      final target = Config(<String, dynamic>{
        'named_templates': {
          'map': 0,
        },
      });
      expect(
        () => target.namedTemplates.isEmpty,
        throwsA(
          isA<AnalysisException>().having(
            (e) => e.message,
            'message',
            "Unexpected value type of 'map' property of 'named_templates'. "
                'Value must be String or mapping, but int.',
          ),
        ),
      );
    });

    test('non string template value cause error', () {
      final target = Config(<String, dynamic>{
        'named_templates': {
          'map': {'template': 0},
        },
      });
      expect(
        () => target.namedTemplates['map'],
        throwsA(
          isA<AnalysisException>().having(
            (e) => e.message,
            'message',
            "'map' property of 'named_templates' must have String 'template' "
                "property, but the type of 'template' is int.",
          ),
        ),
      );
    });

    group('imports', () {
      void testImports(
        dynamic input,
        List<TemplateImports> expected,
      ) {
        final target = Config(<String, dynamic>{
          'named_templates': {
            'template': <dynamic, dynamic>{
              'template': 'value',
              'imports': input,
            }
          },
        });
        final result = target.namedTemplates['TEMPLATE'];
        expect(result, isNotNull);
        expect(result!.value, 'value');
        expected.sort((l, r) {
          final uri = l.uri.compareTo(r.uri);
          if (uri != 0) {
            return uri;
          }

          return l.prefix.compareTo(r.prefix);
        });
        final imports = result.imports.toList();
        expect(imports.length, expected.length);
        for (var i = 0; i < expected.length; i++) {
          expect(imports[i].uri, expected[i].uri, reason: '[$i].uri');
          expect(imports[i].prefix, expected[i].prefix, reason: '[$i].prefix');
          expect(imports[i].types, expected[i].types, reason: '[$i].types');
        }
      }

      test(
        'simple string should be non-prefixed uri without types',
        () => testImports(
          'package:a/b.dart',
          [TemplateImports('package:a/b.dart', '', [])],
        ),
      );

      test(
        'string map should be prefixed uri with types',
        () => testImports(
          {
            'a.TypeA': 'package:a/b.dart',
            'TypeAA': 'package:a/b.dart',
            'b.TypeB': 'package:b/c.dart',
            'TypeBB': 'package:b/c.dart',
          },
          [
            TemplateImports('package:a/b.dart', '', ['TypeAA']),
            TemplateImports('package:a/b.dart', 'a', ['TypeA']),
            TemplateImports('package:b/c.dart', '', ['TypeBB']),
            TemplateImports('package:b/c.dart', 'b', ['TypeB']),
          ],
        ),
      );

      test('non map imports cause error', () {
        final target = Config(<String, dynamic>{
          'named_templates': {
            'template': <dynamic, dynamic>{
              'template': 'value',
              'imports': 0,
            }
          },
        });
        expect(
          () => target.namedTemplates['TEMPLATE'],
          throwsA(
            isA<AnalysisException>().having(
              (e) => e.message,
              'message',
              "Unexpected value type of 'imports' property of 'named_templates'. Value must be string or mapping, but int.",
            ),
          ),
        );
      });

      test('non string key in imports cause error', () {
        final target = Config(<String, dynamic>{
          'named_templates': {
            'template': <dynamic, dynamic>{
              'template': 'value',
              'imports': {0: '0'},
            }
          },
        });
        expect(
          () => target.namedTemplates['TEMPLATE'],
          throwsA(
            isA<AnalysisException>().having(
              (e) => e.message,
              'message',
              "Unexpected key '0' type of 'imports' property of 'named_templates'. Keys must be string, but int.",
            ),
          ),
        );
      });

      test('non string value in imports cause error', () {
        final target = Config(<String, dynamic>{
          'named_templates': {
            'template': <dynamic, dynamic>{
              'template': 'value',
              'imports': {'0': 0},
            }
          },
        });
        expect(
          () => target.namedTemplates['TEMPLATE'],
          throwsA(
            isA<AnalysisException>().having(
              (e) => e.message,
              'message',
              "Unexpected value '0' type of '0' property of 'imports' property of 'named_templates'. Values must be URI string, but int.",
            ),
          ),
        );
      });

      test('invalid format key cause error', () {
        final target = Config(<String, dynamic>{
          'named_templates': {
            'template': <dynamic, dynamic>{
              'template': 'value',
              'imports': {'a.b.c': 'a/b.dart'},
            }
          },
        });
        expect(
          () => target.namedTemplates['TEMPLATE'],
          throwsA(
            isA<AnalysisException>().having(
              (e) => e.message,
              'message',
              "Unexpected key format of 'imports' property of 'named_templates'. Keys must be '[{prefix}.]{typeName}', but 'a.b.c'.",
            ),
          ),
        );
      });
    });
  });

  group('argument_templates', () {
    test('string maps can be parsed', () {
      final target = Config(<String, dynamic>{
        'argument_templates': {
          'AFormField': {'param': 'value'}
        },
      });
      final result = target.argumentTemplates.get('AFormField', 'param');
      expect(result.imports, isEmpty);
      expect(result.itemTemplate, isNull);
      expect(result.value, 'value');
    });

    test('empty maps is harmless', () {
      final target = Config(<String, dynamic>{
        'argument_templates': <String, String>{},
      });
      expect(
        target.argumentTemplates.isEmpty,
        isTrue,
      );
    });

    test('non map causes error', () {
      final target = Config(<String, dynamic>{
        'argument_templates': 0,
      });
      expect(
        () => target.argumentTemplates,
        throwsA(
          isA<AnalysisException>().having(
            (e) => e.message,
            'message',
            "Unexpected value type of 'argument_templates'. "
                'Value must be mapping of string key and '
                'Map<String, ArgumentTemplate> value, but int.',
          ),
        ),
      );
    });

    test('non string keys cause error', () {
      final target = Config(<String, dynamic>{
        'argument_templates': <dynamic, dynamic>{
          0: '0',
        },
      });
      expect(
        () => target.argumentTemplates.isEmpty,
        throwsA(
          isA<AnalysisException>().having(
            (e) => e.message,
            'message',
            "Unexpected key type of '0' property of 'argument_templates'. "
                'Keys must be string, but int.',
          ),
        ),
      );
    });

    test('non map values cause error', () {
      final target = Config(<String, dynamic>{
        'argument_templates': <dynamic, dynamic>{
          '0': '0',
        },
      });
      expect(
        () => target.argumentTemplates.isEmpty,
        throwsA(
          isA<AnalysisException>().having(
            (e) => e.message,
            'message',
            "Unexpected value type of '0' property of 'argument_templates'. "
                'Value must be mapping of string key and mapping value, but string.',
          ),
        ),
      );
    });

    test('error message is cached', () {
      final target = Config(<String, dynamic>{
        'argument_templates': 0,
      });
      late final AnalysisException firstError;
      late final StackTrace firstStackTrace;
      try {
        final _ = target.argumentTemplates;
      } on AnalysisException catch (e, s) {
        firstError = e;
        firstStackTrace = s;
      }

      try {
        final _ = target.argumentTemplates;
      } on AnalysisException catch (e, s) {
        expect(e.message, firstError.message);
        expect(s.toString(), isNot(firstStackTrace.toString()));
      }
    });

    test('string maps can be parsed', () {
      final target = Config(<String, dynamic>{
        'argument_templates': {
          'AFormField': {
            'simple': {'template': 'value'},
            'item': {'item_template': 'value'},
          }
        },
      });
      final simple = target.argumentTemplates.get('AFormField', 'simple');
      expect(simple.imports, isEmpty);
      expect(simple.itemTemplate, isNull);
      expect(simple.value, 'value');
      final item = target.argumentTemplates.get('AFormField', 'item');
      expect(item.imports, isEmpty);
      expect(item.itemTemplate, 'value');
      expect(item.value, isNull);
    });

    test('non string keys in maps cause error', () {
      final target = Config(<String, dynamic>{
        'argument_templates': {
          'AFormField': {
            0: '0',
          }
        },
      });
      expect(
        () => target.argumentTemplates.get('AFormField', '0'),
        throwsA(
          isA<AnalysisException>().having(
            (e) => e.message,
            'message',
            "Unexpected key type of '0' property of 'AFormField' property of 'argument_templates'. "
                'Keys must be string, but int.',
          ),
        ),
      );
    });

    test('non string/object values in maps cause error', () {
      final target = Config(<String, dynamic>{
        'argument_templates': {
          'AFormField': {
            'scalar': 0,
          }
        },
      });
      expect(
        () => target.argumentTemplates.get('AFormField', 'scalar'),
        throwsA(
          isA<AnalysisException>().having(
            (e) => e.message,
            'message',
            "Unexpected value type of 'scalar' property of 'AFormField' property of "
                "'argument_templates'. Value must be string or mapping, but int.",
          ),
        ),
      );
    });

    test('object without template and item_template in maps cause error', () {
      final target = Config(<String, dynamic>{
        'argument_templates': {
          'AFormField': {
            'scalar': {
              'imports': {'p.Foo': 'package:foo/bar.dart'},
            },
          }
        },
      });
      final template = target.argumentTemplates.get('AFormField', 'scalar');
      expect(template.itemTemplate, isNull);
      expect(template.value, isNull);
      expect(template.imports.length, 1);
      final import = template.imports.single;
      expect(import.prefix, 'p');
      expect(import.types, ['Foo']);
      expect(import.uri, 'package:foo/bar.dart');
    });

    test('object with invalid template and item_template in maps cause error',
        () {
      final target = Config(<String, dynamic>{
        'argument_templates': {
          'AFormField': {
            'empty': {'template': 0, 'item_template': false},
          }
        },
      });
      expect(
        () => target.argumentTemplates.get('AFormField', 'scalar'),
        throwsA(
          isA<AnalysisException>().having(
            (e) => e.message,
            'message',
            "'empty' property of 'AFormField' property of "
                "'argument_templates' must have string 'template' or 'item_template' "
                'property, or needs that both of them are not specified, '
                "but the type of 'template' is int, "
                "and the type of 'item_template' is bool.",
          ),
        ),
      );
    });

    void testDualTemplate(
      Map<dynamic, dynamic> input,
      String? itemTemplate,
      String? value,
    ) {
      final target = Config(<String, dynamic>{
        'argument_templates': {
          'AFormField': {
            'param': input,
          }
        },
      });
      final result = target.argumentTemplates.get('AFormField', 'param');
      expect(result.imports, isEmpty);
      expect(result.itemTemplate, itemTemplate);
      expect(result.value, value);
    }

    for (final type in [0, null, 'invalid']) {
      test(
        'template: ${type.runtimeType}, item_template: valid - item_template is used',
        () => testDualTemplate(
          <dynamic, dynamic>{'item_template': 'value', 'template': type},
          'value',
          null,
        ),
      );

      if (type is! String) {
        test(
          'template: value, item_template: ${type.runtimeType} - template is used',
          () => testDualTemplate(
            <dynamic, dynamic>{'item_template': type, 'template': 'value'},
            null,
            'value',
          ),
        );
      }
    }

    test('extra items are ignored in each argument templates', () {
      final target = Config(<String, dynamic>{
        'argument_templates': {
          'AFormField': {
            'param': {
              'template': 'value',
              0: 0,
              '0': 0,
              'map': {'k': 'v'},
              'array': ['e'],
              'extra': 'extra',
            }
          }
        },
      });
      final result = target.argumentTemplates.get('AFormField', 'param');
      expect(result.imports, isEmpty);
      expect(result.itemTemplate, isNull);
      expect(result.value, 'value');
    });

    group('imports', () {
      void testImports(
        dynamic input,
        List<TemplateImports> expected,
      ) {
        final target = Config(<String, dynamic>{
          'argument_templates': {
            'AFormField': {
              'param': <dynamic, dynamic>{
                'template': 'value',
                'imports': input,
              }
            }
          },
        });
        final result = target.argumentTemplates.get('AFormField', 'param');
        expect(result.itemTemplate, isNull);
        expect(result.value, 'value');
        expected.sort((l, r) {
          final uri = l.uri.compareTo(r.uri);
          if (uri != 0) {
            return uri;
          }

          return l.prefix.compareTo(r.prefix);
        });
        final imports = result.imports.toList();
        expect(imports.length, expected.length);
        for (var i = 0; i < expected.length; i++) {
          expect(imports[i].uri, expected[i].uri, reason: '[$i].uri');
          expect(imports[i].prefix, expected[i].prefix, reason: '[$i].prefix');
          expect(imports[i].types, expected[i].types, reason: '[$i].types');
        }
      }

      test(
        'simple string should be non-prefixed uri without types',
        () => testImports(
          'package:a/b.dart',
          [TemplateImports('package:a/b.dart', '', [])],
        ),
      );

      test(
        'string map should be prefixed uri with types',
        () => testImports(
          {
            'a.TypeA': 'package:a/b.dart',
            'TypeAA': 'package:a/b.dart',
            'b.TypeB': 'package:b/c.dart',
            'TypeBB': 'package:b/c.dart',
          },
          [
            TemplateImports('package:a/b.dart', '', ['TypeAA']),
            TemplateImports('package:a/b.dart', 'a', ['TypeA']),
            TemplateImports('package:b/c.dart', '', ['TypeBB']),
            TemplateImports('package:b/c.dart', 'b', ['TypeB']),
          ],
        ),
      );

      test('non map imports cause error', () {
        final target = Config(<String, dynamic>{
          'argument_templates': {
            'AFormField': {
              'param': <dynamic, dynamic>{
                'template': 'value',
                'imports': 0,
              }
            }
          },
        });
        expect(
          () => target.argumentTemplates.get('AFormField', 'param'),
          throwsA(
            isA<AnalysisException>().having(
              (e) => e.message,
              'message',
              "Unexpected value type of 'imports' property of 'param' property of 'AFormField' property of 'argument_templates'. Value must be string or mapping, but int.",
            ),
          ),
        );
      });

      test('non string key in imports cause error', () {
        final target = Config(<String, dynamic>{
          'argument_templates': {
            'AFormField': {
              'param': <dynamic, dynamic>{
                'template': 'value',
                'imports': {0: '0'},
              }
            }
          },
        });
        expect(
          () => target.argumentTemplates.get('AFormField', 'param'),
          throwsA(
            isA<AnalysisException>().having(
              (e) => e.message,
              'message',
              "Unexpected key '0' type of 'imports' property of 'param' property of 'AFormField' property of 'argument_templates'. Keys must be string, but int.",
            ),
          ),
        );
      });

      test('non string value in imports cause error', () {
        final target = Config(<String, dynamic>{
          'argument_templates': {
            'AFormField': {
              'param': <dynamic, dynamic>{
                'template': 'value',
                'imports': {'0': 0},
              }
            }
          },
        });
        expect(
          () => target.argumentTemplates.get('AFormField', 'param'),
          throwsA(
            isA<AnalysisException>().having(
              (e) => e.message,
              'message',
              "Unexpected value '0' type of '0' property of 'imports' property of 'param' property of 'AFormField' property of 'argument_templates'. Values must be URI string, but int.",
            ),
          ),
        );
      });

      test('invalid format key cause error', () {
        final target = Config(<String, dynamic>{
          'argument_templates': {
            'AFormField': {
              'param': <dynamic, dynamic>{
                'template': 'value',
                'imports': {'a.b.c': 'a/b.dart'},
              }
            }
          },
        });
        expect(
          () => target.argumentTemplates.get('AFormField', 'param'),
          throwsA(
            isA<AnalysisException>().having(
              (e) => e.message,
              'message',
              "Unexpected key format of 'imports' property of 'param' property of 'AFormField' property of 'argument_templates'. Keys must be '[{prefix}.]{typeName}', but 'a.b.c'.",
            ),
          ),
        );
      });
    });

    group('default', () {
      test(
          'undefined parameter in defined type should be replaced with defined default',
          () {
        final target = Config(<String, dynamic>{
          'argument_templates': {
            'default': {'paramDefault': 'DEFAULT'},
            'AFormField': {'param': 'value'},
          },
        });
        final result =
            target.argumentTemplates.get('AFormField', 'paramDefault');
        expect(result.imports, isEmpty);
        expect(result.itemTemplate, isNull);
        expect(result.value, 'DEFAULT');
      });

      test(
          'undefined type and defined parameter should be replaced with defined default',
          () {
        final target = Config(<String, dynamic>{
          'argument_templates': {
            'default': {'paramDefault': 'DEFAULT'},
            'AFormField': {'param': 'value'},
          },
        });
        final result =
            target.argumentTemplates.get('TheFormField', 'paramDefault');
        expect(result.imports, isEmpty);
        expect(result.itemTemplate, isNull);
        expect(result.value, 'DEFAULT');
      });

      test(
          'defined type and undefined parameter should be replaced with defined default',
          () {
        final target = Config(<String, dynamic>{
          'argument_templates': {
            'default': {'paramDefault': 'DEFAULT'},
            'AFormField': {'param': 'value'},
          },
        });
        final result =
            target.argumentTemplates.get('TheFormField', 'paramDefault');
        expect(result.imports, isEmpty);
        expect(result.itemTemplate, isNull);
        expect(result.value, 'DEFAULT');
      });

      test(
          'undefined type and undefined parameter should be replaced with built-in default',
          () {
        final target = Config(<String, dynamic>{
          'argument_templates': {
            'default': {'paramDefault': 'DEFAULT'},
            'AFormField': {'param': 'value'},
          },
        });
        final result =
            target.argumentTemplates.get('TheFormField', 'paramNonDefault');
        expect(result.imports, isEmpty);
        expect(result.itemTemplate, isNull);
        expect(result.value, '#ARGUMENT#');
      });

      test(
          'undefined type and defined parameter should be replaced with built-in default',
          () {
        final target = Config(<String, dynamic>{
          'argument_templates': {
            'AFormField': {'param': 'value'},
          },
        });
        final result = target.argumentTemplates.get('TheFormField', 'param');
        expect(result.imports, isEmpty);
        expect(result.itemTemplate, isNull);
        expect(result.value, '#ARGUMENT#');
      });

      test(
          'defined type and undefined parameter should be replaced with built-in default',
          () {
        final target = Config(<String, dynamic>{
          'argument_templates': {
            'AFormField': {'param': 'value'},
          },
        });
        final result =
            target.argumentTemplates.get('AFormField', 'paramDefault');
        expect(result.imports, isEmpty);
        expect(result.itemTemplate, isNull);
        expect(result.value, '#ARGUMENT#');
      });
    });
  });

  group('custom_namings', () {
    test('single items string maps can be parsed', () {
      final target = Config(<String, dynamic>{
        'custom_namings': {
          'Test01': {
            'form_properties_builder': {'build': 'build1'}
          }
        },
      });
      final result = target.customNamings['Test01'];
      expect(result, isNotNull);
      expect(result!.formPropertiesBuilder, isNotNull);
      expect(result.formPropertiesBuilder!.build, 'build1');
    });

    test('mutiple items string maps can be parsed', () {
      final target = Config(<String, dynamic>{
        'custom_namings': {
          'Test01': {
            'form_properties_builder': {'build': 'build1'}
          },
          'Test02': {
            'form_properties_builder': {'build': 'build2'}
          }
        },
      });
      final result1 = target.customNamings['Test01'];
      expect(result1, isNotNull);
      expect(result1!.formPropertiesBuilder, isNotNull);
      expect(result1.formPropertiesBuilder!.build, 'build1');

      final result2 = target.customNamings['Test02'];
      expect(result2, isNotNull);
      expect(result2!.formPropertiesBuilder, isNotNull);
      expect(result2.formPropertiesBuilder!.build, 'build2');
    });

    test('empty maps is harmless', () {
      final target = Config(<String, dynamic>{
        'custom_namings': <String, String>{},
      });
      expect(target.customNamings, isNotNull);
    });

    test('non map causes error', () {
      final target = Config(<String, dynamic>{
        'custom_namings': 0,
      });
      expect(
        () => target.customNamings,
        throwsA(
          isA<AnalysisException>().having(
            (e) => e.message,
            'message',
            "Unexpected value type of 'custom_namings'. "
                'Value must be mapping of string key and '
                'PresenterCustomNamings value, but int.',
          ),
        ),
      );
    });

    test('error message is cached', () {
      final target = Config(<String, dynamic>{
        'custom_namings': 0,
      });
      late final AnalysisException firstError;
      late final StackTrace firstStackTrace;
      try {
        final _ = target.customNamings;
      } on AnalysisException catch (e, s) {
        firstError = e;
        firstStackTrace = s;
      }

      try {
        final _ = target.customNamings;
      } on AnalysisException catch (e, s) {
        expect(e.message, firstError.message);
        expect(s.toString(), isNot(firstStackTrace.toString()));
      }
    });

    test('can access undefined type and name', () {
      final target = Config(<String, dynamic>{
        'custom_namings': {
          'Test01': {
            'form_properties_builder': {'build': 'build1'}
          }
        },
      });
      final result = target.customNamings['Test02'];
      expect(result, isNull);
      expect(result?.formPropertiesBuilder, isNull);
      expect(result?.formPropertiesBuilder?.build, isNull);
    });

    test('non string keys cause error', () {
      final target = Config(<String, dynamic>{
        'custom_namings': {
          0: '0',
        },
      });
      expect(
        () => target.customNamings,
        throwsA(
          isA<AnalysisException>().having(
            (e) => e.message,
            'message',
            "Unexpected key type of '0' property of 'custom_namings'. Keys must be string, but int.",
          ),
        ),
      );
    });

    test('non string values cause error', () {
      final target = Config(<String, dynamic>{
        'custom_namings': {
          'Test01': 0,
        },
      });
      expect(
        () => target.customNamings,
        throwsA(
          isA<AnalysisException>().having(
            (e) => e.message,
            'message',
            "Unexpected value type of 'Test01' property of 'custom_namings'. "
                'Value must be mapping of string key and mapping value, but int.',
          ),
        ),
      );
    });

    test('non string type keys cause error', () {
      final target = Config(<String, dynamic>{
        'custom_namings': {
          'Test01': {
            0: '0',
          }
        },
      });
      expect(
        () => target.customNamings,
        throwsA(
          isA<AnalysisException>().having(
            (e) => e.message,
            'message',
            "Unexpected key type of '0' property of 'Test01' property of 'custom_namings'. "
                'Keys must be string, but int.',
          ),
        ),
      );
    });

    test('non string type values cause error', () {
      final target = Config(<String, dynamic>{
        'custom_namings': {
          'Test01': {
            'form_properties_builder': 0,
          }
        }
      });
      expect(
        () => target.customNamings,
        throwsA(
          isA<AnalysisException>().having(
            (e) => e.message,
            'message',
            "Unexpected value type of 'form_properties_builder' property of 'Test01' property of 'custom_namings'. "
                'Value must be mapping of string key and string or null value, but int.',
          ),
        ),
      );
    });

    test('unknown type values are halmless', () {
      final target = Config(<String, dynamic>{
        'custom_namings': {
          'Test01': {
            'form_properties_builder': {'build': 'build1'},
            'awesome_type': {'foo': 'bar'},
            'aweful_type': {'boo': 'hoge'},
          }
        }
      });

      final result = target.customNamings['Test01'];
      expect(result, isNotNull);
      expect(result!.formPropertiesBuilder, isNotNull);
      expect(result.formPropertiesBuilder!.build, 'build1');
    });

    test('non string name keys cause error', () {
      final target = Config(<String, dynamic>{
        'custom_namings': {
          'Test01': {
            'form_properties_builder': {
              0: '0',
            }
          }
        },
      });
      expect(
        () => target.customNamings,
        throwsA(
          isA<AnalysisException>().having(
            (e) => e.message,
            'message',
            "Unexpected key type of '0' property of 'form_properties_builder' property of 'Test01' property of 'custom_namings'. "
                'Keys must be string, but int.',
          ),
        ),
      );
    });

    test('non string name values cause error', () {
      final target = Config(<String, dynamic>{
        'custom_namings': {
          'Test01': {
            'form_properties_builder': {'build': 0},
          }
        }
      });
      expect(
        () => target.customNamings,
        throwsA(
          isA<AnalysisException>().having(
            (e) => e.message,
            'message',
            "Unexpected value type of 'build' property of 'form_properties_builder' property of 'Test01' property of 'custom_namings'. "
                'Values must be string or null, but int.',
          ),
        ),
      );
    });

    test('unknown name values are halmless', () {
      final target = Config(<String, dynamic>{
        'custom_namings': {
          'Test01': {
            'form_properties_builder': {
              'build': 'build1',
              'awesome': 'foo',
              'aweful': 'bar',
            }
          }
        }
      });

      final result = target.customNamings['Test01'];
      expect(result, isNotNull);
      expect(result!.formPropertiesBuilder, isNotNull);
      expect(result.formPropertiesBuilder!.build, 'build1');
    });
  });
}
