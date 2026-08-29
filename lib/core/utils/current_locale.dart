import 'package:flutter/widgets.dart';

import '../../l10n/gen/app_localizations.dart';

/// Resolves localized strings outside the widget tree (background scheduling,
/// notification bodies). Mirrors Flutter's own locale-resolution algorithm
/// against the locales this app ships, falling back to English.
///
/// [override] is the user's explicit in-app language choice (see
/// `localeOverrideProvider`); when null, falls back to the phone's system
/// language, same as the rest of the app.
AppLocalizations currentLocalizations({Locale? override}) {
  final deviceLocale = WidgetsBinding.instance.platformDispatcher.locale;
  final resolved = basicLocaleListResolution([
    override ?? deviceLocale,
  ], AppLocalizations.supportedLocales);
  return lookupAppLocalizations(resolved);
}
