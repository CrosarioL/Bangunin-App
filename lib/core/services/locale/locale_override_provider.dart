import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/di/providers.dart';
import '../../../l10n/gen/app_localizations.dart';

const _prefsKey = 'locale_override';
const _followSystem = 'system';

/// The language for anyone who hasn't picked one.
const defaultLocale = Locale('id');

/// The app's language, independent of the phone's system language.
///
/// Bahasa Indonesia until the user chooses otherwise: Bangunin is made for
/// Indonesia, and many Indonesian phones are set to English. `null` means
/// "follow the phone", which is now an explicit choice in Settings.
final localeOverrideProvider =
    NotifierProvider<LocaleOverrideNotifier, Locale?>(
      LocaleOverrideNotifier.new,
    );

class LocaleOverrideNotifier extends Notifier<Locale?> {
  @override
  Locale? build() {
    final code = ref.watch(sharedPreferencesProvider).getString(_prefsKey);
    if (code == null) return defaultLocale;
    if (code == _followSystem) return null;
    final locale = Locale(code);
    // Guard against a stale saved code from a since-dropped locale.
    return AppLocalizations.supportedLocales.contains(locale) ? locale : null;
  }

  Future<void> set(Locale? locale) async {
    state = locale;
    final prefs = ref.read(sharedPreferencesProvider);
    if (locale == null) {
      await prefs.setString(_prefsKey, _followSystem);
    } else {
      await prefs.setString(_prefsKey, locale.languageCode);
    }
  }
}
