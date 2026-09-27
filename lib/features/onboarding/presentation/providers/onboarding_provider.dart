import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../app/di/providers.dart';
import '../../../alarms/domain/entities/alarm.dart';
import '../../../missions/domain/mission_type.dart';

const _onboardingDoneKey = 'onboarding_completed';
const _userNameKey = 'user_first_name';

/// Whether the user has finished onboarding. Drives the router redirect.
final onboardingCompletedProvider =
    NotifierProvider<OnboardingCompletedNotifier, bool>(
      OnboardingCompletedNotifier.new,
    );

class OnboardingCompletedNotifier extends Notifier<bool> {
  @override
  bool build() =>
      ref.read(sharedPreferencesProvider).getBool(_onboardingDoneKey) ?? false;

  Future<void> markCompleted() async {
    state = true;
    await ref.read(sharedPreferencesProvider).setBool(_onboardingDoneKey, true);
  }
}

/// The user's first name, if an earlier onboarding version collected it.
/// Onboarding no longer asks, so new users get the generic paywall headline.
final userNameProvider = Provider<String>(
  (ref) => ref.read(sharedPreferencesProvider).getString(_userNameKey) ?? '',
);

/// The first alarm as the user builds it during onboarding. Onboarding *is*
/// alarm setup: time, sound and mission are picked here, then saved by
/// AlarmActions.createFromOnboarding before the paywall.
class OnboardingAnswers {
  const OnboardingAnswers({
    this.wakeGoalHour = 7,
    this.wakeGoalMinute = 0,
    this.sound = AlarmSound.classic,
    this.mission = MissionType.randomHunt,
  });

  final int wakeGoalHour;
  final int wakeGoalMinute;
  final AlarmSound sound;

  /// Defaults to Random Hunt: no setup, and the mission people film.
  final MissionType mission;

  /// Weekdays only: a 6:30 alarm that also fires on Saturday is how a new
  /// user ends up deleting the app on their first weekend.
  static const repeatDays = {
    DateTime.monday,
    DateTime.tuesday,
    DateTime.wednesday,
    DateTime.thursday,
    DateTime.friday,
  };

  /// The alarm these answers describe, keeping [base]'s id and createdAt.
  Alarm toAlarm(Alarm base) => base.copyWith(
    hour: wakeGoalHour,
    minute: wakeGoalMinute,
    repeatDays: repeatDays,
    sound: sound,
    missionType: mission,
    missionReps: mission.defaultReps,
  );

  OnboardingAnswers copyWith({
    int? wakeGoalHour,
    int? wakeGoalMinute,
    AlarmSound? sound,
    MissionType? mission,
  }) {
    return OnboardingAnswers(
      wakeGoalHour: wakeGoalHour ?? this.wakeGoalHour,
      wakeGoalMinute: wakeGoalMinute ?? this.wakeGoalMinute,
      sound: sound ?? this.sound,
      mission: mission ?? this.mission,
    );
  }
}

final onboardingAnswersProvider =
    NotifierProvider<OnboardingAnswersNotifier, OnboardingAnswers>(
      OnboardingAnswersNotifier.new,
    );

class OnboardingAnswersNotifier extends Notifier<OnboardingAnswers> {
  @override
  OnboardingAnswers build() => const OnboardingAnswers();

  void setWakeGoal(int hour, int minute) =>
      state = state.copyWith(wakeGoalHour: hour, wakeGoalMinute: minute);

  void setSound(AlarmSound sound) => state = state.copyWith(sound: sound);

  void setMission(MissionType mission) =>
      state = state.copyWith(mission: mission);
}
