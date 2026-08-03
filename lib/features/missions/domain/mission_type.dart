import 'package:flutter/material.dart';

/// The wake-up missions offered by the product: photo proofs and movement
/// proofs. `none` is a plain alarm that can be dismissed with a tap.
enum MissionType {
  none,
  objectHunt,
  skyPhoto,
  grassPhoto,
  makeBed,
  squats,
  pushups;

  bool get isPhoto =>
      this == objectHunt ||
      this == skyPhoto ||
      this == grassPhoto ||
      this == makeBed;

  bool get isMovement => this == squats || this == pushups;

  /// Object Hunt needs a reference photo registered when the alarm is created.
  bool get needsReferencePhoto => this == objectHunt;

  IconData get icon => switch (this) {
    none => Icons.notifications_none_rounded,
    objectHunt => Icons.center_focus_strong_rounded,
    skyPhoto => Icons.wb_twilight_rounded,
    grassPhoto => Icons.grass_rounded,
    makeBed => Icons.bed_rounded,
    squats => Icons.accessibility_new_rounded,
    pushups => Icons.fitness_center_rounded,
  };

  /// Default repetition target for movement missions.
  int get defaultReps => isMovement ? 10 : 0;
}
