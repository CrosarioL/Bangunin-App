import 'dart:async';

import '../../../core/storage/local_store.dart';
import '../domain/entities/alarm.dart';
import '../domain/repositories/alarm_repository.dart';

class HiveAlarmRepository implements AlarmRepository {
  HiveAlarmRepository(this._store);

  final LocalStore _store;

  @override
  Future<List<Alarm>> getAll() async {
    // Parsed one at a time (not a lazy .map().toList()) so a single record
    // that fails to match the current schema — e.g. left behind by a future
    // migration bug — doesn't throw away every other, healthy alarm with it.
    // The generated fromJson throws a mix of TypeError (bad cast),
    // FormatException (bad DateTime), and ArgumentError (bad enum value) —
    // deliberately broad because this is a deserialization boundary over
    // persisted data we don't fully trust, not application logic.
    final alarms = <Alarm>[];
    for (final json in _store.readAll(LocalStore.alarms)) {
      try {
        alarms.add(Alarm.fromJson(json));
      } catch (_) {
        continue;
      }
    }
    alarms.sort(_byTime);
    return alarms;
  }

  @override
  Future<Alarm?> getById(String id) async {
    final json = _store.read(LocalStore.alarms, id);
    if (json == null) return null;
    try {
      return Alarm.fromJson(json);
      // ignore: avoid_catching_errors
    } catch (_) {
      return null;
    }
  }

  @override
  Future<void> upsert(Alarm alarm) =>
      _store.write(LocalStore.alarms, alarm.id, alarm.toJson());

  @override
  Future<void> delete(String id) => _store.delete(LocalStore.alarms, id);

  @override
  Stream<List<Alarm>> watchAll() async* {
    yield await getAll();
    await for (final _ in _store.watch(LocalStore.alarms)) {
      yield await getAll();
    }
  }

  static int _byTime(Alarm a, Alarm b) {
    final cmp = (a.hour * 60 + a.minute).compareTo(b.hour * 60 + b.minute);
    return cmp != 0 ? cmp : a.createdAt.compareTo(b.createdAt);
  }
}
