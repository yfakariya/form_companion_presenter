// See LICENCE file in the root.

import 'dart:io';

import 'package:format/format.dart';
import 'package:grinder/grinder.dart';
import 'package:path/path.dart';

enum _Mode { auto, manual }

extension _ModeExtension on _Mode {
  String toTitleCase() => this == _Mode.auto ? 'Auto' : 'Manual';
  String toLowerCase() => this == _Mode.auto ? 'auto' : 'manual';
}

enum _Flavor { vanillaForm, formBuilder }

extension _FlavorExtension on _Flavor {
  String toTitleCase() =>
      this == _Flavor.formBuilder ? 'FormBuilder' : 'VanillaForm';
}

enum _Model { account, booking }

extension _ModelExtension on _Model {
  String toTitleCase() => this == _Model.account ? 'Account' : 'Booking';
  String toLowerCase() => this == _Model.account ? 'account' : 'booking';
}

final _macroRegexp = RegExp(
  '//!macro\\s*(?<Id>\\w+)(\\s+(?<Arg>\\S+))?\\s*',
  unicode: true,
);

// Note: indent are handled by "dart format --fix" after generation,
//       but newline and indent of comments are not inserted ideally.

const _headerNoteSeparator =
    '''//------------------------------------------------------------------------------
''';

const _headerNoteBuilder =
    '''// Note that FormBuilderFields requires unique names and they must be identical
// to names for `PropertyDescriptor`s.
''';

const _headerNoteVanilla =
    '''// Note that vanilla FormFields requires settings key and onSaved callbacks.
''';

const _headerNoteManual = '''// There are 2 differences from Auto* variant:
//   1. Of cource, `autoValidateMode` is set to `AutovalidateMode.disabled`
//      in `Form` constructor.
//   2. The override of `doSubmit` calls `validateAndSave()` and returns
//      immediately when the validation is failed.
''';

const _pageDocumentTemplate =
    '''/// Page for [{model}] input which just declares [{flavor}].
///
/// This class is required to work [CompanionPresenterMixin] correctly
/// because it uses [{flavor}.of] to access form state which requires
/// [{flavor}] exists in ancestor of element tree ([BuildContext]).
''';

const _fieldInitVanilla = '''key: presenter.getKey('{0}', context),
''';

const _fieldInitBuilder = '''name: '{0}',
''';

const _dropDownInitVanilla = '''value: state.{0},
''';

const _dropDownInitBuilder = '''initialValue: state.{0},
''';

const _validateModeAuto =
    '''autovalidateMode: AutovalidateMode.onUserInteraction,
''';

const _validateModeManual = '''autovalidateMode: AutovalidateMode.disabled,
''';

const _preferredRegionsAssignmentVanilla = '''preferredRegions: [],
''';
const _preferredRegionsAssignmentBuilder =
    '''preferredRegions: preferredRegions,
''';

Future<void> assembleCore(
  String sourceDirectory,
  String destinationDirectory,
) async {
  log(
    'Assembly example source from "${canonicalize(sourceDirectory)}" '
    'to "${canonicalize(destinationDirectory)}"',
  );

  for (final mode in _Mode.values) {
    for (final flavor in _Flavor.values) {
      for (final model in _Model.values) {
        if (flavor == _Flavor.vanillaForm && model == _Model.booking) {
          // This combination will not be generated.
          continue;
        }

        final replacementMap = {
          '${model.toTitleCase()}PageTemplate':
              '${mode.toTitleCase()}Validation${flavor.toTitleCase()}${model.toTitleCase()}Page',
          '_${model.toTitleCase()}PaneTemplate':
              '_${mode.toTitleCase()}Validation${flavor.toTitleCase()}${model.toTitleCase()}Pane',
          '${model.toTitleCase()}PresenterTemplate':
              '${mode.toTitleCase()}Validation${flavor.toTitleCase()}${model.toTitleCase()}Presenter',
          "'TITLE_TEMPLATE'": 'LocaleKeys.${mode.toLowerCase()}_'
              '${flavor == _Flavor.vanillaForm ? 'vanilla' : 'flutterFormBuilder${model.toTitleCase()}'}_title.tr()',
          "import '../": "import '",
        };
        if (flavor == _Flavor.vanillaForm) {
          replacementMap['FormBuilderTextField'] = 'TextFormField';
          replacementMap['FormBuilderDropdown'] = 'DropdownButtonFormField';
          replacementMap['FormBuilderCheckboxGroup'] =
              'DropdownButtonFormField';
          replacementMap[r'FormBuilder\('] = 'Form(';
          replacementMap['FormBuilderCompanionMixin'] = 'FormCompanionMixin';
        }

        final replamentRegexp = replacementMap.entries
            .map((entry) => MapEntry(RegExp(entry.key), entry.value));

        final macroMap = _setupMacro(mode, model, flavor);

        final removalImports = flavor == _Flavor.formBuilder
            ? <String>{}
            : {
                "import 'package:flutter_form_builder/flutter_form_builder.dart';",
                "import 'package:form_builder_companion_presenter/form_builder_companion_presenter.dart';"
              };

        // read
        final source = File('$sourceDirectory/${model.toLowerCase()}.dart');
        final destinationFile = File(
          '$destinationDirectory/'
          '${mode.toLowerCase()}_validation_'
          '${flavor == _Flavor.vanillaForm ? 'vanilla_form' : 'form_builder_${model.toLowerCase()}'}'
          '.dart',
        );
        final destination = destinationFile.openWrite();
        try {
          final output = _OutputController(destination);
          for (var line in await source.readAsLines()) {
            if (removalImports.contains(line)) {
              continue;
            }

            // process macro with regexp
            final macroMatch = _macroRegexp.firstMatch(line);
            if (macroMatch != null) {
              final macroId = macroMatch.namedGroup('Id')!;
              final macroArg = macroMatch.namedGroup('Arg');
              final macro = macroMap[macroId];
              if (macro == null) {
                throw AssertionError('Unknown macro ID "$macroId"');
              }

              macro(line, macroMatch, macroArg, output);
            } else {
              // process id map with regexp
              for (final idMapper in replamentRegexp) {
                line = line.replaceAll(idMapper.key, idMapper.value);
              }
              output.sink.writeln(line);
            }
          }

          await destination.flush();

          log('Generated "${canonicalize(destinationFile.path)}".');
        } finally {
          await destination.close();
        }

        await Dart.runAsync(
          'format',
          arguments: [
            '--fix',
            destinationFile.path,
          ],
        );
      }
    }
  }
}

typedef _Macro = void Function(
  String sourceLine,
  Match match,
  String? macroArg,
  _OutputController output,
);

Map<String, _Macro> _setupMacro(_Mode mode, _Model model, _Flavor flavor) {
  final headerNote = StringBuffer()..write(_headerNoteSeparator);
  if (mode == _Mode.manual) {
    headerNote.write(_headerNoteManual);
  }
  switch (flavor) {
    case _Flavor.formBuilder:
      headerNote.write(_headerNoteBuilder);
      break;
    case _Flavor.vanillaForm:
      headerNote.write(_headerNoteVanilla);
      break;
  }
  headerNote.write(_headerNoteSeparator);

  final simpleMacros = {
    'headerNote': headerNote.toString(),
    'pageDocument': format(
      _pageDocumentTemplate,
      {
        'model': model.toTitleCase(),
        'flavor': flavor == _Flavor.formBuilder ? 'FormBuilder' : 'Form'
      },
    ),
    'fieldInit':
        flavor == _Flavor.vanillaForm ? _fieldInitVanilla : _fieldInitBuilder,
    'dropDownInit': flavor == _Flavor.vanillaForm
        ? _dropDownInitVanilla
        : _dropDownInitBuilder,
    'validateMode':
        mode == _Mode.auto ? _validateModeAuto : _validateModeManual,
    'preferredRegionsAssignment': flavor == _Flavor.vanillaForm
        ? _preferredRegionsAssignmentVanilla
        : _preferredRegionsAssignmentBuilder,
  };

  return simpleMacros.map((key, value) => MapEntry(
        key,
        (_, match, macroArg, output) {
          if (macroArg == null) {
            // without newline here.
            output.sink.write(value);
          } else {
            output.sink.write(format(value, macroArg));
          }
        },
      ))
    ..['beginBuilderOnly'] = (line, match, arg, output) {
      if (flavor != _Flavor.formBuilder) {
        output.enable = false;
      }
      // Line itself is not written.
    }
    ..['endBuilderOnly'] = (line, match, arg, output) {
      if (flavor != _Flavor.formBuilder) {
        output.enable = true;
      }
      // Line itself is not written.
    }
    ..['beginVanillaOnly'] = (line, match, arg, output) {
      if (flavor != _Flavor.vanillaForm) {
        output.enable = false;
      }
      // Line itself is not written.
    }
    ..['endVanillaOnly'] = (line, match, arg, output) {
      if (flavor != _Flavor.vanillaForm) {
        output.enable = true;
      }
      // Line itself is not written.
    };
}

final _nullSink = _NullStringSink();

class _NullStringSink extends StringSink {
  @override
  void write(Object? object) {}

  @override
  void writeAll(Iterable<dynamic> objects, [String separator = '']) {}

  @override
  void writeCharCode(int charCode) {}

  @override
  void writeln([Object? object = '']) {}
}

class _OutputController {
  final StringSink _sink;
  bool enable = true;
  StringSink get sink => enable ? _sink : _nullSink;

  _OutputController(this._sink);
}
