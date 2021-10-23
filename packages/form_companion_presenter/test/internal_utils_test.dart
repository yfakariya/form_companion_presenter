// See LICENCE file in the root.

import 'dart:async';

import 'package:flutter_test/flutter_test.dart';

import 'package:form_companion_presenter/src/internal_utils.dart';

void main() {
  group('logger', () {
    void doTest(
      LogLevel expectedLevel,
      void Function(Logger, Object?, Zone?, Object?, StackTrace?) logging,
    ) {
      const name = 'Logger';
      const message = 'Test';
      final zone = Zone.current;
      final error = Error();
      final stackTrace = StackTrace.current;

      final logger = Logger(name: name);
      final oldSink = loggerSink;
      try {
        late String? actualName;
        late LogLevel actualLevel;
        late Object? actualMessage;
        late Zone? actualZone;
        late Object? actualError;
        late StackTrace? actualStackTrace;
        loggerSink = (n, l, m, z, e, s) {
          actualName = n;
          actualLevel = l;
          actualMessage = m;
          actualZone = z;
          actualError = e;
          actualStackTrace = s;
        };

        logging(logger, message, zone, error, stackTrace);

        expect(actualName, equals(name));
        expect(actualLevel, equals(expectedLevel));
        expect(actualMessage, equals(message));
        expect(actualZone, same(zone));
        expect(actualError, same(error));
        expect(actualStackTrace, same(stackTrace));
      } finally {
        loggerSink = oldSink;
      }
    }

    test(
        'fine: LogLevel is fine and all arguments and name are passed to sink.',
        () {
      doTest(
        LogLevel.fine,
        (
          logger,
          message,
          zone,
          error,
          stackTrace,
        ) =>
            logger.fine(
          message,
          zone: zone,
          error: error,
          stackTrace: stackTrace,
        ),
      );
    });

    test(
        'info: LogLevel is info and all arguments and name are passed to sink.',
        () {
      doTest(
        LogLevel.info,
        (
          logger,
          message,
          zone,
          error,
          stackTrace,
        ) =>
            logger.info(
          message,
          zone: zone,
          error: error,
          stackTrace: stackTrace,
        ),
      );
    });

    test(
        'warning: LogLevel is warning and all arguments and name are passed to sink.',
        () {
      doTest(
        LogLevel.warning,
        (
          logger,
          message,
          zone,
          error,
          stackTrace,
        ) =>
            logger.warning(
          message,
          zone: zone,
          error: error,
          stackTrace: stackTrace,
        ),
      );
    });

    test(
        'severe: LogLevel is severe and all arguments and name are passed to sink.',
        () {
      doTest(
        LogLevel.severe,
        (
          logger,
          message,
          zone,
          error,
          stackTrace,
        ) =>
            logger.severe(
          message,
          zone: zone,
          error: error,
          stackTrace: stackTrace,
        ),
      );
    });
  });
}
