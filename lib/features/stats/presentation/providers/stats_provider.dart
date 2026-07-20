import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../app/di/providers.dart';
import '../../domain/entities/wake_record.dart';
import '../../domain/streak_calculator.dart';

final wakeRecordsProvider = StreamProvider<List<WakeRecord>>(
  (ref) => ref.watch(wakeStatsRepositoryProvider).watchAll(),
);

final currentStreakProvider = Provider<int>((ref) {
  final records = ref.watch(wakeRecordsProvider).value ?? const [];
  return StreakCalculator.currentStreak(records);
});

final bestStreakProvider = Provider<int>((ref) {
  final records = ref.watch(wakeRecordsProvider).value ?? const [];
  return StreakCalculator.bestStreak(records);
});

final averageWakeMinutesProvider = Provider<int?>((ref) {
  final records = ref.watch(wakeRecordsProvider).value ?? const [];
  return StreakCalculator.averageWakeMinutes(records);
});

final monthSuccessDaysProvider = Provider<Set<int>>((ref) {
  final records = ref.watch(wakeRecordsProvider).value ?? const [];
  return StreakCalculator.successDaysInMonth(records, DateTime.now());
});
