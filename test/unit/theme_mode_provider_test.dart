import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:wakio/app/di/providers.dart';
import 'package:wakio/core/services/theme/theme_mode_provider.dart';

void main() {
  test('theme defaults to system and persists an explicit choice', () async {
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();
    final container = ProviderContainer(
      overrides: [sharedPreferencesProvider.overrideWithValue(prefs)],
    );
    addTearDown(container.dispose);

    expect(container.read(themeModeProvider), ThemeMode.system);

    await container.read(themeModeProvider.notifier).set(ThemeMode.dark);

    expect(container.read(themeModeProvider), ThemeMode.dark);
    expect(prefs.getString('theme_mode'), 'dark');
  });

  test('saved theme is restored', () async {
    SharedPreferences.setMockInitialValues({'theme_mode': 'light'});
    final prefs = await SharedPreferences.getInstance();
    final container = ProviderContainer(
      overrides: [sharedPreferencesProvider.overrideWithValue(prefs)],
    );
    addTearDown(container.dispose);

    expect(container.read(themeModeProvider), ThemeMode.light);
  });
}
