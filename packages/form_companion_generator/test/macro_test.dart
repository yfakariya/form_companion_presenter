// See LICENCE file in the root.

import 'package:form_companion_generator/src/config.dart';
import 'package:form_companion_generator/src/macro.dart';
import 'package:source_gen/source_gen.dart';
import 'package:test/test.dart';

import 'test_helpers.dart';

Future<void> main() async {
  final typeProvider = (await getParametersLibrary()).typeProvider;

  ArgumentMacroContext createTarget(NamedTemplates namedTemplates) =>
      ArgumentMacroContext(
        propertyName: 'prop',
        propertyValueType: 'P',
        fieldValueType: 'F',
        property: 'property__',
        buildContext: 'context_',
        presenter: 'presenter_',
        autovalidateMode: 'AutovalidateMode.onUserInteraction',
        namedTemplates: namedTemplates,
        itemValue: 'v',
        itemValueType: 'E',
        itemValueString: 'v.toString()',
      ).withArgument(
        argument: 'arg',
        parameterType: typeProvider.doubleType,
        defaultValue: "'default'",
      );

  const baseInput = '#PROPERTY_NAME#|#PROPERTY_VALUE_TYPE#|#FIELD_VALUE_TYPE#|'
      '#PROPERTY#|#BUILD_CONTEXT#|#PRESENTER#|#AUTO_VALIDATE_MODE#|'
      '#ITEM_VALUE#|#ITEM_VALUE_TYPE#|#ITEM_VALUE_STRING#|'
      '#ARGUMENT#|#PARAMETER_TYPE#|#DEFAULT_VALUE#';

  const baseResult = 'prop|P|F|property__|context_|presenter_|'
      'AutovalidateMode.onUserInteraction|v|E|v.toString()|arg|double|'
      "'default'";

  test(
    'All known context values replaced',
    () {
      final target =
          createTarget(NamedTemplates({'THE_TEMPLATE': 'theTemplate'}));

      expect(
        target.resolve('CONTEXT', '$baseInput|#THE_TEMPLATE#'),
        '$baseResult|theTemplate',
      );
    },
  );

  test(
    'Macro in named template can be resolved',
    () {
      final target =
          createTarget(NamedTemplates({'THE_TEMPLATE': '#ARGUMENT#'}));

      expect(
        target.resolve('CONTEXT', '$baseInput|#THE_TEMPLATE#'),
        '$baseResult|arg',
      );
    },
  );

  test(
    'Recursive macro in named template cannot be resolved',
    () {
      final target = createTarget(
        NamedTemplates(
          {
            'THE_TEMPLATE': '#ANOTHER_TEMPLATE#',
            'ANOTHER_TEMPLATE': 'OK',
          },
        ),
      );

      expect(
        () => target.resolve('CONTEXT', '$baseInput|#THE_TEMPLATE#'),
        throwsA(
          isA<InvalidGenerationSourceError>()
              .having(
                (p) => p.message,
                'message',
                'Unknown macro `#ANOTHER_TEMPLATE#` in CONTEXT, position: 212.',
              )
              .having(
                (p) => p.todo,
                'todo',
                'Revise template in the `build.yaml` file.',
              ),
        ),
      );
    },
  );

  test(
    'Unknown macro in named template cannot be resolved',
    () {
      final target = createTarget(
        NamedTemplates({}),
      );

      expect(
        () => target.resolve('CONTEXT', '$baseInput|#THE_TEMPLATE#'),
        throwsA(
          isA<InvalidGenerationSourceError>()
              .having(
                (p) => p.message,
                'message',
                'Unknown macro `#THE_TEMPLATE#` in CONTEXT, position: 212.',
              )
              .having(
                (p) => p.todo,
                'todo',
                'Revise template in the `build.yaml` file.',
              ),
        ),
      );
    },
  );
}
