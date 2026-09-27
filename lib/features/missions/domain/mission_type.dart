import 'package:flutter/material.dart';

/// The wake-up missions offered by the product: photo proofs and movement
/// proofs. `none` is a plain alarm that can be dismissed with a tap.
///
/// Serialized by name, so declaration order only sets the picker order.
/// [randomHunt] leads because it needs no setup and is the most fun to film.
enum MissionType {
  none,
  randomHunt,
  objectHunt,
  skyPhoto,
  grassPhoto,
  makeBed,
  squats,
  pushups;

  bool get isPhoto =>
      this == randomHunt ||
      this == objectHunt ||
      this == skyPhoto ||
      this == grassPhoto ||
      this == makeBed;

  bool get isMovement => this == squats || this == pushups;

  /// Object Hunt needs a reference photo registered when the alarm is created.
  /// Random Hunt deliberately does not: the app picks the object at ring
  /// time, so there is nothing to set up and no spot to pre-plan.
  bool get needsReferencePhoto => this == objectHunt;

  IconData get icon => switch (this) {
    none => Icons.notifications_none_rounded,
    randomHunt => Icons.shuffle_rounded,
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
