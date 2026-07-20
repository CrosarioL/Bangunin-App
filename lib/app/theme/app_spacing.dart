import 'package:flutter/widgets.dart';

/// 4pt spacing rhythm used across every screen.
abstract final class AppSpacing {
  static const double xs = 4;
  static const double sm = 8;
  static const double md = 12;
  static const double lg = 16;
  static const double xl = 24;
  static const double xxl = 32;
  static const double xxxl = 48;

  static const screenPadding = EdgeInsets.symmetric(horizontal: lg);

  /// Corner radii — chunky and playful (Duolingo-style): fat rounded
  /// everything. Cards and buttons share the same generous curve.
  static const double radiusCard = 20;
  static const double radiusControl = 16;
  static const double radiusButton = 16;
  static const double radiusCapsule = 100;

  /// Depth of the solid 3D "lip" under push-buttons and the hard offset
  /// under cards — the signature chunky, physical, un-glassy shadow.
  static const double buttonLip = 5;
  static const double cardLip = 4;
}
