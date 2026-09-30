import AVFoundation
import Flutter
import Foundation

/// Makes an alarm's chosen sound available to the system by name.
///
/// AlarmKit (`AlertSound.named`) and local notifications (`UNNotificationSound`)
/// can only play a file they find by name in the app bundle or in
/// `Library/Sounds`, and only in a PCM format (wav/caf/aiff) of at most 30
/// seconds. Bangunin's meme clips are AAC `.m4a` inside the Flutter asset
/// bundle, and custom sounds are arbitrary imported or recorded files, so
/// without this every iOS alarm fell back to the default system tone.
///
/// `install` converts the source to 16-bit PCM `.caf`, trimmed to 29 seconds,
/// in `Library/Sounds/<key>.caf`, and returns that file name. Conversion is
/// skipped when an up-to-date copy already exists.
enum AlarmSoundBridge {
  static let channelName = "app.bangunin/alarmsound"
  private static let maxSeconds = 29.0

  static func register(with registrar: FlutterPluginRegistrar) {
    let channel = FlutterMethodChannel(
      name: channelName,
      binaryMessenger: registrar.messenger()
    )
    channel.setMethodCallHandler { call, result in
      guard
        call.method == "install",
        let args = call.arguments as? [String: Any],
        let key = args["key"] as? String
      else {
        result(FlutterMethodNotImplemented)
        return
      }

      let source: URL?
      if let asset = args["asset"] as? String {
        let lookup = registrar.lookupKey(forAsset: asset)
        source = Bundle.main.path(forResource: lookup, ofType: nil)
          .map(URL.init(fileURLWithPath:))
      } else if let path = args["path"] as? String {
        source = URL(fileURLWithPath: path)
      } else {
        source = nil
      }

      guard let source, FileManager.default.fileExists(atPath: source.path)
      else {
        result(nil)
        return
      }

      DispatchQueue.global(qos: .userInitiated).async {
        let name = try? install(source: source, key: key)
        DispatchQueue.main.async { result(name) }
      }
    }
  }

  private static func install(source: URL, key: String) throws -> String {
    let fileManager = FileManager.default
    let soundsDir = try fileManager
      .url(for: .libraryDirectory, in: .userDomainMask, appropriateFor: nil, create: true)
      .appendingPathComponent("Sounds", isDirectory: true)
    try fileManager.createDirectory(at: soundsDir, withIntermediateDirectories: true)

    let fileName = "\(key).caf"
    let destination = soundsDir.appendingPathComponent(fileName)
    if isUpToDate(destination, comparedTo: source) { return fileName }

    do {
      try convert(source, to: destination)
    } catch {
      // Video containers (imported .mp4/.mov) are not readable by
      // AVAudioFile; extract the audio track first, then convert that.
      let extracted = fileManager.temporaryDirectory
        .appendingPathComponent("\(key)-extract.m4a")
      try? fileManager.removeItem(at: extracted)
      try extractAudio(from: source, to: extracted)
      defer { try? fileManager.removeItem(at: extracted) }
      try convert(extracted, to: destination)
    }
    return fileName
  }

  private static func isUpToDate(_ destination: URL, comparedTo source: URL) -> Bool {
    let fileManager = FileManager.default
    guard
      let dest = try? fileManager.attributesOfItem(atPath: destination.path),
      let src = try? fileManager.attributesOfItem(atPath: source.path),
      let destDate = dest[.modificationDate] as? Date,
      let srcDate = src[.modificationDate] as? Date
    else { return false }
    return destDate >= srcDate
  }

  private static func convert(_ source: URL, to destination: URL) throws {
    let input = try AVAudioFile(forReading: source)
    let format = input.processingFormat
    let settings: [String: Any] = [
      AVFormatIDKey: kAudioFormatLinearPCM,
      AVSampleRateKey: format.sampleRate,
      AVNumberOfChannelsKey: format.channelCount,
      AVLinearPCMBitDepthKey: 16,
      AVLinearPCMIsFloatKey: false,
      AVLinearPCMIsBigEndianKey: false,
    ]
    try? FileManager.default.removeItem(at: destination)
    let output = try AVAudioFile(
      forWriting: destination,
      settings: settings,
      commonFormat: format.commonFormat,
      interleaved: format.isInterleaved
    )

    var remaining = min(
      input.length,
      AVAudioFramePosition(maxSeconds * format.sampleRate)
    )
    let chunk: AVAudioFrameCount = 16_384
    guard let buffer = AVAudioPCMBuffer(pcmFormat: format, frameCapacity: chunk)
    else { throw CocoaError(.fileWriteUnknown) }
    while remaining > 0 {
      let frames = AVAudioFrameCount(min(AVAudioFramePosition(chunk), remaining))
      try input.read(into: buffer, frameCount: frames)
      if buffer.frameLength == 0 { break }
      try output.write(from: buffer)
      remaining -= AVAudioFramePosition(buffer.frameLength)
    }
  }

  private static func extractAudio(from source: URL, to destination: URL) throws {
    let asset = AVURLAsset(url: source)
    guard
      let export = AVAssetExportSession(
        asset: asset,
        presetName: AVAssetExportPresetAppleM4A
      )
    else { throw CocoaError(.fileReadUnknown) }
    export.outputURL = destination
    export.outputFileType = .m4a
    let done = DispatchSemaphore(value: 0)
    export.exportAsynchronously { done.signal() }
    done.wait()
    if export.status != .completed {
      throw export.error ?? CocoaError(.fileReadUnknown)
    }
  }
}
