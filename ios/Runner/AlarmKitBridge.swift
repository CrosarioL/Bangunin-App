import Foundation
import Flutter

#if canImport(AlarmKit)
  import AlarmKit
  import ActivityKit
  import AppIntents
  import SwiftUI
#endif

/// Bridges Bangunin's Dart alarm layer onto Apple's AlarmKit (iOS 26+).
///
/// AlarmKit is the only API that lets a third-party app ring through Silent
/// Mode and an active Focus, present a full-screen alert, and appear on the
/// Lock Screen — the things a notification fundamentally cannot do. Everything
/// here is gated behind `@available(iOS 26.0, *)` plus a runtime check, so the
/// app still builds and runs against the 15.5 deployment target; older devices
/// fall through to the notification path on the Dart side.
///
/// Contrary to several widely-circulated blog posts, AlarmKit requires **no
/// special entitlement**. It needs `NSAlarmKitUsageDescription` in Info.plist
/// and runtime authorization. (The `com.apple.developer.alarmkit` entitlement
/// those posts describe does not exist — an Apple engineer traced it to an
/// LLM inventing it. See marketing/research/IOS_COMPETITOR_UX_RESEARCH.md §4.2.)
enum AlarmKitBridge {
  static let channelName = "app.bangunin/alarmkit"

  /// Where the "open the app for a mission" intent leaves the alarm id for the
  /// Dart side to pick up on resume.
  static let pendingMissionKey = "bangunin.pendingMissionAlarmId"

  static func register(with registrar: FlutterPluginRegistrar) {
    let channel = FlutterMethodChannel(
      name: channelName,
      binaryMessenger: registrar.messenger()
    )
    channel.setMethodCallHandler { call, result in
      handle(call, result: result)
    }
  }

  private static func handle(
    _ call: FlutterMethodCall,
    result: @escaping FlutterResult
  ) {
    switch call.method {
    case "isSupported":
      result(isSupported)

    case "authorizationState":
      guard #available(iOS 26.0, *), isSupported else {
        result("unsupported")
        return
      }
      result(currentAuthorizationState())

    case "requestAuthorization":
      guard #available(iOS 26.0, *), isSupported else {
        result("unsupported")
        return
      }
      Task {
        let state = await requestAuthorization()
        await MainActor.run { result(state) }
      }

    case "schedule":
      guard #available(iOS 26.0, *), isSupported else {
        result(unsupportedError())
        return
      }
      guard let args = call.arguments as? [String: Any] else {
        result(badArgumentsError("expected an argument map"))
        return
      }
      Task { await schedule(args, result: result) }

    case "cancel":
      guard #available(iOS 26.0, *), isSupported else {
        result(unsupportedError())
        return
      }
      guard
        let args = call.arguments as? [String: Any],
        let rawId = args["id"] as? String,
        let id = UUID(uuidString: rawId)
      else {
        result(badArgumentsError("expected a uuid string 'id'"))
        return
      }
      cancel(id: id, result: result)

    case "cancelAll":
      guard #available(iOS 26.0, *), isSupported else {
        result(unsupportedError())
        return
      }
      cancelAll(result: result)

    case "scheduledIds":
      guard #available(iOS 26.0, *), isSupported else {
        result([String]())
        return
      }
      result(scheduledIds())

    case "deferReRing":
      guard #available(iOS 26.0, *), isSupported,
        let args = call.arguments as? [String: Any],
        let alarmId = args["id"] as? String,
        let seconds = args["seconds"] as? Int
      else {
        result(false)
        return
      }
      Task {
        await scheduleReRing(alarmId: alarmId, after: TimeInterval(seconds))
        await MainActor.run { result(true) }
      }

    case "cancelReRing":
      guard #available(iOS 26.0, *), isSupported,
        let args = call.arguments as? [String: Any],
        let alarmId = args["id"] as? String
      else {
        result(false)
        return
      }
      Task {
        await cancelReRing(alarmId: alarmId)
        await MainActor.run { result(true) }
      }

    case "consumePendingMissionAlarmId":
      let defaults = UserDefaults.standard
      let pending = defaults.string(forKey: pendingMissionKey)
      defaults.removeObject(forKey: pendingMissionKey)
      result(pending)

    default:
      result(FlutterMethodNotImplemented)
    }
  }

  /// True only when the framework is both compiled in and present at runtime.
  private static var isSupported: Bool {
    #if canImport(AlarmKit)
      if #available(iOS 26.0, *) { return true }
      return false
    #else
      return false
    #endif
  }

  private static func unsupportedError() -> FlutterError {
    FlutterError(
      code: "unsupported",
      message: "AlarmKit requires iOS 26 or newer.",
      details: nil
    )
  }

  private static func badArgumentsError(_ message: String) -> FlutterError {
    FlutterError(code: "bad_arguments", message: message, details: nil)
  }
}

#if canImport(AlarmKit)

  /// Metadata travelling with each alarm. Carries the mission so the alert and
  /// the app agree on what the user has to do to switch it off.
  @available(iOS 26.0, *)
  struct BanguninAlarmMetadata: AlarmMetadata {
    let alarmId: String
    let missionType: String

    init(alarmId: String, missionType: String) {
      self.alarmId = alarmId
      self.missionType = missionType
    }
  }

  /// Runs when the user taps the alarm's secondary button. Opens Bangunin and
  /// leaves the alarm id behind so the Dart router can push the mission.
  @available(iOS 26.0, *)
  struct StartMissionIntent: LiveActivityIntent {
    static var title: LocalizedStringResource = "Start wake-up mission"
    static var openAppWhenRun: Bool = true

    @Parameter(title: "Alarm ID")
    var alarmId: String

    init() { self.alarmId = "" }

    init(alarmId: String) { self.alarmId = alarmId }

    func perform() async throws -> some IntentResult {
      UserDefaults.standard.set(alarmId, forKey: AlarmKitBridge.pendingMissionKey)
      // Stopping the alert is not finishing the mission: the alarm comes
      // back unless the app pushes this back while the mission is under way
      // and cancels it once the mission is passed.
      await AlarmKitBridge.scheduleReRing(
        alarmId: alarmId,
        after: AlarmKitBridge.reRingDelay
      )
      return .result()
    }
  }

  @available(iOS 26.0, *)
  extension AlarmKitBridge {
    private static var manager: AlarmManager { AlarmManager.shared }

    static func currentAuthorizationState() -> String {
      describe(manager.authorizationState)
    }

    static func requestAuthorization() async -> String {
      do {
        return describe(try await manager.requestAuthorization())
      } catch {
        return "denied"
      }
    }

    private static func describe(
      _ state: AlarmManager.AuthorizationState
    ) -> String {
      switch state {
      case .notDetermined: return "notDetermined"
      case .authorized: return "authorized"
      case .denied: return "denied"
      @unknown default: return "denied"
      }
    }

    /// Schedules one alarm. `weekdays` is a list of ISO weekday numbers
    /// (1 = Monday … 7 = Sunday); empty means a one-shot alarm.
    static func schedule(
      _ args: [String: Any],
      result: @escaping FlutterResult
    ) async {
      guard
        let rawId = args["id"] as? String,
        let id = UUID(uuidString: rawId),
        let hour = args["hour"] as? Int,
        let minute = args["minute"] as? Int
      else {
        result(badArgumentsError("expected id, hour and minute"))
        return
      }

      let weekdays = (args["weekdays"] as? [Int]) ?? []
      let schedule = Alarm.Schedule.relative(
        Alarm.Schedule.Relative(
          time: Alarm.Schedule.Relative.Time(hour: hour, minute: minute),
          repeats: weekdays.isEmpty
            ? .never
            : .weekly(weekdays.compactMap(Self.weekday(fromIso:)))
        )
      )

      let configuration = makeConfiguration(
        args: args,
        alarmId: rawId,
        schedule: schedule
      )
      // Kept so a re-ring (see `scheduleReRing`) can rebuild the same alarm
      // from inside the intent, without the Flutter side running.
      UserDefaults.standard.set(args, forKey: argsKeyPrefix + rawId)

      do {
        _ = try await manager.schedule(id: id, configuration: configuration)
        await MainActor.run { result(true) }
      } catch AlarmManager.AlarmError.maximumLimitReached {
        // Surfaced to the user rather than swallowed — an alarm the system
        // refused to take is exactly the failure people write 1-star reviews
        // about.
        await MainActor.run {
          result(
            FlutterError(
              code: "limit_reached",
              message: "iOS will not accept any more alarms from this app.",
              details: nil
            )
          )
        }
      } catch {
        await MainActor.run {
          result(
            FlutterError(
              code: "schedule_failed",
              message: error.localizedDescription,
              details: nil
            )
          )
        }
      }
    }

    /// The alarm's look, sound and buttons. Shared by the scheduled alarm and
    /// its re-rings so they are indistinguishable to the user.
    static func makeConfiguration(
      args: [String: Any],
      alarmId: String,
      schedule: Alarm.Schedule
    ) -> AlarmManager.AlarmConfiguration<BanguninAlarmMetadata> {
      let label = (args["label"] as? String) ?? "Bangunin"
      let missionType = (args["missionType"] as? String) ?? "none"
      let secondaryTitle = (args["secondaryButtonTitle"] as? String)
        ?? "Start mission"
      let soundName = args["soundName"] as? String

      let secondaryButton = AlarmButton(
        text: LocalizedStringResource(stringLiteral: secondaryTitle),
        textColor: .black,
        systemImageName: missionType == "none"
          ? "checkmark.circle.fill"
          : "figure.run"
      )

      // 26.1 dropped the explicit stop button (the system draws its own) and
      // deprecated the initialiser that took one. Keep both paths so iOS 26.0
      // devices still get real alarms instead of being pushed onto the
      // notification fallback.
      let alert: AlarmPresentation.Alert
      if #available(iOS 26.1, *) {
        alert = AlarmPresentation.Alert(
          title: LocalizedStringResource(stringLiteral: label),
          secondaryButton: secondaryButton,
          secondaryButtonBehavior: .custom
        )
      } else {
        let stopTitle = (args["stopButtonTitle"] as? String) ?? "Stop"
        alert = AlarmPresentation.Alert(
          title: LocalizedStringResource(stringLiteral: label),
          stopButton: AlarmButton(
            text: LocalizedStringResource(stringLiteral: stopTitle),
            textColor: .white,
            systemImageName: "stop.circle.fill"
          ),
          secondaryButton: secondaryButton,
          secondaryButtonBehavior: .custom
        )
      }

      let attributes = AlarmAttributes<BanguninAlarmMetadata>(
        presentation: AlarmPresentation(alert: alert),
        metadata: BanguninAlarmMetadata(
          alarmId: alarmId,
          missionType: missionType
        ),
        // Bangunin's electric yellow.
        tintColor: Color(red: 1.0, green: 0.839, blue: 0.039)
      )

      let sound: AlertConfiguration.AlertSound =
        // AlarmKit plays the file through once and stops, so give it the
        // five-minute looped copy when there is one.
        soundName.map { .named(AlarmSoundBridge.longName(for: $0) ?? $0) } ?? .default

      let configuration = AlarmManager.AlarmConfiguration.alarm(
        schedule: schedule,
        attributes: attributes,
        // The system Stop control silences AlarmKit itself. For mission alarms,
        // open Bangunin so its ringing session can continue until verification.
        // Alarms without a mission retain the normal system Stop behavior.
        stopIntent: missionType == "none"
          ? nil
          : StartMissionIntent(alarmId: alarmId),
        secondaryIntent: StartMissionIntent(alarmId: alarmId),
        sound: sound
      )
      return configuration
    }

    static let argsKeyPrefix = "bangunin.alarmArgs."
    static let reRingKeyPrefix = "bangunin.reRing."

    /// How long after a mission alarm is swiped away, without the mission
    /// done, it rings again.
    static let reRingDelay: TimeInterval = 60

    /// Arms (or moves) the one pending re-ring for `alarmId` to `delay`
    /// seconds from now. The system's slide-to-stop cannot be removed, so
    /// stopping a mission alarm only buys time: until the mission is passed
    /// the alarm keeps coming back, even if Bangunin is closed.
    static func scheduleReRing(alarmId: String, after delay: TimeInterval) async {
      let defaults = UserDefaults.standard
      guard
        let args = defaults.dictionary(forKey: argsKeyPrefix + alarmId),
        (args["missionType"] as? String ?? "none") != "none"
      else { return }
      await cancelReRing(alarmId: alarmId)
      let reRingId = UUID()
      let configuration = makeConfiguration(
        args: args,
        alarmId: alarmId,
        schedule: .fixed(Date().addingTimeInterval(delay))
      )
      do {
        _ = try await manager.schedule(id: reRingId, configuration: configuration)
        defaults.set(reRingId.uuidString, forKey: reRingKeyPrefix + alarmId)
      } catch {
        // Nothing more we can do from here; the app re-arms it on next open.
      }
    }

    static func cancelReRing(alarmId: String) async {
      let defaults = UserDefaults.standard
      let key = reRingKeyPrefix + alarmId
      if let raw = defaults.string(forKey: key), let id = UUID(uuidString: raw) {
        try? manager.cancel(id: id)
      }
      defaults.removeObject(forKey: key)
    }

    /// ISO-8601 weekday (1 = Monday) to `Locale.Weekday`.
    static func weekday(fromIso iso: Int) -> Locale.Weekday? {
      switch iso {
      case 1: return .monday
      case 2: return .tuesday
      case 3: return .wednesday
      case 4: return .thursday
      case 5: return .friday
      case 6: return .saturday
      case 7: return .sunday
      default: return nil
      }
    }

    static func cancel(id: UUID, result: @escaping FlutterResult) {
      do {
        try manager.cancel(id: id)
        result(true)
      } catch {
        // A cancel for an alarm the system has already forgotten is a no-op,
        // not a failure worth propagating.
        result(true)
      }
    }

    static func cancelAll(result: @escaping FlutterResult) {
      do {
        for alarm in try manager.alarms {
          try? manager.cancel(id: alarm.id)
        }
        result(true)
      } catch {
        result(
          FlutterError(
            code: "cancel_all_failed",
            message: error.localizedDescription,
            details: nil
          )
        )
      }
    }

    static func scheduledIds() -> [String] {
      (try? manager.alarms.map { $0.id.uuidString }) ?? []
    }
  }

#endif
