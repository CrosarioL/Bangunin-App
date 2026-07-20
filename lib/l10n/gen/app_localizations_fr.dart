// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for French (`fr`).
class AppLocalizationsFr extends AppLocalizations {
  AppLocalizationsFr([String locale = 'fr']) : super(locale);

  @override
  String get continueLabel => 'Continuer';

  @override
  String get cancel => 'Annuler';

  @override
  String get save => 'Enregistrer';

  @override
  String get delete => 'Supprimer';

  @override
  String get done => 'OK';

  @override
  String get retry => 'Réessayer';

  @override
  String get getStarted => 'Commencer';

  @override
  String get close => 'Fermer';

  @override
  String get back => 'Retour';

  @override
  String get abandonMission => 'Annuler la mission, garder l\'alarme active';

  @override
  String get genericError => 'Une erreur est survenue.\nVeuillez réessayer.';

  @override
  String get tabAlarms => 'Alarmes';

  @override
  String get tabStats => 'Série';

  @override
  String get tabSettings => 'Réglages';

  @override
  String get homeTitle => 'Alarmes';

  @override
  String get noUpcomingAlarm => 'Aucune alarme programmée';

  @override
  String ringsIn(String countdown) {
    return 'Sonne dans $countdown';
  }

  @override
  String get emptyAlarmsTitle => 'Pas encore d\'alarme';

  @override
  String get emptyAlarmsSubtitle =>
      'Créez votre première alarme et choisissez une mission qui vous sort du lit.';

  @override
  String get deleteAlarmTitle => 'Supprimer l\'alarme ?';

  @override
  String get deleteAlarmMessage =>
      'Cette alarme sera supprimée définitivement.';

  @override
  String get repeatOnce => 'Une fois';

  @override
  String get repeatEveryDay => 'Tous les jours';

  @override
  String get repeatWeekdays => 'En semaine';

  @override
  String get repeatWeekend => 'Week-end';

  @override
  String get dayMonShort => 'L';

  @override
  String get dayTueShort => 'M';

  @override
  String get dayWedShort => 'M';

  @override
  String get dayThuShort => 'J';

  @override
  String get dayFriShort => 'V';

  @override
  String get daySatShort => 'S';

  @override
  String get daySunShort => 'D';

  @override
  String get missionNone => 'Sans mission';

  @override
  String get missionObjectHunt => 'Chasse à l\'objet';

  @override
  String get missionSkyPhoto => 'Photo du ciel';

  @override
  String get missionGrassPhoto => 'Photo d\'herbe';

  @override
  String get missionMakeBed => 'Faire son lit';

  @override
  String get missionSquats => 'Squats';

  @override
  String get missionPushups => 'Pompes';

  @override
  String get missionNoneDescription => 'Arrêtez d\'un simple geste.';

  @override
  String get missionObjectHuntDescription =>
      'Rephotographiez un objet enregistré.';

  @override
  String get missionSkyPhotoDescription =>
      'Sortez et capturez le ciel du matin.';

  @override
  String get missionGrassPhotoDescription =>
      'Trouvez de la verdure et photographiez-la.';

  @override
  String get missionMakeBedDescription => 'Photographiez votre lit fait.';

  @override
  String get missionSquatsDescription =>
      'Tenez votre téléphone et faites des squats.';

  @override
  String get missionPushupsDescription =>
      'Tenez votre téléphone et faites des pompes.';

  @override
  String get newAlarm => 'Nouvelle alarme';

  @override
  String get editAlarm => 'Modifier l\'alarme';

  @override
  String get repeatSection => 'Répéter';

  @override
  String get missionSection => 'Mission de réveil';

  @override
  String get soundSection => 'Sonnerie';

  @override
  String get labelField => 'Libellé';

  @override
  String get labelHint => 'ex. Footing du matin';

  @override
  String get labelNone => 'Aucun';

  @override
  String get repsLabel => 'Répétitions';

  @override
  String get vibrate => 'Vibreur';

  @override
  String get snoozeSection => 'Rappel';

  @override
  String snoozeSummary(int minutes, int count) {
    return '$minutes min, max ${count}x';
  }

  @override
  String get soundClassic => 'Classique';

  @override
  String get soundSunrise => 'Aurore';

  @override
  String get soundPulse => 'Pulsation';

  @override
  String get soundCustom => 'Son personnalisé';

  @override
  String get importSound => 'Importer depuis audio ou vidéo';

  @override
  String get importSoundSubtitle =>
      'Utilisez n\'importe quel extrait de votre bibliothèque.';

  @override
  String get recordSound => 'Enregistrer le vôtre';

  @override
  String get stopRecording => 'Arrêter l\'enregistrement';

  @override
  String get registerObjectTitle => 'Enregistrer un objet';

  @override
  String get registerObjectSubtitle =>
      'Photographiez un objet loin de votre lit : le lavabo, la machine à café. Vous devrez le rephotographier pour arrêter l\'alarme.';

  @override
  String get usePhoto => 'Utiliser cette photo';

  @override
  String get retakePhoto => 'Reprendre';

  @override
  String get cameraPermissionNeeded =>
      'L\'accès à l\'appareil photo est requis pour les missions photo.';

  @override
  String get openSettings => 'Ouvrir les Réglages';

  @override
  String get cameraError => 'L\'appareil photo n\'a pas pu démarrer.';

  @override
  String get takePhoto => 'Prendre une photo';

  @override
  String get ringingWakeUp => 'Debout !';

  @override
  String get startMission => 'Lancer la mission';

  @override
  String get dismissAlarm => 'Arrêter';

  @override
  String snoozeWithRemaining(int minutes, int remaining) {
    return 'Rappel $minutes min ($remaining restants)';
  }

  @override
  String get verifyingPhoto => 'Vérification de votre photo…';

  @override
  String get missionPhotoFailed => 'Ce n\'est pas ça. Réessayez !';

  @override
  String get photoInstructionObject =>
      'Retrouvez votre objet enregistré et photographiez-le.';

  @override
  String get photoInstructionSky =>
      'Sortez et pointez l\'appareil vers le ciel.';

  @override
  String get photoInstructionGrass =>
      'Trouvez de l\'herbe ou une plante et photographiez-la.';

  @override
  String get photoInstructionBed => 'Faites votre lit, puis photographiez-le.';

  @override
  String get movementInstructionSquats =>
      'Tenez le téléphone contre votre poitrine et faites des squats.';

  @override
  String get movementInstructionPushups =>
      'Tenez le téléphone d\'une main et faites des pompes.';

  @override
  String repsOf(int target) {
    return 'sur $target';
  }

  @override
  String get movementHint =>
      'Bougez à un rythme régulier. Les secousses ne comptent pas.';

  @override
  String get notificationDefaultTitle => 'Debout !';

  @override
  String get notificationBodyNoMission => 'Il est temps de se lever.';

  @override
  String get notificationBodyMission =>
      'Terminez votre mission pour arrêter l\'alarme.';

  @override
  String get notificationBodySnoozeOver => 'Le rappel est terminé.';

  @override
  String get wakeSuccessTitle => 'Vous êtes debout. Mission accomplie !';

  @override
  String streakCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Série de $count jours',
      one: 'Série de 1 jour',
    );
    return '$_temp0';
  }

  @override
  String get startMyDay => 'Commencer ma journée';

  @override
  String get statsTitle => 'Vos matins';

  @override
  String get currentStreak => 'Série en cours';

  @override
  String get bestStreak => 'Meilleure série';

  @override
  String get avgWakeTime => 'Réveil moyen';

  @override
  String get totalWakes => 'Réveils';

  @override
  String get thisMonth => 'Ce mois-ci';

  @override
  String get onboardingWelcomeTitle => 'Réveillez-vous. Pour de vrai.';

  @override
  String get onboardingWelcomeSubtitle =>
      'L\'alarme qui vous fait prouver que vous êtes sorti du lit avant de s\'arrêter.';

  @override
  String get snoozeHabitQuestion =>
      'À quelle fréquence repoussez-vous l\'alarme ?';

  @override
  String get snoozeHabitNever => 'Presque jamais';

  @override
  String get snoozeHabitSometimes => 'Quelques fois par semaine';

  @override
  String get snoozeHabitAlways => 'Tous les matins';

  @override
  String get wakeGoalQuestion => 'À quelle heure voulez-vous vous lever ?';

  @override
  String get wakeGoalSubtitle =>
      'Nous proposerons cette heure pour votre première alarme.';

  @override
  String get strugglesQuestion => 'Que se passe-t-il après la sonnerie ?';

  @override
  String get strugglesSubtitle => 'Cochez tout ce qui vous parle.';

  @override
  String get struggleDismissAsleep => 'Je l\'éteins à moitié endormi';

  @override
  String get struggleStayInBed => 'Je reste au lit sur mon téléphone';

  @override
  String get strugglePhoneInBed => 'Je me rendors';

  @override
  String get struggleNoRoutine => 'Mes matins n\'ont aucune routine';

  @override
  String get notificationsTitle => 'Votre alarme a besoin de sonner';

  @override
  String get notificationsSubtitle =>
      'Autorisez les notifications pour que l\'alarme sonne même app fermée.';

  @override
  String get allowNotifications => 'Autoriser les notifications';

  @override
  String get personalizingTitle => 'Création de votre plan de réveil…';

  @override
  String get personalizingItem1 => 'Analyse de vos habitudes de rappel';

  @override
  String get personalizingItem2 => 'Choix de votre première mission';

  @override
  String get personalizingItem3 => 'Préparation de votre suivi de série';

  @override
  String get paywallTitle => 'Ne vous rendormez plus jamais';

  @override
  String get paywallSubtitle =>
      'Rejoignez des milliers de personnes qui ont remplacé le rappel par de vrais matins.';

  @override
  String get paywallFeatureMissions =>
      'Toutes les missions : photos, squats, pompes';

  @override
  String get paywallFeatureSounds =>
      'Sonneries personnalisées depuis audio ou vidéo';

  @override
  String get paywallFeatureStreaks => 'Séries et statistiques matinales';

  @override
  String get paywallFeatureNoLimit => 'Alarmes illimitées';

  @override
  String get planYearly => 'Annuel';

  @override
  String get bestValue => 'MEILLEURE OFFRE';

  @override
  String pricePerYear(String price) {
    return '$price par an';
  }

  @override
  String get restorePurchases => 'Restaurer les achats';

  @override
  String get paywallLegal =>
      'Renouvellement automatique jusqu\'à annulation. Annulable à tout moment dans les réglages de votre compte.';

  @override
  String get purchaseFailed =>
      'L\'achat n\'a pas abouti. Vous n\'avez pas été débité.';

  @override
  String get paywallLoadError =>
      'Impossible de charger les offres.\nVérifiez votre connexion et réessayez.';

  @override
  String get premiumActive => 'Premium actif';

  @override
  String get premiumActiveSubtitle =>
      'Toutes les missions et fonctionnalités débloquées.';

  @override
  String get settingsSectionGeneral => 'GÉNÉRAL';

  @override
  String get settingsNotifications => 'Réglages des notifications';

  @override
  String get nextAlarmIn => 'Prochaine alarme dans';

  @override
  String get settingsLanguage => 'Langue';

  @override
  String get languageSystemDefault => 'Langue du système';

  @override
  String get settingsSectionSupport => 'ASSISTANCE';

  @override
  String get contactSupport => 'Contacter l\'assistance';

  @override
  String get rateApp => 'Noter l\'app';

  @override
  String get settingsSectionLegal => 'MENTIONS LÉGALES';

  @override
  String get privacyPolicy => 'Politique de confidentialité';

  @override
  String get termsOfUse => 'Conditions d\'utilisation';

  @override
  String appVersion(String version) {
    return 'Version $version';
  }

  @override
  String get nameQuestion => 'Comment devons-nous vous appeler ?';

  @override
  String get nameHint => 'Votre prénom';

  @override
  String get ageQuestion => 'Quel âge avez-vous ?';

  @override
  String get ageSubtitle =>
      'Les besoins de sommeil évoluent avec l\'âge. Cela ajuste votre plan.';

  @override
  String get ageUnder18 => 'Moins de 18 ans';

  @override
  String get age18to24 => '18–24 ans';

  @override
  String get age25to34 => '25–34 ans';

  @override
  String get age35to54 => '35–54 ans';

  @override
  String get age55plus => '55 ans et plus';

  @override
  String get bedtimeQuestion =>
      'À quelle heure vous couchez-vous habituellement ?';

  @override
  String get bedtimeSubtitle =>
      'Nous nous en servirons pour vérifier votre créneau de sommeil.';

  @override
  String get painStatPrefix => 'Repousser l\'alarme va vous coûter environ';

  @override
  String painStatHours(int hours) {
    return '$hours heures';
  }

  @override
  String get painStatSuffix =>
      'cette année : des matins que vous ne récupérerez jamais.';

  @override
  String get painStatFootnote =>
      'Estimation basée sur vos réponses, à raison de 9 minutes par rappel.';

  @override
  String sleepWindowNote(String duration) {
    return 'Votre créneau de sommeil prévu est d\'environ $duration.';
  }

  @override
  String get motivationsQuestion =>
      'Que ferez-vous de vos matins plus sereins ?';

  @override
  String get motivationsSubtitle =>
      'Choisissez tout ce qui s\'applique. Cela façonne votre plan.';

  @override
  String get motivationExercise => 'Bouger mon corps';

  @override
  String get motivationBreakfast => 'Prendre un vrai petit-déjeuner';

  @override
  String get motivationDeepWork => 'Me concentrer avant que le bruit commence';

  @override
  String get motivationQuietTime => 'Un moment de calme pour moi';

  @override
  String get motivationFamily => 'Plus de temps avec ceux que j\'aime';

  @override
  String get commitmentTitle => 'Officialisez-le';

  @override
  String get commitmentBody =>
      'Les personnes qui s\'engagent envers un plan de réveil sont bien plus susceptibles de le tenir. Un geste, aucune signature nécessaire.';

  @override
  String get commitmentCta => 'Je suis prêt à mieux me réveiller';

  @override
  String get socialProofTitle => 'Vous êtes en bonne compagnie';

  @override
  String get socialProofSubtitle => 'Adopté par les lève-tôt partout';

  @override
  String get socialProofQuote1 =>
      'La mission squats paraît absurde jusqu\'à ce qu\'elle fonctionne. Je n\'ai pas reporté l\'alarme depuis trois semaines.';

  @override
  String get socialProofAuthor1 => 'Maya';

  @override
  String get socialProofQuote2 =>
      'Photographier le ciel m\'oblige à sortir. Mes matins m\'appartiennent enfin.';

  @override
  String get socialProofAuthor2 => 'Jonas';

  @override
  String get socialProofQuote3 =>
      'Je perdais une heure chaque jour. Maintenant je me lève avant mes enfants, et ça change tout.';

  @override
  String get socialProofAuthor3 => 'Priya';

  @override
  String personalizingTitleNamed(String name) {
    return 'Création du plan de réveil de $name…';
  }

  @override
  String planRevealTitleNamed(String name) {
    return '$name, votre plan est prêt';
  }

  @override
  String get planRevealTitle => 'Votre plan est prêt';

  @override
  String planRevealSubtitle(String time) {
    return 'Debout à $time en 30 jours, une mission à la fois.';
  }

  @override
  String get planChartNow => 'Maintenant';

  @override
  String get planChartGoal => 'Objectif';

  @override
  String get planChartDay1 => 'Jour 1';

  @override
  String get planChartDay30 => 'Jour 30';

  @override
  String get planRevealCta => 'Voir mon plan';

  @override
  String paywallTitleNamed(String name) {
    return '$name, ne vous rendormez plus jamais';
  }

  @override
  String paywallGoalLine(String time) {
    return 'Votre plan : debout à $time, tous les jours.';
  }

  @override
  String get planMonthly => 'Mensuel';

  @override
  String pricePerMonth(String price) {
    return '$price par mois';
  }

  @override
  String monthlyEquivalent(String price) {
    return '≈ $price/mois';
  }

  @override
  String get saveBadge => 'ÉCONOMISEZ 50 %';

  @override
  String get freeTrialToggle => 'Essai gratuit activé';

  @override
  String get trialToday => 'Aujourd\'hui';

  @override
  String get trialTodayBody =>
      'Débloquez toutes les missions, sonneries et statistiques.';

  @override
  String get trialDay2 => 'Jour 2';

  @override
  String get trialDay2Body =>
      'Nous vous préviendrons avant la fin de votre essai.';

  @override
  String trialDayFinal(int day) {
    return 'Jour $day';
  }

  @override
  String get trialDayFinalBody =>
      'Votre abonnement commence. Annulable à tout moment avant.';

  @override
  String paywallCtaTrial(int days) {
    return 'Commencer mon essai gratuit de $days jours';
  }

  @override
  String get paywallCtaNoTrial => 'Continuer';

  @override
  String get noPaymentNow => 'Aucun paiement pour l\'instant';

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
