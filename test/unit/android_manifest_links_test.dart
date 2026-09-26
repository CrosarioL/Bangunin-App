import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  test('Android declares browser and email handlers for Settings links', () {
    final manifest = File(
      'android/app/src/main/AndroidManifest.xml',
    ).readAsStringSync();

    expect(manifest, contains('android:scheme="https"'));
    expect(manifest, contains('android:scheme="mailto"'));
    expect(manifest, contains('android.intent.action.SENDTO'));
  });
}
