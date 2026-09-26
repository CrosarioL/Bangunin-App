import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../app/di/providers.dart';

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

/// The user's first name, persisted at onboarding so the paywall and future
/// surfaces can address them directly. Empty string when never provided.
final userNameProvider = Provider<String>(
  (ref) => ref.read(sharedPreferencesProvider).getString(_userNameKey) ?? '',
);

/// Answers collected during the onboarding survey. Every answer is spent
/// later: the pain stat and plan chart are computed from them, the paywall
/// headline quotes the wake goal back, and the first alarm is created from
/// the goal + struggles (see AlarmActions.createFromOnboarding).
class OnboardingAnswers {
  const OnboardingAnswers({
    this.name = '',
    this.ageRange,
    this.snoozeHabit,
    this.bedHour = 23,
    this.bedMinute = 0,
    this.wakeGoalHour = 7,
    this.wakeGoalMinute = 0,
    this.struggles = const {},
    this.motivations = const {},
  });

  final String name;

  /// Index into the age-range options (0 = under 18 … 4 = 55+).
  final int? ageRange;

  /// 0 = never, 1 = sometimes, 2 = every morning.
  final int? snoozeHabit;
  final int bedHour;
  final int bedMinute;
  final int wakeGoalHour;
  final int wakeGoalMinute;
  final Set<String> struggles;
  final Set<String> motivations;

  OnboardingAnswers copyWith({
    String? name,
    int? ageRange,
    int? snoozeHabit,
    int? bedHour,
    int? bedMinute,
    int? wakeGoalHour,
    int? wakeGoalMinute,
    Set<String>? struggles,
    Set<String>? motivations,
  }) {
    return OnboardingAnswers(
      name: name ?? this.name,
      ageRange: ageRange ?? this.ageRange,
      snoozeHabit: snoozeHabit ?? this.snoozeHabit,
      bedHour: bedHour ?? this.bedHour,
      bedMinute: bedMinute ?? this.bedMinute,
      wakeGoalHour: wakeGoalHour ?? this.wakeGoalHour,
      wakeGoalMinute: wakeGoalMinute ?? this.wakeGoalMinute,
      struggles: struggles ?? this.struggles,
      motivations: motivations ?? this.motivations,
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

  void setName(String value) {
    final name = value.trim();
    state = state.copyWith(name: name);
    // Persisted immediately so the paywall (a separate route) can read it.
    ref.read(sharedPreferencesProvider).setString(_userNameKey, name);
  }

  void setAgeRange(int value) => state = state.copyWith(ageRange: value);

  void setSnoozeHabit(int value) => state = state.copyWith(snoozeHabit: value);

  void setBedtime(int hour, int minute) =>
      state = state.copyWith(bedHour: hour, bedMinute: minute);

  void setWakeGoal(int hour, int minute) =>
      state = state.copyWith(wakeGoalHour: hour, wakeGoalMinute: minute);

  void toggleStruggle(String id) {
    final struggles = {...state.struggles};
    if (!struggles.remove(id)) struggles.add(id);
    state = state.copyWith(struggles: struggles);
  }

  void toggleMotivation(String id) {
    final motivations = {...state.motivations};
    if (!motivations.remove(id)) motivations.add(id);
    state = state.copyWith(motivations: motivations);
  }
}
