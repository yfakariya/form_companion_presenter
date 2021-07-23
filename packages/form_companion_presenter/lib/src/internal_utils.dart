// See LICENCE file in the root.

import 'dart:async';

import 'package:meta/meta.dart';

/// Helps distinction between "set" null-value and "not set" any value for
/// nullable type.
@sealed
class NullableValueHolder<T> {
  /// Value itself.
  ///
  /// Note that [value] can be `null` when [T] is nullable.
  final T value;

  /// Creates new [NullableValueHolder].
  ///
  /// Note that [value] can be `null` when [T] is nullable.
  NullableValueHolder(this.value);
}

// Compatible with package:logging https://github.com/dart-lang/logging/blob/9d9fd5a83f52649264e34605ffa2d364d73316f4/lib/src/level.dart
/// Represents log level.
@sealed
class LogLevel {
  /// Name of this value.
  final String name;

  /// Numeric value of this value.
  final int level;

  /// Creates new [LogLevel] with specified [name] and [level].
  const LogLevel(this.name, this.level);

  /// Events to be respond immediately.
  static const severe = LogLevel('SEVERE', 1000);

  /// Events to be watched continuously.
  static const warning = LogLevel('WARNING', 900);

  /// Events to be recorded.
  static const info = LogLevel('INFO', 800);

  /// Events to be reported to developers.
  static const fine = LogLevel('FINE', 500);
}

/// A function which is called to write log records from [Logger].
///
/// See [LoggerSink] documentation for details.
// ignore: prefer_function_declarations_over_variables
LoggerSink loggerSink = (name, level, message, zone, error, stackTrace) {
  // nop
};

// Compatible with dart:developer/log

/// Represents a function to be set to [loggerSink].
///
/// This function is compatible with `log` function of `dart:developer` and
/// other logging frameworks including `logging` package.
///
/// You can specify [message] as [String], [Function] which returns [String],
/// or any [Object]. If [message] is [Function], [LoggerSink] MAY call it to
/// get actual message. If [message] is [Object], [LoggerSink] MAY call its
/// [Object.toString] method to get actual message. These behavior is NOT
/// guaranteed, but standard `logging` package will do, and you can implement
/// your custom [LoggerSink] as adapter between this expectation and the
/// specification of the logging framework you use.
typedef LoggerSink = void Function(
  String name,
  LogLevel level,
  Object? message,
  Zone? zone,
  Object? error,
  StackTrace? stackTrace,
);

/// Simple logging to decouple with external logging framework.
class Logger {
  late String _name;

  /// Creates a new logger with specified [name].
  ///
  /// If [name] is omitted, a value of [toString] will be used.
  /// This value will be emitted as `name` parameter to [LoggerSink].
  Logger({
    String? name,
  }) {
    _name = name ?? toString();
  }

  /// Logs event as specified [level].
  void log(
    LogLevel level,
    Object? message, {
    Zone? zone,
    Object? error,
    StackTrace? stackTrace,
  }) =>
      loggerSink(
        _name,
        level,
        message,
        zone,
        error,
        stackTrace,
      );

  /// Logs event as [LogLevel.severe].
  void severe(
    Object? message, {
    Zone? zone,
    Object? error,
    StackTrace? stackTrace,
  }) =>
      log(
        LogLevel.severe,
        message,
        zone: zone,
        error: error,
        stackTrace: stackTrace,
      );

  /// Logs event as [LogLevel.warning].
  void warning(
    Object? message, {
    Zone? zone,
    Object? error,
    StackTrace? stackTrace,
  }) =>
      log(
        LogLevel.warning,
        message,
        zone: zone,
        error: error,
        stackTrace: stackTrace,
      );

  /// Logs event as [LogLevel.info].
  void info(
    Object? message, {
    Zone? zone,
    Object? error,
    StackTrace? stackTrace,
  }) =>
      log(
        LogLevel.info,
        message,
        zone: zone,
        error: error,
        stackTrace: stackTrace,
      );

  /// Logs event as [LogLevel.fine].
  void fine(
    Object? message, {
    Zone? zone,
    Object? error,
    StackTrace? stackTrace,
  }) =>
      log(
        LogLevel.fine,
        message,
        zone: zone,
        error: error,
        stackTrace: stackTrace,
      );
}
