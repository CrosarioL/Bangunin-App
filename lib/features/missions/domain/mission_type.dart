import 'package:flutter/material.dart';

/// The wake-up missions offered by the product: photo proofs, movement
/// proofs and on-phone tasks. `none` is a plain alarm that can be dismissed
/// with a tap.
///
/// Serialized by name, so declaration order only sets the picker order.
/// [randomHunt] leads because it needs no setup and is the most fun to film.
enum MissionType {
  none,
  randomHunt,
  math,
  shake,
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

  /// Camera-counted exercise.
  bool get isMovement => this == squats || this == pushups;

  /// Done on the phone itself, no camera: solving sums, shaking it.
  bool get isPhoneTask => this == math || this == shake;

  /// Missions with a user-adjustable count ([defaultReps], [countOptions]).
  bool get hasCount => isMovement || isPhoneTask;

  /// Object Hunt needs a reference photo registered when the alarm is created.
  /// Random Hunt deliberately does not: the app picks the object at ring
  /// time, so there is nothing to set up and no spot to pre-plan.
  bool get needsReferencePhoto => this == objectHunt;

  /// Can follow another mission in a chain. Object Hunt can't: an alarm has
  /// one registered reference photo, and it belongs to the first mission.
  bool get canChain => this != none && this != objectHunt;

  IconData get icon => switch (this) {
    none => Icons.notifications_none_rounded,
    randomHunt => Icons.shuffle_rounded,
    math => Icons.calculate_rounded,
    shake => Icons.vibration_rounded,
    objectHunt => Icons.center_focus_strong_rounded,
    skyPhoto => Icons.wb_twilight_rounded,
    grassPhoto => Icons.grass_rounded,
    makeBed => Icons.bed_rounded,
    squats => Icons.accessibility_new_rounded,
    pushups => Icons.fitness_center_rounded,
  };

  /// Reps, problems or shakes, depending on the mission. 0 when there is no
  /// count.
  int get defaultReps => switch (this) {
    squats || pushups => 10,
    math => 3,
    shake => 30,
    _ => 0,
  };

  List<int> get countOptions => switch (this) {
    squats || pushups => const [5, 10, 15, 20, 30],
    math => const [1, 2, 3, 5, 8],
    shake => const [20, 30, 50, 80, 120],
    _ => const [],
  };
}
