import 'package:logger/logger.dart';

/// Logger utility class for standardized logging across the app
class AppLogger {
  static final Logger _logger = Logger(
    printer: PrettyPrinter(
      methodCount: 2,
      errorMethodCount: 8,
      lineLength: 120,
      colors: true,
      printEmojis: true,
      dateTimeFormat: DateTimeFormat.onlyTimeAndSinceStart,
    ),
  );

  // Category loggers
  static final Logger auth = Logger(
    printer: PrefixPrinter(PrettyPrinter(
      methodCount: 2,
      errorMethodCount: 8,
      lineLength: 120,
      colors: true,
      printEmojis: true,
      dateTimeFormat: DateTimeFormat.onlyTimeAndSinceStart,
    ), debug: '[AUTH] ', info: '[AUTH] ', warning: '[AUTH] ', error: '[AUTH] '),
  );

  static final Logger sync = Logger(
    printer: PrefixPrinter(PrettyPrinter(
      methodCount: 2,
      errorMethodCount: 8,
      lineLength: 120,
      colors: true,
      printEmojis: true,
      dateTimeFormat: DateTimeFormat.onlyTimeAndSinceStart,
    ), debug: '[SYNC] ', info: '[SYNC] ', warning: '[SYNC] ', error: '[SYNC] '),
  );

  static final Logger gps = Logger(
    printer: PrefixPrinter(PrettyPrinter(
      methodCount: 2,
      errorMethodCount: 8,
      lineLength: 120,
      colors: true,
      printEmojis: true,
      dateTimeFormat: DateTimeFormat.onlyTimeAndSinceStart,
    ), debug: '[GPS] ', info: '[GPS] ', warning: '[GPS] ', error: '[GPS] '),
  );

  static final Logger campaign = Logger(
    printer: PrefixPrinter(PrettyPrinter(
      methodCount: 2,
      errorMethodCount: 8,
      lineLength: 120,
      colors: true,
      printEmojis: true,
      dateTimeFormat: DateTimeFormat.onlyTimeAndSinceStart,
    ), debug: '[CAMPAIGN] ', info: '[CAMPAIGN] ', warning: '[CAMPAIGN] ', error: '[CAMPAIGN] '),
  );

  static final Logger permission = Logger(
    printer: PrefixPrinter(PrettyPrinter(
      methodCount: 2,
      errorMethodCount: 8,
      lineLength: 120,
      colors: true,
      printEmojis: true,
      dateTimeFormat: DateTimeFormat.onlyTimeAndSinceStart,
    ), debug: '[PERMISSION] ', info: '[PERMISSION] ', warning: '[PERMISSION] ', error: '[PERMISSION] '),
  );

  // General logger for uncategorized logs
  static Logger get general => _logger;

  // Convenience methods for general logging
  static void t(dynamic message, [dynamic error, StackTrace? stackTrace]) {
    _logger.t(message, error: error, stackTrace: stackTrace);
  }

  static void d(dynamic message, [dynamic error, StackTrace? stackTrace]) {
    _logger.d(message, error: error, stackTrace: stackTrace);
  }

  static void i(dynamic message, [dynamic error, StackTrace? stackTrace]) {
    _logger.i(message, error: error, stackTrace: stackTrace);
  }

  static void w(dynamic message, [dynamic error, StackTrace? stackTrace]) {
    _logger.w(message, error: error, stackTrace: stackTrace);
  }

  static void e(dynamic message, [dynamic error, StackTrace? stackTrace]) {
    _logger.e(message, error: error, stackTrace: stackTrace);
  }

  static void f(dynamic message, [dynamic error, StackTrace? stackTrace]) {
    _logger.f(message, error: error, stackTrace: stackTrace);
  }
}