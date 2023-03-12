// See LICENCE file in the root.

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:form_companion_presenter/form_companion_presenter.dart';

void main() {
  group('RestorableValueFactories', () {
    test('stringRestorableValueFactory returns RestorableStringN', () {
      final result = stringRestorableValueFactory();
      expect(result, isA<RestorableStringN>());
    });

    test('intRestorableValueFactory returns RestorableIntN', () {
      final result = intRestorableValueFactory();
      expect(result, isA<RestorableIntN>());
    });

    test('doubleRestorableValueFactory returns RestorableDoubleN', () {
      final result = doubleRestorableValueFactory();
      expect(result, isA<RestorableDoubleN>());
    });

    test('boolRestorableValueFactory returns RestorableBoolN', () {
      final result = boolRestorableValueFactory();
      expect(result, isA<RestorableBoolN>());
    });

    test('bigIntRestorableValueFactory returns RestorableValue<BigInt?>', () {
      final result = bigIntRestorableValueFactory();
      expect(result, isA<RestorableValue<BigInt?>>());
    });

    test('enumRestorableValueFactory<T> returns RestorableValue<T?>', () {
      final result =
          enumRestorableValueFactory<Brightness>(Brightness.values)();
      expect(result, isA<RestorableValue<Brightness?>>());
    });

    test('enumListRestorableValueFactory<T> returns RestorableValue<List<T>?>',
        () {
      final result =
          enumListRestorableValueFactory<Brightness>(Brightness.values)();
      expect(result, isA<RestorableValue<List<Brightness>?>>());
    });

    test('dateTimeRestorableValueFactory returns RestorableDateTimeN', () {
      final result = dateTimeRestorableValueFactory();
      expect(result, isA<RestorableDateTimeN>());
    });

    test(
      'dateTimeRangeRestorableValueFactory returns RestorableValue<DateTimeRange?>',
      () {
        final result = dateTimeRangeRestorableValueFactory();
        expect(result, isA<RestorableValue<DateTimeRange?>>());
      },
    );

    test(
      'rangeValuesRestorableValueFactory returns RestorableValue<RangeValues?>',
      () {
        final result = rangeValuesRestorableValueFactory();
        expect(result, isA<RestorableValue<RangeValues?>>());
      },
    );
  });

  group('RestorableValues', () {
    FutureOr<void> testRestorableValue<T extends Object>(
      WidgetTester tester,
      RestorableValue<T?> Function() factory,
      T? value,
    ) async {
      final widget = MaterialApp(
        restorationScopeId: 'app',
        home: Tester<T>(
          restorationId: 'target',
          factory: factory,
        ),
      );

      await tester.pumpWidget(widget);
      tester.state<TesterState<T>>(find.byType(Tester<T>)).value = value;
      await tester.pumpAndSettle();
      // ignore: invalid_use_of_protected_member
      final binary = (await tester.getRestorationData()).binary!;
      final dynamic data = const StandardMessageCodec().decodeMessage(
        binary.buffer.asByteData(binary.offsetInBytes, binary.length),
      );
      printOnFailure('data: $data');

      await tester.restartAndRestore();
      expect(
        tester.state<TesterState<T>>(find.byType(Tester<T>)).value,
        value,
      );
    }

    FutureOr<void> testRestorationFailure<T extends Object>(
      WidgetTester tester,
      RestorableValue<T?> Function() factory,
      T initialValue,
      void Function(Map<dynamic, dynamic>) breaker, {
      T? expected, // null for scaler, list without invalid entries for list.
    }) async {
      final widget = MaterialApp(
        restorationScopeId: 'app',
        home: Tester<T>(
          restorationId: 'target',
          factory: factory,
        ),
      );

      await tester.pumpWidget(widget);
      tester.state<TesterState<T>>(find.byType(Tester<T>)).value = initialValue;
      await tester.pumpAndSettle();

      // ignore: invalid_use_of_protected_member
      final binary = (await tester.getRestorationData()).binary!;
      final map = const StandardMessageCodec().decodeMessage(
        binary.buffer.asByteData(binary.offsetInBytes, binary.length),
      ) as Map;
      printOnFailure('before: $map');
      breaker(
        ((((((((map['c'] as Map)['app'] as Map)['c'] as Map)['nav'] as Map)['c']
            as Map)['r+0'] as Map)['c'] as Map)['target'] as Map)['v'] as Map,
      );
      printOnFailure('after: $map');
      final newBinary = const StandardMessageCodec().encodeMessage(map)!;
      assert(
        WidgetsBinding.instance.restorationManager is TestRestorationManager,
      );
      // Replace with broken data here.
      // ignore: invalid_use_of_protected_member
      await WidgetsBinding.instance.restorationManager.sendToEngine(
        Uint8List.view(
          newBinary.buffer,
          newBinary.offsetInBytes,
          newBinary.lengthInBytes,
        ),
      );
      await tester.restartAndRestore();
      // If data is broken, null value should be restored
      // because _defaultValue is always null.
      // But for list items, the invalid value just be skipped.
      expect(
        tester.state<TesterState<T>>(find.byType(Tester<T>)).value,
        expected,
      );
    }

    // non-null,
    group('_RestorableBigIntN roundtrips', () {
      testWidgets(
        'Non-null BigInt',
        (tester) async {
          await testRestorableValue(
            tester,
            bigIntRestorableValueFactory,
            BigInt.two,
          );
        },
      );

      testWidgets(
        'null BigInt',
        (tester) async {
          await testRestorableValue<BigInt>(
            tester,
            bigIntRestorableValueFactory,
            null,
          );
        },
      );

      testWidgets(
        'non-string BigInt',
        (tester) async {
          await testRestorationFailure<BigInt>(
            tester,
            bigIntRestorableValueFactory,
            BigInt.two,
            (map) {
              map['target'] = 0;
            },
          );
        },
      );

      testWidgets(
        'non-number string BigInt',
        (tester) async {
          await testRestorationFailure<BigInt>(
            tester,
            bigIntRestorableValueFactory,
            BigInt.two,
            (map) {
              map['target'] = 'x';
            },
          );
        },
      );
    });

    group('_RestorableEnumList<T>', () {
      testWidgets(
        'Non-null, non-empty EnumList<T>',
        (tester) async {
          await testRestorableValue(
            tester,
            enumListRestorableValueFactory(Brightness.values),
            [Brightness.dark, Brightness.light],
          );
        },
      );

      testWidgets(
        'Empty EnumList<T>',
        (tester) async {
          await testRestorableValue(
            tester,
            enumListRestorableValueFactory(Brightness.values),
            <Brightness>[],
          );
        },
      );

      testWidgets(
        'null EnumList<T>',
        (tester) async {
          await testRestorableValue<List<Brightness>>(
            tester,
            enumListRestorableValueFactory(Brightness.values),
            null,
          );
        },
      );

      testWidgets(
        'non-list EnumList<T>',
        (tester) async {
          await testRestorationFailure<List<Brightness>>(
            tester,
            enumListRestorableValueFactory(Brightness.values),
            [Brightness.light],
            (map) {
              map['target'] = 'light';
            },
          );
        },
      );

      testWidgets(
        'non-string item in EnumList<T>',
        (tester) async {
          await testRestorationFailure<List<Brightness>>(
            tester,
            enumListRestorableValueFactory(Brightness.values),
            [Brightness.light],
            (map) {
              map['target'] = [0, 'dark', 1];
            },
            expected: [Brightness.dark],
          );
        },
      );

      testWidgets(
        'non-enum member item in EnumList<T>',
        (tester) async {
          await testRestorationFailure<List<Brightness>>(
            tester,
            enumListRestorableValueFactory(Brightness.values),
            [Brightness.light],
            (map) {
              map['target'] = ['void', 'dark', 'plain'];
            },
            expected: [Brightness.dark],
          );
        },
      );
    });

    group('_RestorableDateTimeRangeN', () {
      testWidgets(
        'Non-null DateTimeRange',
        (tester) async {
          await testRestorableValue(
            tester,
            dateTimeRangeRestorableValueFactory,
            DateTimeRange(
              start: DateTime(2023, 2, 24),
              end: DateTime(2023, 3, 12),
            ),
          );
        },
      );

      testWidgets(
        'null DateTimeRange',
        (tester) async {
          await testRestorableValue<DateTimeRange>(
            tester,
            dateTimeRangeRestorableValueFactory,
            null,
          );
        },
      );

      testWidgets(
        'non-list DateTimeRange',
        (tester) async {
          await testRestorationFailure<DateTimeRange>(
            tester,
            dateTimeRangeRestorableValueFactory,
            DateTimeRange(
              start: DateTime(2023, 2, 24),
              end: DateTime(2023, 3, 12),
            ),
            (map) {
              map['target'] = 0;
            },
          );
        },
      );

      testWidgets(
        'empty-list DateTimeRange',
        (tester) async {
          await testRestorationFailure<DateTimeRange>(
            tester,
            dateTimeRangeRestorableValueFactory,
            DateTimeRange(
              start: DateTime(2023, 2, 24),
              end: DateTime(2023, 3, 12),
            ),
            (map) {
              map['target'] = <int>[];
            },
          );
        },
      );

      testWidgets(
        'three-item-list DateTimeRange',
        (tester) async {
          await testRestorationFailure<DateTimeRange>(
            tester,
            dateTimeRangeRestorableValueFactory,
            DateTimeRange(
              start: DateTime(2023, 2, 24),
              end: DateTime(2023, 3, 12),
            ),
            (map) {
              map['target'] = [0, 1, 2];
            },
          );
        },
      );

      testWidgets(
        'non-int item at 0 DateTimeRange',
        (tester) async {
          await testRestorationFailure<DateTimeRange>(
            tester,
            dateTimeRangeRestorableValueFactory,
            DateTimeRange(
              start: DateTime(2023, 2, 24),
              end: DateTime(2023, 3, 12),
            ),
            (map) {
              map['target'] = ['0', 1];
            },
          );
        },
      );

      testWidgets(
        'non-int item at 1 DateTimeRange',
        (tester) async {
          await testRestorationFailure<DateTimeRange>(
            tester,
            dateTimeRangeRestorableValueFactory,
            DateTimeRange(
              start: DateTime(2023, 2, 24),
              end: DateTime(2023, 3, 12),
            ),
            (map) {
              map['target'] = [0, '1'];
            },
          );
        },
      );
    });

    group('_RestorableRangeValuesN', () {
      testWidgets(
        'Non-null RangeValues',
        (tester) async {
          await testRestorableValue(
            tester,
            rangeValuesRestorableValueFactory,
            RangeValues(0.1, 9.9),
          );
        },
      );

      testWidgets(
        'null RangeValues',
        (tester) async {
          await testRestorableValue<RangeValues>(
            tester,
            rangeValuesRestorableValueFactory,
            null,
          );
        },
      );

      testWidgets(
        'non-list RangeValues',
        (tester) async {
          await testRestorationFailure<RangeValues>(
            tester,
            rangeValuesRestorableValueFactory,
            RangeValues(0.1, 9.9),
            (map) {
              map['target'] = 0;
            },
          );
        },
      );

      testWidgets(
        'empty-list RangeValues',
        (tester) async {
          await testRestorationFailure<RangeValues>(
            tester,
            rangeValuesRestorableValueFactory,
            RangeValues(0.1, 9.9),
            (map) {
              map['target'] = <int>[];
            },
          );
        },
      );

      testWidgets(
        'three-item-list RangeValues',
        (tester) async {
          await testRestorationFailure<RangeValues>(
            tester,
            rangeValuesRestorableValueFactory,
            RangeValues(0.1, 9.9),
            (map) {
              map['target'] = [0.1, 9.9, 99.9];
            },
          );
        },
      );

      testWidgets(
        'non-double item at 0 RangeValues',
        (tester) async {
          await testRestorationFailure<RangeValues>(
            tester,
            rangeValuesRestorableValueFactory,
            RangeValues(0.1, 9.9),
            (map) {
              map['target'] = ['0.1', 9.9];
            },
          );
        },
      );

      testWidgets(
        'non-double item at 1 RangeValues',
        (tester) async {
          await testRestorationFailure<RangeValues>(
            tester,
            rangeValuesRestorableValueFactory,
            RangeValues(0.1, 9.9),
            (map) {
              map['target'] = [0.1, '9.9'];
            },
          );
        },
      );
    });
  });
}

class Tester<T extends Object> extends StatefulWidget {
  final String restorationId;
  final RestorableValue<T?> Function() factory;

  Tester({
    super.key,
    required this.restorationId,
    required this.factory,
  });

  @override
  TesterState<T> createState() => TesterState<T>(factory);
}

class TesterState<T extends Object> extends State<Tester>
    with RestorationMixin {
  late final RestorableValue<T?> _value;
  TesterState(RestorableValue<T?> Function() factory) {
    _value = factory();
  }

  @override
  Widget build(BuildContext context) => SizedBox(width: 1, height: 1);

  @override
  String? get restorationId => widget.restorationId;

  T? get value => _value.value;
  void set value(T? v) {
    setState(() {
      _value.value = v;
    });
  }

  @override
  void restoreState(RestorationBucket? oldBucket, bool initialRestore) {
    registerForRestoration(_value, restorationId!);
  }
}
