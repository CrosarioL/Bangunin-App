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
  String get missionSquatsDescription =>
      'Place your phone securely and complete squats.';

  @override
  String get missionPushupsDescription =>
      'Place your phone securely and complete pushups.';

  @override
  String get missionRandomHunt => 'Find It';

  @override
  String get missionRandomHuntDescription =>
      'A random object is picked when it rings. Go find it. No setup.';

  @override
  String huntFind(String object) {
    return 'FIND: $object';
  }

  @override
  String get huntInstruction => 'Point the camera at it to stop the alarm.';

  @override
  String huntReroll(int left) {
    return 'Don\'t have it? Swap ($left left)';
  }

  @override
  String get huntNoRerolls => 'No swaps left. Go find it!';

  @override
  String photoFailTargetNotFound(String object) {
    return 'Couldn\'t spot the $object yet. Get it in the frame';
  }

  @override
  String get tryMission => 'Try mission';

  @override
  String get missionPreviewTitle => 'Mission preview';

  @override
  String get missionPreviewSuccess =>
      'Preview complete — this did not affect your alarm or streak.';

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
  String get batteryTitle => 'Keep alarms working on this phone';

  @override
  String get batteryBody =>
      'Your phone\'s battery saver can stop Bangunin waking you. Allow it to run in the background so your alarm always rings.';

  @override
  String get batteryAllow => 'Allow background running';

  @override
  String get batteryDone => 'Background running allowed';

  @override
  String get batteryStepsXiaomi =>
      'Also turn on Autostart for Bangunin, and set its battery setting to \"No restrictions\". Usually under Settings > Apps > Manage apps > Bangunin.';

  @override
  String get batteryStepsOppo =>
      'Also turn on Auto-launch for Bangunin, and allow background activity. Usually under Settings > Apps > Bangunin.';

  @override
  String get batteryStepsVivo =>
      'Also turn on Autostart for Bangunin and allow high background power use. Usually under Settings > Apps > Bangunin.';

  @override
  String get batteryStepsHuawei =>
      'Also set Bangunin to \"Manage manually\" and enable Auto-launch. Usually under Settings > Battery > App launch.';

  @override
  String get batteryStepsTranssion =>
      'Also turn on Autostart for Bangunin and allow it to run in the background. Usually under Settings > Apps > Bangunin.';

  @override
  String get batteryStepsGeneric =>
      'If alarms still miss, check your phone\'s battery settings and allow Bangunin to run in the background.';

  @override
  String get batteryMenusVary =>
      'Menu names differ between phones and Android versions, so look for the closest match.';

  @override
  String get notNow => 'Not now';

  @override
  String get alarmEngineFullTitle => 'Rings even on silent';

  @override
  String get alarmEngineFallbackBody =>
      'Alarms use notifications on this iPhone. They won\'t ring in Silent Mode or a Focus, and they stop after about 30 seconds.';

  @override
  String get alarmEngineEnable => 'Turn on real alarms';

  @override
  String get alarmEngineEducationTitle => 'Let Bangunin wake you properly';

  @override
  String get alarmEngineEducationBody =>
      'iOS can let Bangunin ring like the built-in Clock — through Silent Mode, through a Focus, and full screen on your lock screen.\n\nWe\'ll ask for that permission next. Without it, alarms stay as ordinary notifications and are easy to sleep through.';

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
  String get onboardingWelcomeTitle =>
      'Normal alarms are easy to turn off in your sleep.';

  @override
  String get onboardingWelcomeSubtitle =>
      'This one won\'t stop until you\'re actually up.';

  @override
  String get wakeGoalQuestion => 'When should we wake you?';

  @override
  String get wakeGoalSubtitle => 'Weekdays. You can change it any time.';

  @override
  String get notificationsTitle => 'Your alarm needs a voice';

  @override
  String get notificationsSubtitle =>
      'Allow notifications so your alarm can ring even when the app is closed.';

  @override
  String get allowNotifications => 'Allow notifications';

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
  String get settingsTheme => 'Appearance';

  @override
  String get themeSystem => 'System';

  @override
  String get themeLight => 'Light';

  @override
  String get themeDark => 'Dark';

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
  String get linkOpenFailed => 'Couldn\'t open that link. Please try again.';

  @override
  String get supportEmailCopied =>
      'No email app was found. hello@bangunin.app was copied.';

  @override
  String appVersion(String version) {
    return 'Version $version';
  }

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
  String get planChartNow => 'Now';

  @override
  String get planChartGoal => 'Goal';

  @override
  String get planChartDay1 => 'Day 1';

  @override
  String get planChartDay30 => 'Day 30';

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

  @override
  String get onboardingSoundTitle => 'Pick your alarm sound';

  @override
  String get onboardingSoundSubtitle => 'Tap one to hear it.';

  @override
  String get onboardingMissionTitle => 'How will you prove you\'re awake?';

  @override
  String get onboardingMissionSubtitle =>
      'The alarm keeps ringing until you do it.';

  @override
  String get onboardingMissionBadge => 'Most fun';

  @override
  String onboardingReadyTitle(String when, String time) {
    return '$when at $time.';
  }

  @override
  String get onboardingReadyHunt =>
      'To turn it off you\'ll have to find a random object. We\'ll tell you which one when it rings.';

  @override
  String onboardingReadyMission(String mission) {
    return 'To turn it off: $mission.';
  }

  @override
  String get onboardingReadyNoMission =>
      'One tap turns it off. You can add a mission any time.';

  @override
  String get onboardingReadyFootnote =>
      'Change the time, sound or mission whenever you like.';

  @override
  String get onboardingReadyCta => 'I\'m ready';

  @override
  String get onboardingReadyToday => 'Today';

  @override
  String get onboardingReadyTomorrow => 'Tomorrow';

  @override
  String get videoAlarmsSection => 'Video alarms';

  @override
  String get soundsSection => 'Sounds';

  @override
  String get missionMath => 'Math';

  @override
  String get missionMathDescription =>
      'Solve sums until your brain switches on.';

  @override
  String get missionShake => 'Shake';

  @override
  String get missionShakeDescription =>
      'Shake your phone hard until the counter fills.';

  @override
  String mathProgress(int current, int total) {
    return 'Problem $current of $total';
  }

  @override
  String get mathWrong => 'Not quite. Try this one.';

  @override
  String get shakeInstruction => 'Shake it! Hard!';

  @override
  String get shakeHint => 'Hold on tight and shake with your whole arm.';

  @override
  String get countProblems => 'Problems';

  @override
  String get countShakes => 'Shakes';

  @override
  String get emergencyLink => 'Emergency? Can\'t do the mission';

  @override
  String get emergencyTitle => 'Emergency exit';

  @override
  String emergencyTapBody(int left) {
    return 'Only for real emergencies. Tap $left more times.';
  }

  @override
  String get emergencyTapButton => 'Tap';

  @override
  String get emergencyPledgeBody => 'Type this out:';

  @override
  String get emergencyConfirm => 'Turn off alarm';

  @override
  String get emergencyCancel => 'Back to the alarm';

  @override
  String get emergencyDone =>
      'Alarm off. This morning won\'t count toward your streak.';

  @override
  String get wakeCheckNotificationTitle => 'Still awake?';

  @override
  String get wakeCheckNotificationBody =>
      'Tap within a minute, or your alarm rings again.';

  @override
  String get wakeCheckRingBody =>
      'You didn\'t confirm you\'re up. Back to the mission.';

  @override
  String missionStepOf(int step, int total, String mission) {
    return 'Mission $step of $total: $mission';
  }

  @override
  String get wakeCheckTitle => 'Still awake?';

  @override
  String get wakeCheckBody =>
      'Prove it, or your alarm comes back with its missions.';

  @override
  String wakeCheckCountdown(int seconds) {
    return '${seconds}s';
  }

  @override
  String get wakeCheckConfirm => 'I\'m awake';

  @override
  String get wakeCheckPassed => 'Nice. Good morning!';

  @override
  String missionNumber(int number) {
    return 'Mission $number';
  }

  @override
  String get addMission => 'Add another mission';

  @override
  String addMissionLimit(int max) {
    return 'up to $max';
  }

  @override
  String get removeMission => 'Remove this mission';

  @override
  String get wakeCheckSetting => 'Wake Up Check';

  @override
  String get wakeCheckOff => 'Off';

  @override
  String wakeCheckAfter(int minutes) {
    return '$minutes min after';
  }

  @override
  String get wakeCheckExplainer =>
      'A few minutes after you turn the alarm off, we check you\'re still up. Don\'t answer within a minute and it rings again, missions and all.';
}
