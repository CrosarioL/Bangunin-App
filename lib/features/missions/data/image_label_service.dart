import 'package:google_mlkit_image_labeling/google_mlkit_image_labeling.dart';

/// On-device semantic check used by Make Bed. Only labels are returned to the
/// app; the image never leaves the phone and the detector is closed on exit.
class ImageLabelService {
  ImageLabelService()
    : _labeler = ImageLabeler(
        options: ImageLabelerOptions(confidenceThreshold: 0.45),
      );

  final ImageLabeler _labeler;

  Future<bool> containsBed(String path) async {
    final labels = await _labeler.processImage(InputImage.fromFilePath(path));
    const bedWords = <String>{
      'bed',
      'bedding',
      'bedroom',
      'mattress',
      'bed frame',
    };
    return labels.any((label) {
      final normalized = label.label.toLowerCase().trim();
      return label.confidence >= 0.45 &&
          bedWords.any(
            (word) => normalized == word || normalized.contains(word),
          );
    });
  }

  Future<void> dispose() => _labeler.close();
}
