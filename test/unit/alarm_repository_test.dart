import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:hive_ce/hive.dart';
import 'package:wakio/core/storage/local_store.dart';
import 'package:wakio/features/alarms/data/alarm_repository_impl.dart';
import 'package:wakio/features/alarms/domain/entities/alarm.dart';

void main() {
  late Directory tempDir;
  late LocalStore store;
  late HiveAlarmRepository repository;

  setUp(() async {
    tempDir = await Directory.systemTemp.createTemp('wakio_test');
    Hive.init(tempDir.path);
    store = await LocalStore.open();
    repository = HiveAlarmRepository(store);
  });

  tearDown(() async {
    await Hive.deleteFromDisk();
    await tempDir.delete(recursive: true);
  });

  Alarm alarm(String id, int hour, {DateTime? createdAt}) => Alarm(
        id: id,
        hour: hour,
        minute: 0,
        createdAt: createdAt ?? DateTime(2026),
      );

  test('upsert then getById round-trips', () async {
    await repository.upsert(alarm('a', 7));
    final loaded = await repository.getById('a');
    expect(loaded, isNotNull);
    expect(loaded!.hour, 7);
  });

  test('getAll returns alarms sorted by time of day', () async {
    await repository.upsert(alarm('late', 22));
    await repository.upsert(alarm('early', 5));
    await repository.upsert(alarm('mid', 12));
    final all = await repository.getAll();
    expect(all.map((a) => a.id).toList(), ['early', 'mid', 'late']);
  });

  test('upsert with existing id replaces', () async {
    await repository.upsert(alarm('a', 7));
    await repository.upsert(alarm('a', 9));
    final all = await repository.getAll();
    expect(all, hasLength(1));
    expect(all.single.hour, 9);
  });

  test('delete removes the alarm', () async {
    await repository.upsert(alarm('a', 7));
    await repository.delete('a');
    expect(await repository.getById('a'), isNull);
    expect(await repository.getAll(), isEmpty);
  });

  test('watchAll emits current list first, then updates', () async {
    await repository.upsert(alarm('a', 7));
    final emissionsFuture = repository.watchAll().take(2).toList();
    await Future<void>.delayed(const Duration(milliseconds: 20));
    await repository.upsert(alarm('b', 8));
    final emissions = await emissionsFuture;

    expect(emissions.first, hasLength(1));
    expect(emissions.last, hasLength(2));
  });

  group('resilience to malformed records', () {
    test('a single corrupt record does not break getAll for the rest',
        () async {
      await repository.upsert(alarm('good-1', 6));
      // Bypass the repository to write a record missing required fields
      // directly into the box, simulating disk corruption or a future
      // schema change without a migration.
      await store.write(LocalStore.alarms, 'corrupt', {'not': 'an alarm'});
      await repository.upsert(alarm('good-2', 8));

      final all = await repository.getAll();
      expect(all.map((a) => a.id).toSet(), {'good-1', 'good-2'});
    });

    test('getById returns null for a corrupt record instead of throwing',
        () async {
      await store.write(LocalStore.alarms, 'corrupt', {'not': 'an alarm'});
      expect(await repository.getById('corrupt'), isNull);
    });

    test('a truncated JSON string in the box does not break getAll',
        () async {
      await repository.upsert(alarm('good', 6));
      // LocalStore.write always produces valid JSON; this simulates a
      // partial disk write landing directly in the underlying box.
      await Hive.box<String>(LocalStore.alarms).put('truncated', '{"id":');

      final all = await repository.getAll();
      expect(all.map((a) => a.id).toList(), ['good']);
    });
  });
}
