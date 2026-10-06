import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:wakio/app/di/providers.dart';
import 'package:wakio/core/services/locale/locale_override_provider.dart';

Future<ProviderContainer> _container(Map<String, Object> saved) async {
  SharedPreferences.setMockInitialValues(saved);
  final prefs = await SharedPreferences.getInstance();
  final container = ProviderContainer(
    overrides: [sharedPreferencesProvider.overrideWithValue(prefs)],
  );
  addTearDown(container.dispose);
  return container;
}

void main() {
  test('someone who never chose gets Bahasa Indonesia', () async {
    final c = await _container({});
    expect(c.read(localeOverrideProvider), const Locale('id'));
  });

  test('choosing System default follows the phone and is remembered', () async {
    final c = await _container({});
    await c.read(localeOverrideProvider.notifier).set(null);
    expect(c.read(localeOverrideProvider), isNull);

    final reopened = await _container({'locale_override': 'system'});
    expect(reopened.read(localeOverrideProvider), isNull);
  });

  test('an explicit English choice is kept', () async {
    final c = await _container({'locale_override': 'en'});
    expect(c.read(localeOverrideProvider), const Locale('en'));
  });
}
