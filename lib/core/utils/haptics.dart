import 'package:flutter/services.dart';

/// Centralized haptic vocabulary so every interaction uses the same feedback
/// grammar: light for selection, medium for commits, heavy for success.
abstract final class Haptics {
  static void selection() => HapticFeedback.selectionClick();

  static void tap() => HapticFeedback.lightImpact();

  static void commit() => HapticFeedback.mediumImpact();

  static void success() => HapticFeedback.heavyImpact();

  static void warning() => HapticFeedback.vibrate();
}
