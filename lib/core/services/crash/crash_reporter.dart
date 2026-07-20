import 'package:flutter/foundation.dart';

/// Crash reporting abstraction (Crashlytics/Sentry drop in behind this).
abstract interface class CrashReporter {
  Future<void> recordError(
    Object error,
    StackTrace stackTrace, {
    bool fatal = false,
  });

  Future<void> log(String message);
}

class DebugCrashReporter implements CrashReporter {
  const DebugCrashReporter();

  @override
  Future<void> recordError(
    Object error,
    StackTrace stackTrace, {
    bool fatal = false,
  }) async {
    if (kDebugMode) {
      debugPrint('[crash] ${fatal ? 'FATAL ' : ''}$error\n$stackTrace');
    }
  }

  @override
  Future<void> log(String message) async {
    if (kDebugMode) debugPrint('[crash-log] $message');
  }
}
