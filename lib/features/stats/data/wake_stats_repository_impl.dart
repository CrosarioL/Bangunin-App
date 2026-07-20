import 'dart:async';

import '../../../core/storage/local_store.dart';
import '../domain/entities/wake_record.dart';
import '../domain/repositories/wake_stats_repository.dart';

class HiveWakeStatsRepository implements WakeStatsRepository {
  HiveWakeStatsRepository(this._store);

  final LocalStore _store;

  @override
  Future<List<WakeRecord>> getAll() async {
    // See HiveAlarmRepository.getAll: parsed one at a time so a single
    // malformed record can't wipe out the whole streak history.
    final records = <WakeRecord>[];
    for (final json in _store.readAll(LocalStore.wakeRecords)) {
      try {
        records.add(WakeRecord.fromJson(json));
      } catch (_) {
        continue;
      }
    }
    records.sort((a, b) => b.dismissedAt.compareTo(a.dismissedAt));
    return records;
  }

  @override
  Future<void> add(WakeRecord record) =>
      _store.write(LocalStore.wakeRecords, record.id, record.toJson());

  @override
  Stream<List<WakeRecord>> watchAll() async* {
    yield await getAll();
    await for (final _ in _store.watch(LocalStore.wakeRecords)) {
      yield await getAll();
    }
  }
}
