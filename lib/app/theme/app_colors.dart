import 'package:flutter/material.dart';

/// Bangunin brand palette: a deep midnight-navy night sky with an
/// electric-yellow accent — first daylight cutting through the dark, and a
/// color no big alarm app owns (Alarmy is red, the clones are orange/blue).
/// The mascot is a crowing chick, the sound of morning in Indonesia.
abstract final class AppColors {
  // Core surfaces (dark theme is the primary experience for an alarm app).
  static const background = Color(0xFF0E1630);
  static const surface = Color(0xFF16204A);
  static const surfaceRaised = Color(0xFF1E2B5C);
  static const outline = Color(0xFF34407A);

  // Electric-yellow accent (deep end shifts to amber).
  static const primary = Color(0xFFFFD60A);
  static const primaryDeep = Color(0xFFFFA000);
  static const onPrimary = Color(0xFF201900);

  // Solid "lip"/edge shades for the chunky 3D push-buttons and hard-offset
  // card shadows — a darker tone of the surface it sits under, no blur.
  static const primaryEdge = Color(0xFFC28A00); // under the yellow button
  static const successEdge = Color(0xFF37A85C);
  static const dangerEdge = Color(0xFFC93B3B);
  static const surfaceEdge = Color(0xFF0A1026); // under dark cards/controls
  static const surfaceEdgeLight = Color(0xFFD6D9E4);

  // Text.
  static const textPrimary = Color(0xFFF4F5F8);
  static const textSecondary = Color(0xFF9BA1B0);
  static const textTertiary = Color(0xFF5E6472);

  // Semantic.
  static const success = Color(0xFF4CD97B);
  static const danger = Color(0xFFFF5D5D);
  static const info = Color(0xFF6C8CFF);

  // Light theme counterparts. The canvas is a real, unmistakable slate
  // blue — not white, not a whisper of grey. White reads flat and dated,
  // and white cards need actual contrast to sit against.
  static const backgroundLight = Color(0xFFAEB6D4);
  static const surfaceLight = Color(0xFFFFFFFF);
  static const surfaceRaisedLight = Color(0xFFF0F1F5);
  static const outlineLight = Color(0xFFC5CBE0);
  static const textPrimaryLight = Color(0xFF15171E);
  static const textSecondaryLight = Color(0xFF5D6370);
  static const textTertiaryLight = Color(0xFF9BA1B0);

  static const sunriseGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [primary, primaryDeep],
  );
}
