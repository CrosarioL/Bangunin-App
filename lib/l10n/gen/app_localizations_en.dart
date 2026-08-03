// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get continueLabel => 'Continue';

  @override
  String get cancel => 'Cancel';

  @override
  String get save => 'Save';

  @override
  String get delete => 'Delete';

  @override
  String get done => 'Done';

  @override
  String get retry => 'Try again';

  @override
  String get getStarted => 'Get started';

  @override
  String get close => 'Close';

  @override
  String get back => 'Back';

  @override
  String get abandonMission => 'Cancel mission, keep ringing';

  @override
  String get genericError => 'Something went wrong.\nPlease try again.';

  @override
  String get tabAlarms => 'Alarms';

  @override
  String get tabStats => 'Streak';

  @override
  String get tabSettings => 'Settings';

  @override
  String get homeTitle => 'Alarms';

  @override
  String get noUpcomingAlarm => 'No alarm scheduled';

  @override
  String ringsIn(String countdown) {
    return 'Rings in $countdown';
  }

  @override
  String get emptyAlarmsTitle => 'No alarms yet';

  @override
  String get emptyAlarmsSubtitle =>
      'Create your first alarm and pick a mission that gets you out of bed.';

  @override
  String get deleteAlarmTitle => 'Delete alarm?';

  @override
  String get deleteAlarmMessage => 'This alarm will be removed permanently.';

  @override
  String get repeatOnce => 'Once';

  @override
  String get repeatEveryDay => 'Every day';

  @override
  String get repeatWeekdays => 'Weekdays';

  @override
  String get repeatWeekend => 'Weekend';

  @override
  String get dayMonShort => 'M';

  @override
  String get dayTueShort => 'T';

  @override
  String get dayWedShort => 'W';

  @override
  String get dayThuShort => 'T';

  @override
  String get dayFriShort => 'F';

  @override
  String get daySatShort => 'S';

  @override
  String get daySunShort => 'S';

  @override
  String get missionNone => 'No mission';

  @override
  String get missionObjectHunt => 'Object Hunt';

  @override
  String get missionSkyPhoto => 'Sky Photo';

  @override
  String get missionGrassPhoto => 'Grass Photo';

  @override
  String get missionMakeBed => 'Make Your Bed';

  @override
  String get missionSquats => 'Squats';

  @override
  String get missionPushups => 'Pushups';

  @override
  String get missionNoneDescription => 'Dismiss with a single tap.';

  @override
  String get missionObjectHuntDescription =>
      'Rephotograph an object you registered.';

  @override
  String get missionSkyPhotoDescription =>
      'Step outside and capture the morning sky.';

  @override
  String get missionGrassPhotoDescription =>
      'Find something green and photograph it.';

  @override
  String get missionMakeBedDescription => 'Take a photo of your made bed.';

  @override
  String get missionSquatsDescription => 'Hold your phone and complete squats.';

  @override
  String get missionPushupsDescription =>
      'Hold your phone and complete pushups.';

  @override
  String get newAlarm => 'New alarm';

  @override
  String get editAlarm => 'Edit alarm';

  @override
  String get repeatSection => 'Repeat';

  @override
  String get missionSection => 'Wake-up mission';

  @override
  String get soundSection => 'Sound';

  @override
  String get labelField => 'Label';

  @override
  String get labelHint => 'e.g. Morning run';

  @override
  String get labelNone => 'None';

  @override
  String get repsLabel => 'Repetitions';

  @override
  String get vibrate => 'Vibration';

  @override
  String get snoozeSection => 'Snooze';

  @override
  String snoozeSummary(int minutes, int count) {
    return '$minutes min, max ${count}x';
  }

  @override
  String get soundClassic => 'Classic';

  @override
  String get soundSunrise => 'Sunrise';

  @override
  String get soundPulse => 'Pulse';

  @override
  String get soundCustom => 'Custom sound';

  @override
  String get importSound => 'Import from audio or video';

  @override
  String get importSoundSubtitle =>
      'Use any clip from your library as your alarm.';

  @override
  String get recordSound => 'Record your own';

  @override
  String get stopRecording => 'Stop recording';

  @override
  String get registerObjectTitle => 'Register object';

  @override
  String get registerObjectSubtitle =>
      'Photograph an object far from your bed, like the bathroom sink or the coffee machine. You\'ll rephotograph it to stop the alarm.';

  @override
  String get usePhoto => 'Use this photo';

  @override
  String get retakePhoto => 'Retake';

  @override
  String get cameraPermissionNeeded =>
      'Camera access is needed to complete photo missions.';

  @override
  String get openSettings => 'Open Settings';

  @override
  String get cameraError => 'The camera couldn\'t start.';

  @override
  String get takePhoto => 'Take photo';

  @override
  String get ringingWakeUp => 'Wake up!';

  @override
  String get startMission => 'Start mission';

  @override
  String get dismissAlarm => 'Dismiss';

  @override
  String snoozeWithRemaining(int minutes, int remaining) {
    return 'Snooze $minutes min ($remaining left)';
  }

  @override
  String get verifyingPhoto => 'Checking your photo…';

  @override
  String get missionPhotoFailed => 'That doesn\'t look right. Try again!';

  @override
  String get photoInstructionObject =>
      'Find your registered object and photograph it.';

  @override
  String get photoInstructionSky =>
      'Step outside and point your camera at the sky.';

  @override
  String get photoInstructionGrass =>
      'Find grass or a plant and photograph it.';

  @override
  String get photoInstructionBed => 'Make your bed, then photograph it.';

  @override
  String get movementInstructionSquats =>
      'Hold your phone against your chest and do squats.';

  @override
  String get movementInstructionPushups =>
      'Hold your phone in one hand and do pushups.';

  @override
  String repsOf(int target) {
    return 'of $target';
  }

  @override
  String get movementHint =>
      'Move at a steady pace. Rushed shakes don\'t count.';

  @override
  String get notificationDefaultTitle => 'Wake up!';

  @override
  String get notificationBodyNoMission => 'Time to get up.';

  @override
  String get notificationBodyMission =>
      'Complete your mission to stop the alarm.';

  @override
  String get notificationBodySnoozeOver => 'Snooze is over.';

  @override
  String get wakeSuccessTitle => 'You\'re up. Mission complete!';

  @override
  String streakCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count day streak',
      one: '1 day streak',
    );
    return '$_temp0';
  }

  @override
  String get startMyDay => 'Start my day';

  @override
  String get statsTitle => 'Your mornings';

  @override
  String get currentStreak => 'Current streak';

  @override
  String get bestStreak => 'Best streak';

  @override
  String get avgWakeTime => 'Avg wake time';

  @override
  String get totalWakes => 'Total wakes';

  @override
  String get thisMonth => 'This month';

  @override
  String get onboardingWelcomeTitle => 'Wake up. For real this time.';

  @override
  String get onboardingWelcomeSubtitle =>
      'The alarm that makes you prove you\'re out of bed before it stops ringing.';

  @override
  String get snoozeHabitQuestion => 'How often do you hit snooze?';

  @override
  String get snoozeHabitNever => 'Almost never';

  @override
  String get snoozeHabitSometimes => 'A few times a week';

  @override
  String get snoozeHabitAlways => 'Every single morning';

  @override
  String get wakeGoalQuestion => 'When do you want to wake up?';

  @override
  String get wakeGoalSubtitle =>
      'We\'ll suggest this time for your first alarm.';

  @override
  String get strugglesQuestion => 'What happens after your alarm rings?';

  @override
  String get strugglesSubtitle => 'Pick everything that sounds familiar.';

  @override
  String get struggleDismissAsleep => 'I dismiss it half asleep';

  @override
  String get struggleStayInBed => 'I stay in bed scrolling';

  @override
  String get strugglePhoneInBed => 'I fall back asleep';

  @override
  String get struggleNoRoutine => 'My mornings have no routine';

  @override
  String get notificationsTitle => 'Your alarm needs a voice';

  @override
  String get notificationsSubtitle =>
      'Allow notifications so your alarm can ring even when the app is closed.';

  @override
  String get allowNotifications => 'Allow notifications';

  @override
  String get personalizingTitle => 'Building your wake-up plan…';

  @override
  String get personalizingItem1 => 'Analyzing your snooze habits';

  @override
  String get personalizingItem2 => 'Picking your first mission';

  @override
  String get personalizingItem3 => 'Preparing your streak tracker';

  @override
  String get paywallTitle => 'Never oversleep again';

  @override
  String get paywallSubtitle =>
      'Join thousands who replaced snoozing with real mornings.';

  @override
  String get paywallFeatureMissions =>
      'All wake-up missions: photos, squats, pushups';

  @override
  String get paywallFeatureSounds =>
      'Custom alarm sounds from any audio or video';

  @override
  String get paywallFeatureStreaks => 'Streaks and morning statistics';

  @override
  String get paywallFeatureNoLimit => 'Unlimited alarms';

  @override
  String get planYearly => 'Yearly';

  @override
  String get bestValue => 'BEST VALUE';

  @override
  String pricePerYear(String price) {
    return '$price per year';
  }

  @override
  String get restorePurchases => 'Restore purchases';

  @override
  String get paywallLegal =>
      'Auto-renews until cancelled. Cancel anytime in your store account settings.';

  @override
  String get purchaseFailed =>
      'Purchase didn\'t complete. You haven\'t been charged.';

  @override
  String get paywallLoadError =>
      'Plans couldn\'t be loaded.\nCheck your connection and try again.';

  @override
  String get premiumActive => 'Premium active';

  @override
  String get premiumActiveSubtitle => 'All missions and features unlocked.';

  @override
  String get settingsSectionGeneral => 'GENERAL';

  @override
  String get settingsNotifications => 'Notification settings';

  @override
  String get nextAlarmIn => 'Next alarm in';

  @override
  String get settingsLanguage => 'Language';

  @override
  String get languageSystemDefault => 'System default';

  @override
  String get settingsSectionSupport => 'SUPPORT';

  @override
  String get contactSupport => 'Contact support';

  @override
  String get rateApp => 'Rate the app';

  @override
  String get settingsSectionLegal => 'LEGAL';

  @override
  String get privacyPolicy => 'Privacy policy';

  @override
  String get termsOfUse => 'Terms of use';

  @override
  String appVersion(String version) {
    return 'Version $version';
  }

  @override
  String get nameQuestion => 'What should we call you?';

  @override
  String get nameHint => 'Your first name';

  @override
  String get ageQuestion => 'How old are you?';

  @override
  String get ageSubtitle =>
      'Sleep needs change with age. This tunes your plan.';

  @override
  String get ageUnder18 => 'Under 18';

  @override
  String get age18to24 => '18–24';

  @override
  String get age25to34 => '25–34';

  @override
  String get age35to54 => '35–54';

  @override
  String get age55plus => '55+';

  @override
  String get bedtimeQuestion => 'When do you usually go to bed?';

  @override
  String get bedtimeSubtitle => 'We\'ll use this to check your sleep window.';

  @override
  String get painStatPrefix => 'Snoozing will cost you about';

  @override
  String painStatHours(int hours) {
    return '$hours hours';
  }

  @override
  String get painStatSuffix => 'this year: mornings you never get back.';

  @override
  String get painStatFootnote =>
      'Estimated from your answers, at 9 minutes per snooze.';

  @override
  String sleepWindowNote(String duration) {
    return 'Your planned sleep window is about $duration.';
  }

  @override
  String get motivationsQuestion =>
      'What will you do with your calmer mornings?';

  @override
  String get motivationsSubtitle =>
      'Choose all that apply. This shapes your plan.';

  @override
  String get motivationExercise => 'Move my body';

  @override
  String get motivationBreakfast => 'Eat a real breakfast';

  @override
  String get motivationDeepWork => 'Focus before the noise starts';

  @override
  String get motivationQuietTime => 'Quiet time for myself';

  @override
  String get motivationFamily => 'More time with the people I love';

  @override
  String get commitmentTitle => 'Make it official';

  @override
  String get commitmentBody =>
      'People who commit to a wake-up plan are far more likely to stick with it. One tap, no signature needed.';

  @override
  String get commitmentCta => 'I\'m ready to wake up better';

  @override
  String get socialProofTitle => 'You\'re in good company';

  @override
  String get socialProofSubtitle => 'Loved by early risers everywhere';

  @override
  String get socialProofQuote1 =>
      'The squat mission sounds silly until it works. I haven\'t snoozed in three weeks.';

  @override
  String get socialProofAuthor1 => 'Maya';

  @override
  String get socialProofQuote2 =>
      'Photographing the sky forces me outside. My mornings finally belong to me.';

  @override
  String get socialProofAuthor2 => 'Jonas';

  @override
  String get socialProofQuote3 =>
      'I used to lose an hour every day. Now I\'m up before my kids, and it changes everything.';

  @override
  String get socialProofAuthor3 => 'Priya';

  @override
  String personalizingTitleNamed(String name) {
    return 'Building $name\'s wake-up plan…';
  }

  @override
  String planRevealTitleNamed(String name) {
    return '$name, your plan is ready';
  }

  @override
  String get planRevealTitle => 'Your plan is ready';

  @override
  String planRevealSubtitle(String time) {
    return 'Out of bed at $time within 30 days, one mission at a time.';
  }

  @override
  String get planChartNow => 'Now';

  @override
  String get planChartGoal => 'Goal';

  @override
  String get planChartDay1 => 'Day 1';

  @override
  String get planChartDay30 => 'Day 30';

  @override
  String get planRevealCta => 'See my plan';

  @override
  String paywallTitleNamed(String name) {
    return '$name, never oversleep again';
  }

  @override
  String paywallGoalLine(String time) {
    return 'Your plan: out of bed at $time, every day.';
  }

  @override
  String get planMonthly => 'Monthly';

  @override
  String pricePerMonth(String price) {
    return '$price per month';
  }

  @override
  String monthlyEquivalent(String price) {
    return '≈ $price/month';
  }

  @override
  String get saveBadge => 'SAVE 50%';

  @override
  String get freeTrialToggle => 'Free trial enabled';

  @override
  String get trialToday => 'Today';

  @override
  String get trialTodayBody => 'Unlock every mission, sound and stat.';

  @override
  String get trialDay2 => 'Day 2';

  @override
  String get trialDay2Body => 'We\'ll remind you before your trial ends.';

  @override
  String trialDayFinal(int day) {
    return 'Day $day';
  }

  @override
  String get trialDayFinalBody =>
      'Your subscription starts. Cancel anytime before.';

  @override
  String paywallCtaTrial(int days) {
    return 'Start my $days-day free trial';
  }

  @override
  String get paywallCtaNoTrial => 'Continue';

  @override
  String get noPaymentNow => 'No payment due now';

  @override
  String get manageSubscription => 'Manage subscription';

  @override
  String get photoFailTooDark =>
      'Too dark to check — try again in brighter light';

  @override
  String get photoFailTooBright =>
      'Too bright to check — move away from the light';

  @override
  String get photoFailNotEnoughDetail =>
      'We couldn\'t make out enough detail — get a bit closer';

  @override
  String get photoFailSurface =>
      'We couldn\'t verify that — point the camera at the real thing';

  @override
  String get photoFailNotLive =>
      'Hold the camera steady on the real scene and try again';

  @override
  String get photoFailNoMatch =>
      'That doesn\'t look like your registered object';

  @override
  String get photoFailNoHand => 'Put your hand in the shot, touching the grass';

  @override
  String get photoFailNoReference =>
      'No object registered yet — set one up in the alarm';

  @override
  String get missionSafetyNote =>
      'Place the phone securely so your full body is visible. Do not hold it while exercising. Stop if you feel pain or dizzy.';

  @override
  String get poseGuidanceNoPerson => 'We can\'t see you — step into the frame';

  @override
  String get poseGuidanceJointsHidden =>
      'Move back so your arms and legs are fully visible';

  @override
  String get poseGuidanceGetReady => 'Hold the starting position to begin';

  @override
  String get poseGuidanceGoDown => 'Go down';

  @override
  String get poseGuidanceComeUp => 'Come back up';

  @override
  String get poseGuidanceComplete => 'Done — nice work';

  @override
  String get accessCodeTitle => 'Enter access code';

  @override
  String get accessCodeHint => 'Access code';

  @override
  String get accessCodeRedeem => 'Redeem';

  @override
  String get accessCodeInvalid => 'That access code is not valid.';

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
