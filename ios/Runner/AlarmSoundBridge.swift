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
/// `install` writes two files to `Library/Sounds`, both made by playing the
/// clip back to back until they are full, so a short meme sound repeats
/// instead of firing once and leaving silence:
///
///  * `<key>-v2.caf` — 29 seconds of 16-bit PCM, for notifications (snooze,
///    Wake Up Check), whose sounds iOS refuses beyond 30 seconds.
///  * `<key>-v2-long.caf` — five minutes of IMA4, for AlarmKit, which plays
///    the file it is given and stops at its end. Compressed so each sound
///    stays around a dozen megabytes.
///
/// It returns the short name; [longName] maps it to the AlarmKit one.
/// Conversion is skipped when up-to-date copies already exist. The `-v2`
/// suffix makes phones that hold the old play-once files build new ones.
enum AlarmSoundBridge {
  static let channelName = "app.bangunin/alarmsound"
  private static let notificationSeconds = 29.0
  private static let alarmSeconds = 300.0
  private static let suffix = "-v2"

  /// The AlarmKit file for a name returned by `install`, when it exists.
  static func longName(for shortName: String) -> String? {
    guard shortName.hasSuffix("\(suffix).caf") else { return nil }
    let long = shortName.replacingOccurrences(
      of: "\(suffix).caf", with: "\(suffix)-long.caf")
    guard
      let dir = try? FileManager.default.url(
        for: .libraryDirectory, in: .userDomainMask, appropriateFor: nil, create: false),
      FileManager.default.fileExists(
        atPath: dir.appendingPathComponent("Sounds/\(long)").path)
    else { return nil }
    return long
  }

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

    let fileName = "\(key)\(suffix).caf"
    let destination = soundsDir.appendingPathComponent(fileName)
    let longDestination = soundsDir.appendingPathComponent(
      "\(key)\(suffix)-long.caf")
    if isUpToDate(destination, comparedTo: source),
      isUpToDate(longDestination, comparedTo: source)
    {
      return fileName
    }

    var audio = source
    if (try? AVAudioFile(forReading: source)) == nil {
      // Video containers (imported .mp4/.mov) are not readable by
      // AVAudioFile; extract the audio track first, then convert that.
      let extracted = fileManager.temporaryDirectory
        .appendingPathComponent("\(key)-extract.m4a")
      try? fileManager.removeItem(at: extracted)
      try extractAudio(from: source, to: extracted)
      audio = extracted
    }
    defer {
      if audio != source { try? fileManager.removeItem(at: audio) }
    }
    try convert(audio, to: destination, seconds: notificationSeconds, compressed: false)
    // A failed long file is not fatal: AlarmKit then uses the short one.
    try? convert(audio, to: longDestination, seconds: alarmSeconds, compressed: true)
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

  /// Writes [seconds] of audio to [destination] by playing [source] from
  /// the start again each time it runs out.
  private static func convert(
    _ source: URL, to destination: URL, seconds: Double, compressed: Bool
  ) throws {
    let input = try AVAudioFile(forReading: source)
    let format = input.processingFormat
    guard input.length > 0 else { throw CocoaError(.fileReadCorruptFile) }
    var settings: [String: Any] = [
      AVSampleRateKey: format.sampleRate,
      AVNumberOfChannelsKey: format.channelCount,
    ]
    if compressed {
      settings[AVFormatIDKey] = kAudioFormatAppleIMA4
    } else {
      settings[AVFormatIDKey] = kAudioFormatLinearPCM
      settings[AVLinearPCMBitDepthKey] = 16
      settings[AVLinearPCMIsFloatKey] = false
      settings[AVLinearPCMIsBigEndianKey] = false
    }
    try? FileManager.default.removeItem(at: destination)
    do {
      let output = try AVAudioFile(
        forWriting: destination,
        settings: settings,
        commonFormat: format.commonFormat,
        interleaved: format.isInterleaved
      )

      var remaining = AVAudioFramePosition(seconds * format.sampleRate)
      let chunk: AVAudioFrameCount = 16_384
      guard let buffer = AVAudioPCMBuffer(pcmFormat: format, frameCapacity: chunk)
      else { throw CocoaError(.fileWriteUnknown) }
      while remaining > 0 {
        if input.framePosition >= input.length { input.framePosition = 0 }
        let frames = AVAudioFrameCount(
          min(AVAudioFramePosition(chunk), remaining, input.length - input.framePosition))
        try input.read(into: buffer, frameCount: frames)
        if buffer.frameLength == 0 {
          // Nothing more to read from here: start the clip over.
          input.framePosition = 0
          continue
        }
        try output.write(from: buffer)
        remaining -= AVAudioFramePosition(buffer.frameLength)
      }
    } catch {
      // Never leave a half-written file that a later run would trust.
      try? FileManager.default.removeItem(at: destination)
      throw error
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
