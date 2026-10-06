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

/// The user's first name from onboarding (may be empty: the step is
/// optional). Personalises the paywall headline.
final userNameProvider = Provider<String>(
  (ref) => ref.read(sharedPreferencesProvider).getString(_userNameKey) ?? '',
);

/// Saves the onboarding name for [userNameProvider].
Future<void> saveUserName(WidgetRef ref, String name) async {
  await ref.read(sharedPreferencesProvider).setString(_userNameKey, name);
  ref.invalidate(userNameProvider);
}

enum AgeRange { under18, from18to24, from25to34, from35to44, over45 }

/// How often the user snoozes each morning, and the minutes that costs
/// (one standard 9-minute snooze each time).
enum SnoozeHabit {
  never(0),
  few(1.5),
  some(4),
  lots(6.5);

  const SnoozeHabit(this.snoozesPerMorning);

  final double snoozesPerMorning;

  /// Hours a year lost to snoozing, rounded.
  int get hoursPerYear => (snoozesPerMorning * 9 * 365 / 60).round();
}

enum WakeReason { work, school, sahur, exercise, productive }

enum HeardFrom { tiktok, instagram, youtube, friend, store, other }

/// The first alarm as the user builds it during onboarding. Onboarding *is*
/// alarm setup: time, sound and mission are picked here, then saved by
/// AlarmActions.createFromOnboarding before the paywall.
class OnboardingAnswers {
  const OnboardingAnswers({
    this.wakeGoalHour = 7,
    this.wakeGoalMinute = 0,
    this.sound = AlarmSound.classic,
    this.clipId,
    this.mission = MissionType.randomHunt,
    this.name = '',
    this.age,
    this.snooze,
    this.reason,
    this.heardFrom,
  });

  /// Survey answers: they shape the cost, plan and paywall copy, and are
  /// logged (never with the name) to learn who installs and why.
  final String name;
  final AgeRange? age;
  final SnoozeHabit? snooze;
  final WakeReason? reason;
  final HeardFrom? heardFrom;

  final int wakeGoalHour;
  final int wakeGoalMinute;
  final AlarmSound sound;

  /// A video alarm, which takes over from [sound] when set.
  final String? clipId;

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
    clipId: clipId,
    missionType: mission,
    missionReps: mission.defaultReps,
  );

  OnboardingAnswers copyWith({
    int? wakeGoalHour,
    int? wakeGoalMinute,
    AlarmSound? sound,
    String? Function()? clipId,
    MissionType? mission,
    String? name,
    AgeRange? age,
    SnoozeHabit? snooze,
    WakeReason? reason,
    HeardFrom? heardFrom,
  }) {
    return OnboardingAnswers(
      wakeGoalHour: wakeGoalHour ?? this.wakeGoalHour,
      wakeGoalMinute: wakeGoalMinute ?? this.wakeGoalMinute,
      sound: sound ?? this.sound,
      clipId: clipId == null ? this.clipId : clipId(),
      mission: mission ?? this.mission,
      name: name ?? this.name,
      age: age ?? this.age,
      snooze: snooze ?? this.snooze,
      reason: reason ?? this.reason,
      heardFrom: heardFrom ?? this.heardFrom,
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

  void setSound(AlarmSound sound) =>
      state = state.copyWith(sound: sound, clipId: () => null);

  void setClip(String clipId) => state = state.copyWith(clipId: () => clipId);

  void setMission(MissionType mission) =>
      state = state.copyWith(mission: mission);

  void setName(String name) => state = state.copyWith(name: name.trim());
  void setAge(AgeRange age) => state = state.copyWith(age: age);
  void setSnooze(SnoozeHabit snooze) => state = state.copyWith(snooze: snooze);
  void setReason(WakeReason reason) => state = state.copyWith(reason: reason);
  void setHeardFrom(HeardFrom from) => state = state.copyWith(heardFrom: from);
}
