import '../../../../l10n/gen/app_localizations.dart';
import '../../domain/entities/alarm.dart';

/// Shared by the sound picker sheet and the alarm editor's summary row so
/// the two never drift out of sync.
extension AlarmSoundL10n on AlarmSound {
  String localizedName(AppLocalizations l10n) => switch (this) {
    AlarmSound.classic => l10n.soundClassic,
    AlarmSound.sunrise => l10n.soundSunrise,
    AlarmSound.pulse => l10n.soundPulse,
    AlarmSound.custom => l10n.soundCustom,
  };
}
