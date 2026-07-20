import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/misc.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:hive_ce_flutter/hive_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:timezone/data/latest_10y.dart' as tz_data;
import 'package:timezone/timezone.dart' as tz;

import 'app/di/providers.dart';
import 'core/services/notifications/notification_service.dart';
import 'core/storage/local_store.dart';

/// Performs all async initialization required before [runApp] and returns
/// the provider overrides that inject the ready-to-use singletons.
Future<List<Override>> bootstrap() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Each branch below is a platform-channel round trip or disk I/O with no
  // dependency on the others' results, so they run concurrently instead of
  // paying their latency one after another.
  final results = await Future.wait([
    SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]),
    _initTimeZone(),
    _openLocalStore(),
    SharedPreferences.getInstance(),
    _initNotifications(),
  ]);

  final store = results[2] as LocalStore;
  final prefs = results[3] as SharedPreferences;
  final notificationService = results[4] as NotificationService;

  return [
    localStoreProvider.overrideWithValue(store),
    sharedPreferencesProvider.overrideWithValue(prefs),
    notificationServiceProvider.overrideWithValue(notificationService),
  ];
}

Future<void> _initTimeZone() async {
  // 10-year rule window: alarms only ever schedule a handful of days ahead
  // (see AlarmScheduler.occurrencesPerAlarm), so the full historical-since-
  // 1970 database (~2MB parsed at startup) buys nothing here.
  tz_data.initializeTimeZones();
  try {
    final localTimezone = await FlutterTimezone.getLocalTimezone();
    tz.setLocalLocation(tz.getLocation(localTimezone.identifier));
  } on Exception {
    // Fall back to the bundled default (UTC); alarms still fire because
    // scheduling uses the device wall clock converted through tz.local.
  }
}

Future<LocalStore> _openLocalStore() async {
  await Hive.initFlutter();
  return LocalStore.open();
}

Future<NotificationService> _initNotifications() async {
  final service = NotificationService();
  await service.initialize();
  return service;
}
