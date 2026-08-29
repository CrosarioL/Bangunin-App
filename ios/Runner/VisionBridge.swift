import Foundation
import Flutter
import Vision

/// On-device scene understanding for photo missions, via Apple's Vision
/// framework.
///
/// Chosen over a bundled classifier because it costs **0 MB of binary**, has
/// no third-party licence, and no App Store review impact — and because a
/// probe of `VNClassifyImageRequest`'s taxonomy (1,303 labels) confirmed it
/// already carries the exact labels the missions need: `grass`, `bed`,
/// `bedding`, `bedroom`, `pillow`, `sky`, `blue_sky`, `night_sky`, `cloudy`,
/// plus `foliage`/`garden`/`outdoor` as supporting evidence.
///
/// Everything runs locally. No frame, and no derived feature, ever leaves the
/// device — the same privacy posture as the rest of the mission pipeline.
///
/// This is a *signal*, not proof. Callers still hedge their wording.
enum VisionBridge {
  static let channelName = "app.bangunin/vision"

  static func register(with registrar: FlutterPluginRegistrar) {
    let channel = FlutterMethodChannel(
      name: channelName,
      binaryMessenger: registrar.messenger()
    )
    channel.setMethodCallHandler { call, result in
      switch call.method {
      case "isSupported":
        result(true)

      case "classify":
        guard
          let args = call.arguments as? [String: Any],
          let path = args["path"] as? String
        else {
          result(badArguments())
          return
        }
        // Vision is not cheap; keep it off the platform thread.
        DispatchQueue.global(qos: .userInitiated).async {
          let labels = classify(path: path)
          DispatchQueue.main.async { result(labels) }
        }

      case "detectHand":
        guard
          let args = call.arguments as? [String: Any],
          let path = args["path"] as? String
        else {
          result(badArguments())
          return
        }
        DispatchQueue.global(qos: .userInitiated).async {
          let confidence = handConfidence(path: path)
          DispatchQueue.main.async { result(confidence) }
        }

      default:
        result(FlutterMethodNotImplemented)
      }
    }
  }

  private static func badArguments() -> FlutterError {
    FlutterError(
      code: "bad_arguments",
      message: "expected a 'path' string",
      details: nil
    )
  }

  /// Returns `[label: confidence]` for classifications worth considering.
  ///
  /// `hasMinimumRecall(_:forPrecision:)` is Apple's own calibration hook: it
  /// keeps observations whose precision is trustworthy rather than us picking
  /// a raw confidence cut-off out of the air.
  static func classify(path: String) -> [String: Double] {
    let url = URL(fileURLWithPath: path)
    let request = VNClassifyImageRequest()
    let handler = VNImageRequestHandler(url: url, options: [:])

    do {
      try handler.perform([request])
    } catch {
      return [:]
    }

    guard let observations = request.results else { return [:] }

    var labels: [String: Double] = [:]
    for observation in observations
    where observation.hasMinimumRecall(0.01, forPrecision: 0.7) {
      labels[observation.identifier] = Double(observation.confidence)
    }
    return labels
  }

  /// Confidence that a human hand is visible, 0 when none is found.
  ///
  /// This is what makes "touch grass" mean something: the heuristics can see
  /// a green textured surface, but only this can see a hand reaching into it.
  static func handConfidence(path: String) -> Double {
    let url = URL(fileURLWithPath: path)
    let request = VNDetectHumanHandPoseRequest()
    request.maximumHandCount = 2
    let handler = VNImageRequestHandler(url: url, options: [:])

    do {
      try handler.perform([request])
    } catch {
      return 0
    }

    guard let observations = request.results, !observations.isEmpty else {
      return 0
    }
    return Double(observations.map(\.confidence).max() ?? 0)
  }
}
