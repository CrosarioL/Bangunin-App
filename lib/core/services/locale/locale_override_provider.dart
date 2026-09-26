import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/di/providers.dart';
import '../../../l10n/gen/app_localizations.dart';

const _prefsKey = 'locale_override';

/// The user's explicit in-app language choice, independent of the phone's
/// system language. `null` means "follow system" (the default).
final localeOverrideProvider =
    NotifierProvider<LocaleOverrideNotifier, Locale?>(
      LocaleOverrideNotifier.new,
    );

class LocaleOverrideNotifier extends Notifier<Locale?> {
  @override
  Locale? build() {
    final code = ref.watch(sharedPreferencesProvider).getString(_prefsKey);
    if (code == null) return null;
    final locale = Locale(code);
    // Guard against a stale saved code from a since-dropped locale.
    return AppLocalizations.supportedLocales.contains(locale) ? locale : null;
  }

  Future<void> set(Locale? locale) async {
    state = locale;
    final prefs = ref.read(sharedPreferencesProvider);
    if (locale == null) {
      await prefs.remove(_prefsKey);
    } else {
      await prefs.setString(_prefsKey, locale.languageCode);
    }
  }
}
