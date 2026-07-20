// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for German (`de`).
class AppLocalizationsDe extends AppLocalizations {
  AppLocalizationsDe([String locale = 'de']) : super(locale);

  @override
  String get continueLabel => 'Weiter';

  @override
  String get cancel => 'Abbrechen';

  @override
  String get save => 'Sichern';

  @override
  String get delete => 'Löschen';

  @override
  String get done => 'Fertig';

  @override
  String get retry => 'Erneut versuchen';

  @override
  String get getStarted => 'Loslegen';

  @override
  String get close => 'Schließen';

  @override
  String get back => 'Zurück';

  @override
  String get abandonMission =>
      'Mission abbrechen, Wecker weiter klingeln lassen';

  @override
  String get genericError =>
      'Etwas ist schiefgelaufen.\nBitte erneut versuchen.';

  @override
  String get tabAlarms => 'Wecker';

  @override
  String get tabStats => 'Serie';

  @override
  String get tabSettings => 'Einstellungen';

  @override
  String get homeTitle => 'Wecker';

  @override
  String get noUpcomingAlarm => 'Kein Wecker geplant';

  @override
  String ringsIn(String countdown) {
    return 'Klingelt in $countdown';
  }

  @override
  String get emptyAlarmsTitle => 'Noch keine Wecker';

  @override
  String get emptyAlarmsSubtitle =>
      'Erstelle deinen ersten Wecker und wähle eine Mission, die dich aus dem Bett holt.';

  @override
  String get deleteAlarmTitle => 'Wecker löschen?';

  @override
  String get deleteAlarmMessage => 'Dieser Wecker wird dauerhaft entfernt.';

  @override
  String get repeatOnce => 'Einmalig';

  @override
  String get repeatEveryDay => 'Täglich';

  @override
  String get repeatWeekdays => 'Wochentags';

  @override
  String get repeatWeekend => 'Wochenende';

  @override
  String get dayMonShort => 'M';

  @override
  String get dayTueShort => 'D';

  @override
  String get dayWedShort => 'M';

  @override
  String get dayThuShort => 'D';

  @override
  String get dayFriShort => 'F';

  @override
  String get daySatShort => 'S';

  @override
  String get daySunShort => 'S';

  @override
  String get missionNone => 'Keine Mission';

  @override
  String get missionObjectHunt => 'Objektjagd';

  @override
  String get missionSkyPhoto => 'Himmelsfoto';

  @override
  String get missionGrassPhoto => 'Grasfoto';

  @override
  String get missionMakeBed => 'Bett machen';

  @override
  String get missionSquats => 'Kniebeugen';

  @override
  String get missionPushups => 'Liegestütze';

  @override
  String get missionNoneDescription => 'Mit einem Tipp ausschalten.';

  @override
  String get missionObjectHuntDescription =>
      'Fotografiere ein registriertes Objekt erneut.';

  @override
  String get missionSkyPhotoDescription =>
      'Geh raus und fotografiere den Morgenhimmel.';

  @override
  String get missionGrassPhotoDescription =>
      'Finde etwas Grünes und fotografiere es.';

  @override
  String get missionMakeBedDescription => 'Fotografiere dein gemachtes Bett.';

  @override
  String get missionSquatsDescription =>
      'Halte dein Handy und mache Kniebeugen.';

  @override
  String get missionPushupsDescription =>
      'Halte dein Handy und mache Liegestütze.';

  @override
  String get newAlarm => 'Neuer Wecker';

  @override
  String get editAlarm => 'Wecker bearbeiten';

  @override
  String get repeatSection => 'Wiederholen';

  @override
  String get missionSection => 'Weckmission';

  @override
  String get soundSection => 'Ton';

  @override
  String get labelField => 'Name';

  @override
  String get labelHint => 'z. B. Morgenlauf';

  @override
  String get labelNone => 'Keiner';

  @override
  String get repsLabel => 'Wiederholungen';

  @override
  String get vibrate => 'Vibration';

  @override
  String get snoozeSection => 'Schlummern';

  @override
  String snoozeSummary(int minutes, int count) {
    return '$minutes Min., max. ${count}x';
  }

  @override
  String get soundClassic => 'Klassisch';

  @override
  String get soundSunrise => 'Sonnenaufgang';

  @override
  String get soundPulse => 'Puls';

  @override
  String get soundCustom => 'Eigener Ton';

  @override
  String get importSound => 'Aus Audio oder Video importieren';

  @override
  String get importSoundSubtitle =>
      'Nutze jeden Clip aus deiner Mediathek als Weckton.';

  @override
  String get recordSound => 'Selbst aufnehmen';

  @override
  String get stopRecording => 'Aufnahme beenden';

  @override
  String get registerObjectTitle => 'Objekt registrieren';

  @override
  String get registerObjectSubtitle =>
      'Fotografiere ein Objekt weit weg vom Bett – das Waschbecken, die Kaffeemaschine. Du musst es erneut fotografieren, um den Wecker zu stoppen.';

  @override
  String get usePhoto => 'Dieses Foto verwenden';

  @override
  String get retakePhoto => 'Wiederholen';

  @override
  String get cameraPermissionNeeded =>
      'Für Foto-Missionen wird Kamerazugriff benötigt.';

  @override
  String get openSettings => 'Einstellungen öffnen';

  @override
  String get cameraError => 'Die Kamera konnte nicht gestartet werden.';

  @override
  String get takePhoto => 'Foto aufnehmen';

  @override
  String get ringingWakeUp => 'Aufstehen!';

  @override
  String get startMission => 'Mission starten';

  @override
  String get dismissAlarm => 'Ausschalten';

  @override
  String snoozeWithRemaining(int minutes, int remaining) {
    return '$minutes Min. schlummern (noch $remaining)';
  }

  @override
  String get verifyingPhoto => 'Foto wird geprüft…';

  @override
  String get missionPhotoFailed =>
      'Das sieht nicht richtig aus. Versuch\'s nochmal!';

  @override
  String get photoInstructionObject =>
      'Finde dein registriertes Objekt und fotografiere es.';

  @override
  String get photoInstructionSky =>
      'Geh raus und richte die Kamera auf den Himmel.';

  @override
  String get photoInstructionGrass =>
      'Finde Gras oder eine Pflanze und fotografiere sie.';

  @override
  String get photoInstructionBed => 'Mach dein Bett und fotografiere es dann.';

  @override
  String get movementInstructionSquats =>
      'Halte das Handy an die Brust und mache Kniebeugen.';

  @override
  String get movementInstructionPushups =>
      'Halte das Handy in einer Hand und mache Liegestütze.';

  @override
  String repsOf(int target) {
    return 'von $target';
  }

  @override
  String get movementHint =>
      'Bewege dich gleichmäßig – hektisches Schütteln zählt nicht.';

  @override
  String get notificationDefaultTitle => 'Aufstehen!';

  @override
  String get notificationBodyNoMission => 'Zeit aufzustehen.';

  @override
  String get notificationBodyMission =>
      'Schließe deine Mission ab, um den Wecker zu stoppen.';

  @override
  String get notificationBodySnoozeOver => 'Die Schlummerzeit ist vorbei.';

  @override
  String get wakeSuccessTitle => 'Du bist wach. Mission erfüllt!';

  @override
  String streakCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count Tage Serie',
      one: '1 Tag Serie',
    );
    return '$_temp0';
  }

  @override
  String get startMyDay => 'Meinen Tag starten';

  @override
  String get statsTitle => 'Deine Morgen';

  @override
  String get currentStreak => 'Aktuelle Serie';

  @override
  String get bestStreak => 'Beste Serie';

  @override
  String get avgWakeTime => 'Ø Weckzeit';

  @override
  String get totalWakes => 'Aufgestanden';

  @override
  String get thisMonth => 'Dieser Monat';

  @override
  String get onboardingWelcomeTitle => 'Wach auf. Diesmal wirklich.';

  @override
  String get onboardingWelcomeSubtitle =>
      'Der Wecker, der einen Beweis verlangt, dass du aus dem Bett bist, bevor er verstummt.';

  @override
  String get snoozeHabitQuestion => 'Wie oft drückst du auf Schlummern?';

  @override
  String get snoozeHabitNever => 'Fast nie';

  @override
  String get snoozeHabitSometimes => 'Ein paar Mal pro Woche';

  @override
  String get snoozeHabitAlways => 'Jeden einzelnen Morgen';

  @override
  String get wakeGoalQuestion => 'Wann willst du aufwachen?';

  @override
  String get wakeGoalSubtitle =>
      'Wir schlagen diese Zeit für deinen ersten Wecker vor.';

  @override
  String get strugglesQuestion => 'Was passiert, nachdem dein Wecker klingelt?';

  @override
  String get strugglesSubtitle => 'Wähle alles aus, was dir bekannt vorkommt.';

  @override
  String get struggleDismissAsleep => 'Ich schalte ihn im Halbschlaf aus';

  @override
  String get struggleStayInBed => 'Ich bleibe scrollend im Bett';

  @override
  String get strugglePhoneInBed => 'Ich schlafe wieder ein';

  @override
  String get struggleNoRoutine => 'Meine Morgen haben keine Routine';

  @override
  String get notificationsTitle => 'Dein Wecker braucht eine Stimme';

  @override
  String get notificationsSubtitle =>
      'Erlaube Mitteilungen, damit dein Wecker auch bei geschlossener App klingelt.';

  @override
  String get allowNotifications => 'Mitteilungen erlauben';

  @override
  String get personalizingTitle => 'Dein Weckplan wird erstellt…';

  @override
  String get personalizingItem1 => 'Schlummergewohnheiten werden analysiert';

  @override
  String get personalizingItem2 => 'Deine erste Mission wird gewählt';

  @override
  String get personalizingItem3 => 'Dein Serien-Tracker wird vorbereitet';

  @override
  String get paywallTitle => 'Nie wieder verschlafen';

  @override
  String get paywallSubtitle =>
      'Schließe dich Tausenden an, die Schlummern gegen echte Morgen getauscht haben.';

  @override
  String get paywallFeatureMissions =>
      'Alle Weckmissionen: Fotos, Kniebeugen, Liegestütze';

  @override
  String get paywallFeatureSounds => 'Eigene Wecktöne aus Audio oder Video';

  @override
  String get paywallFeatureStreaks => 'Serien und Morgenstatistiken';

  @override
  String get paywallFeatureNoLimit => 'Unbegrenzte Wecker';

  @override
  String get planYearly => 'Jährlich';

  @override
  String get bestValue => 'BESTER PREIS';

  @override
  String pricePerYear(String price) {
    return '$price pro Jahr';
  }

  @override
  String get restorePurchases => 'Käufe wiederherstellen';

  @override
  String get paywallLegal =>
      'Verlängert sich automatisch bis zur Kündigung. Jederzeit in den Kontoeinstellungen kündbar.';

  @override
  String get purchaseFailed =>
      'Der Kauf wurde nicht abgeschlossen. Dir wurde nichts berechnet.';

  @override
  String get paywallLoadError =>
      'Die Angebote konnten nicht geladen werden.\nPrüfe deine Verbindung und versuche es erneut.';

  @override
  String get premiumActive => 'Premium aktiv';

  @override
  String get premiumActiveSubtitle =>
      'Alle Missionen und Funktionen freigeschaltet.';

  @override
  String get settingsSectionGeneral => 'ALLGEMEIN';

  @override
  String get settingsNotifications => 'Mitteilungseinstellungen';

  @override
  String get nextAlarmIn => 'Nächster Wecker in';

  @override
  String get settingsLanguage => 'Sprache';

  @override
  String get languageSystemDefault => 'Systemstandard';

  @override
  String get settingsSectionSupport => 'SUPPORT';

  @override
  String get contactSupport => 'Support kontaktieren';

  @override
  String get rateApp => 'App bewerten';

  @override
  String get settingsSectionLegal => 'RECHTLICHES';

  @override
  String get privacyPolicy => 'Datenschutzerklärung';

  @override
  String get termsOfUse => 'Nutzungsbedingungen';

  @override
  String appVersion(String version) {
    return 'Version $version';
  }

  @override
  String get nameQuestion => 'Wie sollen wir dich nennen?';

  @override
  String get nameHint => 'Dein Vorname';

  @override
  String get ageQuestion => 'Wie alt bist du?';

  @override
  String get ageSubtitle =>
      'Der Schlafbedarf ändert sich mit dem Alter. Das passt deinen Plan an.';

  @override
  String get ageUnder18 => 'Unter 18';

  @override
  String get age18to24 => '18–24';

  @override
  String get age25to34 => '25–34';

  @override
  String get age35to54 => '35–54';

  @override
  String get age55plus => '55+';

  @override
  String get bedtimeQuestion => 'Wann gehst du normalerweise ins Bett?';

  @override
  String get bedtimeSubtitle => 'Damit prüfen wir dein Schlaffenster.';

  @override
  String get painStatPrefix => 'Schlummern kostet dich etwa';

  @override
  String painStatHours(int hours) {
    return '$hours Stunden';
  }

  @override
  String get painStatSuffix =>
      'in diesem Jahr: Morgen, die du nie zurückbekommst.';

  @override
  String get painStatFootnote =>
      'Geschätzt aus deinen Antworten, mit 9 Minuten pro Schlummern.';

  @override
  String sleepWindowNote(String duration) {
    return 'Dein geplantes Schlaffenster beträgt etwa $duration.';
  }

  @override
  String get motivationsQuestion =>
      'Was machst du mit deinen ruhigeren Morgen?';

  @override
  String get motivationsSubtitle =>
      'Wähle alles Zutreffende. Das prägt deinen Plan.';

  @override
  String get motivationExercise => 'Mich bewegen';

  @override
  String get motivationBreakfast => 'Ein richtiges Frühstück essen';

  @override
  String get motivationDeepWork => 'Fokussieren, bevor der Trubel beginnt';

  @override
  String get motivationQuietTime => 'Ruhige Zeit für mich';

  @override
  String get motivationFamily => 'Mehr Zeit mit den Menschen, die ich liebe';

  @override
  String get commitmentTitle => 'Mach es offiziell';

  @override
  String get commitmentBody =>
      'Wer sich zu einem Weckplan verpflichtet, bleibt viel eher dabei. Ein Tipp, keine Unterschrift nötig.';

  @override
  String get commitmentCta => 'Ich bin bereit, besser aufzuwachen';

  @override
  String get socialProofTitle => 'Du bist in guter Gesellschaft';

  @override
  String get socialProofSubtitle => 'Geliebt von Frühaufstehern überall';

  @override
  String get socialProofQuote1 =>
      'Die Kniebeugen-Mission klingt albern, bis sie funktioniert. Ich habe seit drei Wochen nicht mehr geschlummert.';

  @override
  String get socialProofAuthor1 => 'Maya';

  @override
  String get socialProofQuote2 =>
      'Den Himmel zu fotografieren zwingt mich raus. Meine Morgen gehören endlich mir.';

  @override
  String get socialProofAuthor2 => 'Jonas';

  @override
  String get socialProofQuote3 =>
      'Früher habe ich jeden Tag eine Stunde verloren. Jetzt bin ich vor meinen Kindern wach, und das verändert alles.';

  @override
  String get socialProofAuthor3 => 'Priya';

  @override
  String personalizingTitleNamed(String name) {
    return '${name}s Weckplan wird erstellt…';
  }

  @override
  String planRevealTitleNamed(String name) {
    return '$name, dein Plan ist fertig';
  }

  @override
  String get planRevealTitle => 'Dein Plan ist fertig';

  @override
  String planRevealSubtitle(String time) {
    return 'In 30 Tagen um $time aus dem Bett, eine Mission nach der anderen.';
  }

  @override
  String get planChartNow => 'Jetzt';

  @override
  String get planChartGoal => 'Ziel';

  @override
  String get planChartDay1 => 'Tag 1';

  @override
  String get planChartDay30 => 'Tag 30';

  @override
  String get planRevealCta => 'Meinen Plan ansehen';

  @override
  String paywallTitleNamed(String name) {
    return '$name, nie wieder verschlafen';
  }

  @override
  String paywallGoalLine(String time) {
    return 'Dein Plan: um $time aus dem Bett, jeden Tag.';
  }

  @override
  String get planMonthly => 'Monatlich';

  @override
  String pricePerMonth(String price) {
    return '$price pro Monat';
  }

  @override
  String monthlyEquivalent(String price) {
    return '≈ $price/Monat';
  }

  @override
  String get saveBadge => '50 % SPAREN';

  @override
  String get freeTrialToggle => 'Kostenlose Testphase aktiviert';

  @override
  String get trialToday => 'Heute';

  @override
  String get trialTodayBody =>
      'Schalte jede Mission, jeden Ton und jede Statistik frei.';

  @override
  String get trialDay2 => 'Tag 2';

  @override
  String get trialDay2Body => 'Wir erinnern dich, bevor deine Testphase endet.';

  @override
  String trialDayFinal(int day) {
    return 'Tag $day';
  }

  @override
  String get trialDayFinalBody => 'Dein Abo beginnt. Jederzeit vorher kündbar.';

  @override
  String paywallCtaTrial(int days) {
    return 'Meine $days-tägige kostenlose Testphase starten';
  }

  @override
  String get paywallCtaNoTrial => 'Weiter';

  @override
  String get noPaymentNow => 'Jetzt keine Zahlung fällig';

  @override
  String get settingsOurStory => 'Our story';

  @override
  String get founderStoryTitle => 'Why Bangunin exists';

  @override
  String get founderStoryBody =>
      'In 2023 I was a third-semester student, living in a kos, a rented room, away from home for the first time.\n\nBack home, my mom always woke me up. \"Wake up, it\'s late!\" Every morning. I never realised how much I leaned on that until it was gone.\n\nIn the kos I set six alarms. I turned them all off with my eyes shut. I missed my 7 AM class three times in one month, my attendance grade tanked, and I hated myself every time I woke at 9 to the class group chat already blowing up.\n\nI tried every alarm on the Play Store. The one with a math problem: I memorised the answer. The one you shake: I shook it in my sleep. All of them were too easy to cheat, because a brain at 5 AM has exactly one goal: get back to bed.\n\nSo I built one I couldn\'t lie to. It only goes quiet once you\'re actually out of bed. Photograph the sky outside, do ten squats, photograph the bathroom sink. Things that are impossible half-asleep.\n\nThe first time I used it, I was furious. The second time, I laughed. By the third week, I hadn\'t overslept once.\n\nI gave it to my kos-mates. Then my whole cohort. Now I\'m giving it to you.\n\nBangunin wasn\'t built by a big startup in Silicon Valley. It was made by one student who was tired of missing class, for you, who feels exactly the same.\n\nGood morning. For real this time.';

  @override
  String get founderStorySignature => 'The founder of Bangunin';
}
