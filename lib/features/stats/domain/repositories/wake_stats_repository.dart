import '../entities/wake_record.dart';

abstract interface class WakeStatsRepository {
  Future<List<WakeRecord>> getAll();

  Future<void> add(WakeRecord record);

  Stream<List<WakeRecord>> watchAll();
}
