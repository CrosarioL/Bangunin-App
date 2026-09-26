import 'dart:convert';

import 'package:hive_ce/hive.dart';

/// Thin wrapper over Hive boxes. Entities are persisted as JSON strings so
/// no generated type adapters are required and models stay the single source
/// of truth for their schema.
class LocalStore {
  LocalStore._(this._alarms, this._wakeRecords, this._settings);

  final Box<String> _alarms;
  final Box<String> _wakeRecords;
  final Box<String> _settings;

  static const _alarmsBox = 'alarms';
  static const _wakeRecordsBox = 'wake_records';
  static const _settingsBox = 'settings';

  static Future<LocalStore> open() async {
    // Independent files — opening in parallel shaves the sequential I/O off
    // startup instead of waiting on each box one at a time.
    final boxes = await Future.wait([
      Hive.openBox<String>(_alarmsBox),
      Hive.openBox<String>(_wakeRecordsBox),
      Hive.openBox<String>(_settingsBox),
    ]);
    return LocalStore._(boxes[0], boxes[1], boxes[2]);
  }

  // -- Generic JSON collection access ---------------------------------------

  /// Decodes every entry in [collection], silently dropping any that fail
  /// to parse as JSON. A single truncated write (e.g. the app was killed
  /// mid-write) must not take down the rest of an otherwise-healthy
  /// collection — losing one alarm is recoverable, refusing to show any of
  /// them is not.
  List<Map<String, dynamic>> readAll(String collection) {
    final box = _boxFor(collection);
    final decoded = <Map<String, dynamic>>[];
    for (final raw in box.values) {
      try {
        decoded.add(jsonDecode(raw) as Map<String, dynamic>);
      } on FormatException {
        continue;
      }
    }
    return decoded;
  }

  Map<String, dynamic>? read(String collection, String id) {
    final raw = _boxFor(collection).get(id);
    return raw == null ? null : jsonDecode(raw) as Map<String, dynamic>;
  }

  Future<void> write(String collection, String id, Map<String, dynamic> json) =>
      _boxFor(collection).put(id, jsonEncode(json));

  Future<void> delete(String collection, String id) =>
      _boxFor(collection).delete(id);

  Stream<void> watch(String collection) =>
      _boxFor(collection).watch().map((_) {});

  Box<String> _boxFor(String collection) => switch (collection) {
    _alarmsBox => _alarms,
    _wakeRecordsBox => _wakeRecords,
    _settingsBox => _settings,
    _ => throw ArgumentError('Unknown collection: $collection'),
  };

  static const alarms = _alarmsBox;
  static const wakeRecords = _wakeRecordsBox;
  static const settings = _settingsBox;
}
