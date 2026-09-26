import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/misc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:wakio/app/theme/app_theme.dart';
import 'package:wakio/l10n/gen/app_localizations.dart';

/// Wraps a widget in the app chrome (theme + localizations + ProviderScope)
/// for widget tests.
Widget testApp({required Widget child, List<Override> overrides = const []}) {
  return ProviderScope(
    overrides: overrides,
    child: MaterialApp(
      theme: AppTheme.dark,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      // Widget assertions exercise the settled UI. The production app now
      // contains deliberate idle/scanner loops, so disable motion here just
      // as iOS Reduce Motion would; otherwise pumpAndSettle can never finish.
      builder: (context, child) => MediaQuery(
        data: MediaQuery.of(context).copyWith(disableAnimations: true),
        child: child!,
      ),
      home: child,
    ),
  );
}

/// Advances transient UI motion without waiting for deliberate looping
/// animations (for example the breathing mascot) to report that they settled.
/// `pumpAndSettle` can never complete while those animations are on screen.
Future<void> pumpForAnimations(
  WidgetTester tester, {
  Duration duration = const Duration(seconds: 1),
}) async {
  const frame = Duration(milliseconds: 50);
  var elapsed = Duration.zero;
  while (elapsed < duration) {
    await tester.pump(frame);
    elapsed += frame;
  }
}
