import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../app/di/providers.dart';

const _tutorialDoneKey = 'coach_mark_completed';

/// Whether the post-onboarding coach-mark tutorial has been shown.
final tutorialCompletedProvider =
    NotifierProvider<TutorialCompletedNotifier, bool>(
      TutorialCompletedNotifier.new,
    );

class TutorialCompletedNotifier extends Notifier<bool> {
  @override
  bool build() =>
      ref.read(sharedPreferencesProvider).getBool(_tutorialDoneKey) ?? false;

  Future<void> markCompleted() async {
    state = true;
    await ref.read(sharedPreferencesProvider).setBool(_tutorialDoneKey, true);
  }

  Future<void> reset() async {
    state = false;
    await ref.read(sharedPreferencesProvider).setBool(_tutorialDoneKey, false);
  }
}
