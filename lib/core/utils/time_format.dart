import 'package:flutter/material.dart';

/// Time/duration formatting helpers shared by home, editor and stats.
abstract final class TimeFormat {
  static String clock(BuildContext context, int hour, int minute) {
    return TimeOfDay(hour: hour, minute: minute).format(context);
  }

  /// "7h 32m" / "42m" / "<1m" — used by the next-alarm countdown.
  static String countdown(Duration d) {
    if (d.inMinutes < 1) return '<1m';
    final hours = d.inHours;
    final minutes = d.inMinutes % 60;
    if (hours == 0) return '${minutes}m';
    return '${hours}h ${minutes}m';
  }

  /// Minutes-after-midnight to a localized clock string.
  static String minutesToClock(BuildContext context, int minutes) =>
      clock(context, minutes ~/ 60, minutes % 60);
}
