import 'dart:async';
import 'dart:typed_data';

import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;

/// Wraps the local notifications plugin. Alarms are scheduled as exact,
/// full-screen notifications; tapping one deep-links into the ringing screen
/// via [selectedPayloads].
class NotificationService {
  NotificationService([FlutterLocalNotificationsPlugin? plugin])
    : _plugin = plugin ?? FlutterLocalNotificationsPlugin();

  final FlutterLocalNotificationsPlugin _plugin;
  final _selectedPayloads = StreamController<String>.broadcast();

  /// Payloads of notifications the user tapped (alarm ids).
  Stream<String> get selectedPayloads => _selectedPayloads.stream;

  /// Payload of the notification that launched the app, if any.
  String? launchPayload;

  // Changing the ID ensures devices that installed an older build get the
  // corrected alarm-channel behavior (Android channel settings are immutable).
  static const _channelId = 'bangunin_alarms_v2';

  Future<void> initialize() async {
    const settings = InitializationSettings(
      android: AndroidInitializationSettings('launcher_icon'),
      iOS: DarwinInitializationSettings(
        requestAlertPermission: false,
        requestBadgePermission: false,
        requestSoundPermission: false,
      ),
    );
    await _plugin.initialize(
      settings: settings,
      onDidReceiveNotificationResponse: (response) {
        final payload = response.payload;
        if (payload != null && payload.isNotEmpty) {
          _selectedPayloads.add(payload);
        }
      },
    );

    final launchDetails = await _plugin.getNotificationAppLaunchDetails();
    if (launchDetails?.didNotificationLaunchApp ?? false) {
      launchPayload = launchDetails?.notificationResponse?.payload;
    }
  }

  Future<bool> requestPermission() async {
    final ios = _plugin
        .resolvePlatformSpecificImplementation<
          IOSFlutterLocalNotificationsPlugin
        >();
    if (ios != null) {
      return await ios.requestPermissions(
            alert: true,
            badge: true,
            sound: true,
          ) ??
          false;
    }
    final android = _plugin
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >();
    if (android != null) {
      final granted = await android.requestNotificationsPermission() ?? false;
      await android.requestExactAlarmsPermission();
      return granted;
    }
    return false;
  }

  Future<void> schedule({
    required int id,
    required String title,
    required String body,
    required DateTime at,
    required String payload,
  }) async {
    await _plugin.zonedSchedule(
      id: id,
      title: title,
      body: body,
      scheduledDate: tz.TZDateTime.from(at, tz.local),
      notificationDetails: NotificationDetails(
        android: AndroidNotificationDetails(
          _channelId,
          'Bangunin alarms',
          channelDescription: 'User-scheduled wake-up alarms',
          importance: Importance.max,
          priority: Priority.max,
          category: AndroidNotificationCategory.alarm,
          fullScreenIntent: true,
          ongoing: true,
          autoCancel: false,
          additionalFlags: Int32List.fromList(<int>[
            4, // Notification.FLAG_INSISTENT: repeat sound until handled.
            32, // Notification.FLAG_NO_CLEAR: cannot be swipe-dismissed.
          ]),
          audioAttributesUsage: AudioAttributesUsage.alarm,
        ),
        iOS: const DarwinNotificationDetails(
          presentAlert: true,
          presentSound: true,
          presentBanner: true,
          sound: 'default',
          interruptionLevel: InterruptionLevel.timeSensitive,
        ),
      ),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      payload: payload,
    );
  }

  Future<void> cancel(int id) => _plugin.cancel(id: id);

  Future<void> cancelAll() => _plugin.cancelAll();
}
