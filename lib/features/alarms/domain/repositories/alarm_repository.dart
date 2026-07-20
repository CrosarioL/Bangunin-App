import '../entities/alarm.dart';

abstract interface class AlarmRepository {
  Future<List<Alarm>> getAll();

  Future<Alarm?> getById(String id);

  Future<void> upsert(Alarm alarm);

  Future<void> delete(String id);

  /// Emits whenever the alarm collection changes (initial emit included).
  Stream<List<Alarm>> watchAll();
}
