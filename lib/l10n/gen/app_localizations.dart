import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_id.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'gen/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('id'),
  ];

  /// No description provided for @continueLabel.
  ///
  /// In en, this message translates to:
  /// **'Continue'**
  String get continueLabel;

  /// No description provided for @cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// No description provided for @save.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get save;

  /// No description provided for @delete.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get delete;

  /// No description provided for @done.
  ///
  /// In en, this message translates to:
  /// **'Done'**
  String get done;

  /// No description provided for @retry.
  ///
  /// In en, this message translates to:
  /// **'Try again'**
  String get retry;

  /// No description provided for @getStarted.
  ///
  /// In en, this message translates to:
  /// **'Get started'**
  String get getStarted;

  /// No description provided for @close.
  ///
  /// In en, this message translates to:
  /// **'Close'**
  String get close;

  /// No description provided for @back.
  ///
  /// In en, this message translates to:
  /// **'Back'**
  String get back;

  /// No description provided for @abandonMission.
  ///
  /// In en, this message translates to:
  /// **'Cancel mission, keep ringing'**
  String get abandonMission;

  /// No description provided for @genericError.
  ///
  /// In en, this message translates to:
  /// **'Something went wrong.\nPlease try again.'**
  String get genericError;

  /// No description provided for @tabAlarms.
  ///
  /// In en, this message translates to:
  /// **'Alarms'**
  String get tabAlarms;

  /// No description provided for @tabStats.
  ///
  /// In en, this message translates to:
  /// **'Streak'**
  String get tabStats;

  /// No description provided for @tabSettings.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get tabSettings;

  /// No description provided for @homeTitle.
  ///
  /// In en, this message translates to:
  /// **'Alarms'**
  String get homeTitle;

  /// No description provided for @noUpcomingAlarm.
  ///
  /// In en, this message translates to:
  /// **'No alarm scheduled'**
  String get noUpcomingAlarm;

  /// No description provided for @ringsIn.
  ///
  /// In en, this message translates to:
  /// **'Rings in {countdown}'**
  String ringsIn(String countdown);

  /// No description provided for @emptyAlarmsTitle.
  ///
  /// In en, this message translates to:
  /// **'No alarms yet'**
  String get emptyAlarmsTitle;

  /// No description provided for @emptyAlarmsSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Create your first alarm and pick a mission that gets you out of bed.'**
  String get emptyAlarmsSubtitle;

  /// No description provided for @deleteAlarmTitle.
  ///
  /// In en, this message translates to:
  /// **'Delete alarm?'**
  String get deleteAlarmTitle;

  /// No description provided for @deleteAlarmMessage.
  ///
  /// In en, this message translates to:
  /// **'This alarm will be removed permanently.'**
  String get deleteAlarmMessage;

  /// No description provided for @repeatOnce.
  ///
  /// In en, this message translates to:
  /// **'Once'**
  String get repeatOnce;

  /// No description provided for @repeatEveryDay.
  ///
  /// In en, this message translates to:
  /// **'Every day'**
  String get repeatEveryDay;

  /// No description provided for @repeatWeekdays.
  ///
  /// In en, this message translates to:
  /// **'Weekdays'**
  String get repeatWeekdays;

  /// No description provided for @repeatWeekend.
  ///
  /// In en, this message translates to:
  /// **'Weekend'**
  String get repeatWeekend;

  /// No description provided for @dayMonShort.
  ///
  /// In en, this message translates to:
  /// **'M'**
  String get dayMonShort;

  /// No description provided for @dayTueShort.
  ///
  /// In en, this message translates to:
  /// **'T'**
  String get dayTueShort;

  /// No description provided for @dayWedShort.
  ///
  /// In en, this message translates to:
  /// **'W'**
  String get dayWedShort;

  /// No description provided for @dayThuShort.
  ///
  /// In en, this message translates to:
  /// **'T'**
  String get dayThuShort;

  /// No description provided for @dayFriShort.
  ///
  /// In en, this message translates to:
  /// **'F'**
  String get dayFriShort;

  /// No description provided for @daySatShort.
  ///
  /// In en, this message translates to:
  /// **'S'**
  String get daySatShort;

  /// No description provided for @daySunShort.
  ///
  /// In en, this message translates to:
  /// **'S'**
  String get daySunShort;

  /// No description provided for @missionNone.
  ///
  /// In en, this message translates to:
  /// **'No mission'**
  String get missionNone;

  /// No description provided for @missionObjectHunt.
  ///
  /// In en, this message translates to:
  /// **'Object Hunt'**
  String get missionObjectHunt;

  /// No description provided for @missionSkyPhoto.
  ///
  /// In en, this message translates to:
  /// **'Sky Photo'**
  String get missionSkyPhoto;

  /// No description provided for @missionGrassPhoto.
  ///
  /// In en, this message translates to:
  /// **'Grass Photo'**
  String get missionGrassPhoto;

  /// No description provided for @missionMakeBed.
  ///
  /// In en, this message translates to:
  /// **'Make Your Bed'**
  String get missionMakeBed;

  /// No description provided for @missionSquats.
  ///
  /// In en, this message translates to:
  /// **'Squats'**
  String get missionSquats;

  /// No description provided for @missionPushups.
  ///
  /// In en, this message translates to:
  /// **'Pushups'**
  String get missionPushups;

  /// No description provided for @missionNoneDescription.
  ///
  /// In en, this message translates to:
  /// **'Dismiss with a single tap.'**
  String get missionNoneDescription;

  /// No description provided for @missionObjectHuntDescription.
  ///
  /// In en, this message translates to:
  /// **'Rephotograph an object you registered.'**
  String get missionObjectHuntDescription;

  /// No description provided for @missionSkyPhotoDescription.
  ///
  /// In en, this message translates to:
  /// **'Step outside and capture the morning sky.'**
  String get missionSkyPhotoDescription;

  /// No description provided for @missionGrassPhotoDescription.
  ///
  /// In en, this message translates to:
  /// **'Find something green and photograph it.'**
  String get missionGrassPhotoDescription;

  /// No description provided for @missionMakeBedDescription.
  ///
  /// In en, this message translates to:
  /// **'Take a photo of your made bed.'**
  String get missionMakeBedDescription;

  /// No description provided for @missionSquatsDescription.
  ///
  /// In en, this message translates to:
  /// **'Place your phone securely and complete squats.'**
  String get missionSquatsDescription;

  /// No description provided for @missionPushupsDescription.
  ///
  /// In en, this message translates to:
  /// **'Place your phone securely and complete pushups.'**
  String get missionPushupsDescription;

  /// No description provided for @missionRandomHunt.
  ///
  /// In en, this message translates to:
  /// **'Find It'**
  String get missionRandomHunt;

  /// No description provided for @missionRandomHuntDescription.
  ///
  /// In en, this message translates to:
  /// **'A random object is picked when it rings. Go find it. No setup.'**
  String get missionRandomHuntDescription;

  /// No description provided for @huntFind.
  ///
  /// In en, this message translates to:
  /// **'FIND: {object}'**
  String huntFind(String object);

  /// No description provided for @huntInstruction.
  ///
  /// In en, this message translates to:
  /// **'Point the camera at it to stop the alarm.'**
  String get huntInstruction;

  /// No description provided for @huntReroll.
  ///
  /// In en, this message translates to:
  /// **'Don\'t have it? Swap ({left} left)'**
  String huntReroll(int left);

  /// No description provided for @huntNoRerolls.
  ///
  /// In en, this message translates to:
  /// **'No swaps left. Go find it!'**
  String get huntNoRerolls;

  /// No description provided for @photoFailTargetNotFound.
  ///
  /// In en, this message translates to:
  /// **'Couldn\'t spot the {object} yet. Get it in the frame'**
  String photoFailTargetNotFound(String object);

  /// No description provided for @tryMission.
  ///
  /// In en, this message translates to:
  /// **'Try mission'**
  String get tryMission;

  /// No description provided for @missionPreviewTitle.
  ///
  /// In en, this message translates to:
  /// **'Mission preview'**
  String get missionPreviewTitle;

  /// No description provided for @missionPreviewSuccess.
  ///
  /// In en, this message translates to:
  /// **'Preview complete — this did not affect your alarm or streak.'**
  String get missionPreviewSuccess;

  /// No description provided for @newAlarm.
  ///
  /// In en, this message translates to:
  /// **'New alarm'**
  String get newAlarm;

  /// No description provided for @editAlarm.
  ///
  /// In en, this message translates to:
  /// **'Edit alarm'**
  String get editAlarm;

  /// No description provided for @repeatSection.
  ///
  /// In en, this message translates to:
  /// **'Repeat'**
  String get repeatSection;

  /// No description provided for @missionSection.
  ///
  /// In en, this message translates to:
  /// **'Wake-up mission'**
  String get missionSection;

  /// No description provided for @soundSection.
  ///
  /// In en, this message translates to:
  /// **'Sound'**
  String get soundSection;

  /// No description provided for @labelField.
  ///
  /// In en, this message translates to:
  /// **'Label'**
  String get labelField;

  /// No description provided for @labelHint.
  ///
  /// In en, this message translates to:
  /// **'e.g. Morning run'**
  String get labelHint;

  /// No description provided for @labelNone.
  ///
  /// In en, this message translates to:
  /// **'None'**
  String get labelNone;

  /// No description provided for @repsLabel.
  ///
  /// In en, this message translates to:
  /// **'Repetitions'**
  String get repsLabel;

  /// No description provided for @vibrate.
  ///
  /// In en, this message translates to:
  /// **'Vibration'**
  String get vibrate;

  /// No description provided for @snoozeSection.
  ///
  /// In en, this message translates to:
  /// **'Snooze'**
  String get snoozeSection;

  /// No description provided for @snoozeSummary.
  ///
  /// In en, this message translates to:
  /// **'{minutes} min, max {count}x'**
  String snoozeSummary(int minutes, int count);

  /// No description provided for @soundClassic.
  ///
  /// In en, this message translates to:
  /// **'Classic'**
  String get soundClassic;

  /// No description provided for @soundSunrise.
  ///
  /// In en, this message translates to:
  /// **'Sunrise'**
  String get soundSunrise;

  /// No description provided for @soundPulse.
  ///
  /// In en, this message translates to:
  /// **'Pulse'**
  String get soundPulse;

  /// No description provided for @soundCustom.
  ///
  /// In en, this message translates to:
  /// **'Custom sound'**
  String get soundCustom;

  /// No description provided for @importSound.
  ///
  /// In en, this message translates to:
  /// **'Import from audio or video'**
  String get importSound;

  /// No description provided for @importSoundSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Use any clip from your library as your alarm.'**
  String get importSoundSubtitle;

  /// No description provided for @recordSound.
  ///
  /// In en, this message translates to:
  /// **'Record your own'**
  String get recordSound;

  /// No description provided for @stopRecording.
  ///
  /// In en, this message translates to:
  /// **'Stop recording'**
  String get stopRecording;

  /// No description provided for @registerObjectTitle.
  ///
  /// In en, this message translates to:
  /// **'Register object'**
  String get registerObjectTitle;

  /// No description provided for @registerObjectSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Photograph an object far from your bed, like the bathroom sink or the coffee machine. You\'ll rephotograph it to stop the alarm.'**
  String get registerObjectSubtitle;

  /// No description provided for @usePhoto.
  ///
  /// In en, this message translates to:
  /// **'Use this photo'**
  String get usePhoto;

  /// No description provided for @retakePhoto.
  ///
  /// In en, this message translates to:
  /// **'Retake'**
  String get retakePhoto;

  /// No description provided for @cameraPermissionNeeded.
  ///
  /// In en, this message translates to:
  /// **'Camera access is needed to complete photo missions.'**
  String get cameraPermissionNeeded;

  /// No description provided for @openSettings.
  ///
  /// In en, this message translates to:
  /// **'Open Settings'**
  String get openSettings;

  /// No description provided for @batteryTitle.
  ///
  /// In en, this message translates to:
  /// **'Keep alarms working on this phone'**
  String get batteryTitle;

  /// No description provided for @batteryBody.
  ///
  /// In en, this message translates to:
  /// **'Your phone\'s battery saver can stop Bangunin waking you. Allow it to run in the background so your alarm always rings.'**
  String get batteryBody;

  /// No description provided for @batteryAllow.
  ///
  /// In en, this message translates to:
  /// **'Allow background running'**
  String get batteryAllow;

  /// No description provided for @batteryDone.
  ///
  /// In en, this message translates to:
  /// **'Background running allowed'**
  String get batteryDone;

  /// No description provided for @batteryStepsXiaomi.
  ///
  /// In en, this message translates to:
  /// **'Also turn on Autostart for Bangunin, and set its battery setting to \"No restrictions\". Usually under Settings > Apps > Manage apps > Bangunin.'**
  String get batteryStepsXiaomi;

  /// No description provided for @batteryStepsOppo.
  ///
  /// In en, this message translates to:
  /// **'Also turn on Auto-launch for Bangunin, and allow background activity. Usually under Settings > Apps > Bangunin.'**
  String get batteryStepsOppo;

  /// No description provided for @batteryStepsVivo.
  ///
  /// In en, this message translates to:
  /// **'Also turn on Autostart for Bangunin and allow high background power use. Usually under Settings > Apps > Bangunin.'**
  String get batteryStepsVivo;

  /// No description provided for @batteryStepsHuawei.
  ///
  /// In en, this message translates to:
  /// **'Also set Bangunin to \"Manage manually\" and enable Auto-launch. Usually under Settings > Battery > App launch.'**
  String get batteryStepsHuawei;

  /// No description provided for @batteryStepsTranssion.
  ///
  /// In en, this message translates to:
  /// **'Also turn on Autostart for Bangunin and allow it to run in the background. Usually under Settings > Apps > Bangunin.'**
  String get batteryStepsTranssion;

  /// No description provided for @batteryStepsGeneric.
  ///
  /// In en, this message translates to:
  /// **'If alarms still miss, check your phone\'s battery settings and allow Bangunin to run in the background.'**
  String get batteryStepsGeneric;

  /// No description provided for @batteryMenusVary.
  ///
  /// In en, this message translates to:
  /// **'Menu names differ between phones and Android versions, so look for the closest match.'**
  String get batteryMenusVary;

  /// No description provided for @notNow.
  ///
  /// In en, this message translates to:
  /// **'Not now'**
  String get notNow;

  /// No description provided for @alarmEngineFullTitle.
  ///
  /// In en, this message translates to:
  /// **'Rings even on silent'**
  String get alarmEngineFullTitle;

  /// No description provided for @alarmEngineFallbackBody.
  ///
  /// In en, this message translates to:
  /// **'Alarms use notifications on this iPhone. They won\'t ring in Silent Mode or a Focus, and they stop after about 30 seconds.'**
  String get alarmEngineFallbackBody;

  /// No description provided for @alarmEngineEnable.
  ///
  /// In en, this message translates to:
  /// **'Turn on real alarms'**
  String get alarmEngineEnable;

  /// No description provided for @alarmEngineEducationTitle.
  ///
  /// In en, this message translates to:
  /// **'Let Bangunin wake you properly'**
  String get alarmEngineEducationTitle;

  /// No description provided for @alarmEngineEducationBody.
  ///
  /// In en, this message translates to:
  /// **'iOS can let Bangunin ring like the built-in Clock — through Silent Mode, through a Focus, and full screen on your lock screen.\n\nWe\'ll ask for that permission next. Without it, alarms stay as ordinary notifications and are easy to sleep through.'**
  String get alarmEngineEducationBody;

  /// No description provided for @cameraError.
  ///
  /// In en, this message translates to:
  /// **'The camera couldn\'t start.'**
  String get cameraError;

  /// No description provided for @takePhoto.
  ///
  /// In en, this message translates to:
  /// **'Take photo'**
  String get takePhoto;

  /// No description provided for @ringingWakeUp.
  ///
  /// In en, this message translates to:
  /// **'Wake up!'**
  String get ringingWakeUp;

  /// No description provided for @startMission.
  ///
  /// In en, this message translates to:
  /// **'Start mission'**
  String get startMission;

  /// No description provided for @dismissAlarm.
  ///
  /// In en, this message translates to:
  /// **'Dismiss'**
  String get dismissAlarm;

  /// No description provided for @snoozeWithRemaining.
  ///
  /// In en, this message translates to:
  /// **'Snooze {minutes} min ({remaining} left)'**
  String snoozeWithRemaining(int minutes, int remaining);

  /// No description provided for @verifyingPhoto.
  ///
  /// In en, this message translates to:
  /// **'Checking your photo…'**
  String get verifyingPhoto;

  /// No description provided for @missionPhotoFailed.
  ///
  /// In en, this message translates to:
  /// **'That doesn\'t look right. Try again!'**
  String get missionPhotoFailed;

  /// No description provided for @photoInstructionObject.
  ///
  /// In en, this message translates to:
  /// **'Find your registered object and photograph it.'**
  String get photoInstructionObject;

  /// No description provided for @photoInstructionSky.
  ///
  /// In en, this message translates to:
  /// **'Step outside and point your camera at the sky.'**
  String get photoInstructionSky;

  /// No description provided for @photoInstructionGrass.
  ///
  /// In en, this message translates to:
  /// **'Find grass or a plant and photograph it.'**
  String get photoInstructionGrass;

  /// No description provided for @photoInstructionBed.
  ///
  /// In en, this message translates to:
  /// **'Make your bed, then photograph it.'**
  String get photoInstructionBed;

  /// No description provided for @movementInstructionSquats.
  ///
  /// In en, this message translates to:
  /// **'Hold your phone against your chest and do squats.'**
  String get movementInstructionSquats;

  /// No description provided for @movementInstructionPushups.
  ///
  /// In en, this message translates to:
  /// **'Hold your phone in one hand and do pushups.'**
  String get movementInstructionPushups;

  /// No description provided for @repsOf.
  ///
  /// In en, this message translates to:
  /// **'of {target}'**
  String repsOf(int target);

  /// No description provided for @movementHint.
  ///
  /// In en, this message translates to:
  /// **'Move at a steady pace. Rushed shakes don\'t count.'**
  String get movementHint;

  /// No description provided for @notificationDefaultTitle.
  ///
  /// In en, this message translates to:
  /// **'Wake up!'**
  String get notificationDefaultTitle;

  /// No description provided for @notificationBodyNoMission.
  ///
  /// In en, this message translates to:
  /// **'Time to get up.'**
  String get notificationBodyNoMission;

  /// No description provided for @notificationBodyMission.
  ///
  /// In en, this message translates to:
  /// **'Complete your mission to stop the alarm.'**
  String get notificationBodyMission;

  /// No description provided for @notificationBodySnoozeOver.
  ///
  /// In en, this message translates to:
  /// **'Snooze is over.'**
  String get notificationBodySnoozeOver;

  /// No description provided for @wakeSuccessTitle.
  ///
  /// In en, this message translates to:
  /// **'You\'re up. Mission complete!'**
  String get wakeSuccessTitle;

  /// No description provided for @streakCount.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 day streak} other{{count} day streak}}'**
  String streakCount(int count);

  /// No description provided for @startMyDay.
  ///
  /// In en, this message translates to:
  /// **'Start my day'**
  String get startMyDay;

  /// No description provided for @statsTitle.
  ///
  /// In en, this message translates to:
  /// **'Your mornings'**
  String get statsTitle;

  /// No description provided for @currentStreak.
  ///
  /// In en, this message translates to:
  /// **'Current streak'**
  String get currentStreak;

  /// No description provided for @bestStreak.
  ///
  /// In en, this message translates to:
  /// **'Best streak'**
  String get bestStreak;

  /// No description provided for @avgWakeTime.
  ///
  /// In en, this message translates to:
  /// **'Avg wake time'**
  String get avgWakeTime;

  /// No description provided for @totalWakes.
  ///
  /// In en, this message translates to:
  /// **'Total wakes'**
  String get totalWakes;

  /// No description provided for @thisMonth.
  ///
  /// In en, this message translates to:
  /// **'This month'**
  String get thisMonth;

  /// No description provided for @onboardingWelcomeTitle.
  ///
  /// In en, this message translates to:
  /// **'Normal alarms are easy to turn off in your sleep.'**
  String get onboardingWelcomeTitle;

  /// No description provided for @onboardingWelcomeSubtitle.
  ///
  /// In en, this message translates to:
  /// **'This one won\'t stop until you\'re actually up.'**
  String get onboardingWelcomeSubtitle;

  /// No description provided for @wakeGoalQuestion.
  ///
  /// In en, this message translates to:
  /// **'When should we wake you?'**
  String get wakeGoalQuestion;

  /// No description provided for @wakeGoalSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Weekdays. You can change it any time.'**
  String get wakeGoalSubtitle;

  /// No description provided for @notificationsTitle.
  ///
  /// In en, this message translates to:
  /// **'Your alarm needs a voice'**
  String get notificationsTitle;

  /// No description provided for @notificationsSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Allow notifications so your alarm can ring even when the app is closed.'**
  String get notificationsSubtitle;

  /// No description provided for @allowNotifications.
  ///
  /// In en, this message translates to:
  /// **'Allow notifications'**
  String get allowNotifications;

  /// No description provided for @paywallTitle.
  ///
  /// In en, this message translates to:
  /// **'Never oversleep again'**
  String get paywallTitle;

  /// No description provided for @paywallSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Join thousands who replaced snoozing with real mornings.'**
  String get paywallSubtitle;

  /// No description provided for @paywallFeatureMissions.
  ///
  /// In en, this message translates to:
  /// **'All wake-up missions: photos, squats, pushups'**
  String get paywallFeatureMissions;

  /// No description provided for @paywallFeatureSounds.
  ///
  /// In en, this message translates to:
  /// **'Custom alarm sounds from any audio or video'**
  String get paywallFeatureSounds;

  /// No description provided for @paywallFeatureStreaks.
  ///
  /// In en, this message translates to:
  /// **'Streaks and morning statistics'**
  String get paywallFeatureStreaks;

  /// No description provided for @paywallFeatureNoLimit.
  ///
  /// In en, this message translates to:
  /// **'Unlimited alarms'**
  String get paywallFeatureNoLimit;

  /// No description provided for @planYearly.
  ///
  /// In en, this message translates to:
  /// **'Yearly'**
  String get planYearly;

  /// No description provided for @bestValue.
  ///
  /// In en, this message translates to:
  /// **'BEST VALUE'**
  String get bestValue;

  /// No description provided for @pricePerYear.
  ///
  /// In en, this message translates to:
  /// **'{price} per year'**
  String pricePerYear(String price);

  /// No description provided for @restorePurchases.
  ///
  /// In en, this message translates to:
  /// **'Restore purchases'**
  String get restorePurchases;

  /// No description provided for @paywallLegal.
  ///
  /// In en, this message translates to:
  /// **'Auto-renews until cancelled. Cancel anytime in your store account settings.'**
  String get paywallLegal;

  /// No description provided for @purchaseFailed.
  ///
  /// In en, this message translates to:
  /// **'Purchase didn\'t complete. You haven\'t been charged.'**
  String get purchaseFailed;

  /// No description provided for @paywallLoadError.
  ///
  /// In en, this message translates to:
  /// **'Plans couldn\'t be loaded.\nCheck your connection and try again.'**
  String get paywallLoadError;

  /// No description provided for @premiumActive.
  ///
  /// In en, this message translates to:
  /// **'Premium active'**
  String get premiumActive;

  /// No description provided for @premiumActiveSubtitle.
  ///
  /// In en, this message translates to:
  /// **'All missions and features unlocked.'**
  String get premiumActiveSubtitle;

  /// No description provided for @settingsSectionGeneral.
  ///
  /// In en, this message translates to:
  /// **'GENERAL'**
  String get settingsSectionGeneral;

  /// No description provided for @settingsNotifications.
  ///
  /// In en, this message translates to:
  /// **'Notification settings'**
  String get settingsNotifications;

  /// No description provided for @nextAlarmIn.
  ///
  /// In en, this message translates to:
  /// **'Next alarm in'**
  String get nextAlarmIn;

  /// No description provided for @settingsLanguage.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get settingsLanguage;

  /// No description provided for @languageSystemDefault.
  ///
  /// In en, this message translates to:
  /// **'System default'**
  String get languageSystemDefault;

  /// No description provided for @settingsTheme.
  ///
  /// In en, this message translates to:
  /// **'Appearance'**
  String get settingsTheme;

  /// No description provided for @themeSystem.
  ///
  /// In en, this message translates to:
  /// **'System'**
  String get themeSystem;

  /// No description provided for @themeLight.
  ///
  /// In en, this message translates to:
  /// **'Light'**
  String get themeLight;

  /// No description provided for @themeDark.
  ///
  /// In en, this message translates to:
  /// **'Dark'**
  String get themeDark;

  /// No description provided for @settingsSectionSupport.
  ///
  /// In en, this message translates to:
  /// **'SUPPORT'**
  String get settingsSectionSupport;

  /// No description provided for @contactSupport.
  ///
  /// In en, this message translates to:
  /// **'Contact support'**
  String get contactSupport;

  /// No description provided for @rateApp.
  ///
  /// In en, this message translates to:
  /// **'Rate the app'**
  String get rateApp;

  /// No description provided for @settingsSectionLegal.
  ///
  /// In en, this message translates to:
  /// **'LEGAL'**
  String get settingsSectionLegal;

  /// No description provided for @privacyPolicy.
  ///
  /// In en, this message translates to:
  /// **'Privacy policy'**
  String get privacyPolicy;

  /// No description provided for @termsOfUse.
  ///
  /// In en, this message translates to:
  /// **'Terms of use'**
  String get termsOfUse;

  /// No description provided for @linkOpenFailed.
  ///
  /// In en, this message translates to:
  /// **'Couldn\'t open that link. Please try again.'**
  String get linkOpenFailed;

  /// No description provided for @supportEmailCopied.
  ///
  /// In en, this message translates to:
  /// **'No email app was found. hello@bangunin.app was copied.'**
  String get supportEmailCopied;

  /// No description provided for @appVersion.
  ///
  /// In en, this message translates to:
  /// **'Version {version}'**
  String appVersion(String version);

  /// No description provided for @socialProofTitle.
  ///
  /// In en, this message translates to:
  /// **'You\'re in good company'**
  String get socialProofTitle;

  /// No description provided for @socialProofSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Loved by early risers everywhere'**
  String get socialProofSubtitle;

  /// No description provided for @socialProofQuote1.
  ///
  /// In en, this message translates to:
  /// **'The squat mission sounds silly until it works. I haven\'t snoozed in three weeks.'**
  String get socialProofQuote1;

  /// No description provided for @socialProofAuthor1.
  ///
  /// In en, this message translates to:
  /// **'Maya'**
  String get socialProofAuthor1;

  /// No description provided for @socialProofQuote2.
  ///
  /// In en, this message translates to:
  /// **'Photographing the sky forces me outside. My mornings finally belong to me.'**
  String get socialProofQuote2;

  /// No description provided for @socialProofAuthor2.
  ///
  /// In en, this message translates to:
  /// **'Jonas'**
  String get socialProofAuthor2;

  /// No description provided for @socialProofQuote3.
  ///
  /// In en, this message translates to:
  /// **'I used to lose an hour every day. Now I\'m up before my kids, and it changes everything.'**
  String get socialProofQuote3;

  /// No description provided for @socialProofAuthor3.
  ///
  /// In en, this message translates to:
  /// **'Priya'**
  String get socialProofAuthor3;

  /// No description provided for @planChartNow.
  ///
  /// In en, this message translates to:
  /// **'Now'**
  String get planChartNow;

  /// No description provided for @planChartGoal.
  ///
  /// In en, this message translates to:
  /// **'Goal'**
  String get planChartGoal;

  /// No description provided for @planChartDay1.
  ///
  /// In en, this message translates to:
  /// **'Day 1'**
  String get planChartDay1;

  /// No description provided for @planChartDay30.
  ///
  /// In en, this message translates to:
  /// **'Day 30'**
  String get planChartDay30;

  /// No description provided for @paywallTitleNamed.
  ///
  /// In en, this message translates to:
  /// **'{name}, never oversleep again'**
  String paywallTitleNamed(String name);

  /// No description provided for @paywallGoalLine.
  ///
  /// In en, this message translates to:
  /// **'Your plan: out of bed at {time}, every day.'**
  String paywallGoalLine(String time);

  /// No description provided for @planMonthly.
  ///
  /// In en, this message translates to:
  /// **'Monthly'**
  String get planMonthly;

  /// No description provided for @pricePerMonth.
  ///
  /// In en, this message translates to:
  /// **'{price} per month'**
  String pricePerMonth(String price);

  /// No description provided for @monthlyEquivalent.
  ///
  /// In en, this message translates to:
  /// **'≈ {price}/month'**
  String monthlyEquivalent(String price);

  /// No description provided for @saveBadge.
  ///
  /// In en, this message translates to:
  /// **'SAVE 50%'**
  String get saveBadge;

  /// No description provided for @freeTrialToggle.
  ///
  /// In en, this message translates to:
  /// **'Free trial enabled'**
  String get freeTrialToggle;

  /// No description provided for @trialToday.
  ///
  /// In en, this message translates to:
  /// **'Today'**
  String get trialToday;

  /// No description provided for @trialTodayBody.
  ///
  /// In en, this message translates to:
  /// **'Unlock every mission, sound and stat.'**
  String get trialTodayBody;

  /// No description provided for @trialDay2.
  ///
  /// In en, this message translates to:
  /// **'Day 2'**
  String get trialDay2;

  /// No description provided for @trialDay2Body.
  ///
  /// In en, this message translates to:
  /// **'We\'ll remind you before your trial ends.'**
  String get trialDay2Body;

  /// No description provided for @trialDayFinal.
  ///
  /// In en, this message translates to:
  /// **'Day {day}'**
  String trialDayFinal(int day);

  /// No description provided for @trialDayFinalBody.
  ///
  /// In en, this message translates to:
  /// **'Your subscription starts. Cancel anytime before.'**
  String get trialDayFinalBody;

  /// No description provided for @paywallCtaTrial.
  ///
  /// In en, this message translates to:
  /// **'Start my {days}-day free trial'**
  String paywallCtaTrial(int days);

  /// No description provided for @paywallCtaNoTrial.
  ///
  /// In en, this message translates to:
  /// **'Continue'**
  String get paywallCtaNoTrial;

  /// No description provided for @noPaymentNow.
  ///
  /// In en, this message translates to:
  /// **'No payment due now'**
  String get noPaymentNow;

  /// No description provided for @manageSubscription.
  ///
  /// In en, this message translates to:
  /// **'Manage subscription'**
  String get manageSubscription;

  /// No description provided for @photoFailTooDark.
  ///
  /// In en, this message translates to:
  /// **'Too dark to check — try again in brighter light'**
  String get photoFailTooDark;

  /// No description provided for @photoFailTooBright.
  ///
  /// In en, this message translates to:
  /// **'Too bright to check — move away from the light'**
  String get photoFailTooBright;

  /// No description provided for @photoFailNotEnoughDetail.
  ///
  /// In en, this message translates to:
  /// **'We couldn\'t make out enough detail — get a bit closer'**
  String get photoFailNotEnoughDetail;

  /// No description provided for @photoFailSurface.
  ///
  /// In en, this message translates to:
  /// **'We couldn\'t verify that — point the camera at the real thing'**
  String get photoFailSurface;

  /// No description provided for @photoFailNotLive.
  ///
  /// In en, this message translates to:
  /// **'Hold the camera steady on the real scene and try again'**
  String get photoFailNotLive;

  /// No description provided for @photoFailNoMatch.
  ///
  /// In en, this message translates to:
  /// **'That doesn\'t look like your registered object'**
  String get photoFailNoMatch;

  /// No description provided for @photoFailNoHand.
  ///
  /// In en, this message translates to:
  /// **'Put your hand in the shot, touching the grass'**
  String get photoFailNoHand;

  /// No description provided for @photoFailNoReference.
  ///
  /// In en, this message translates to:
  /// **'No object registered yet — set one up in the alarm'**
  String get photoFailNoReference;

  /// No description provided for @missionSafetyNote.
  ///
  /// In en, this message translates to:
  /// **'Place the phone securely so your full body is visible. Do not hold it while exercising. Stop if you feel pain or dizzy.'**
  String get missionSafetyNote;

  /// No description provided for @poseGuidanceNoPerson.
  ///
  /// In en, this message translates to:
  /// **'We can\'t see you — step into the frame'**
  String get poseGuidanceNoPerson;

  /// No description provided for @poseGuidanceJointsHidden.
  ///
  /// In en, this message translates to:
  /// **'Move back so your arms and legs are fully visible'**
  String get poseGuidanceJointsHidden;

  /// No description provided for @poseGuidanceGetReady.
  ///
  /// In en, this message translates to:
  /// **'Hold the starting position to begin'**
  String get poseGuidanceGetReady;

  /// No description provided for @poseGuidanceGoDown.
  ///
  /// In en, this message translates to:
  /// **'Go down'**
  String get poseGuidanceGoDown;

  /// No description provided for @poseGuidanceComeUp.
  ///
  /// In en, this message translates to:
  /// **'Come back up'**
  String get poseGuidanceComeUp;

  /// No description provided for @poseGuidanceComplete.
  ///
  /// In en, this message translates to:
  /// **'Done — nice work'**
  String get poseGuidanceComplete;

  /// No description provided for @accessCodeTitle.
  ///
  /// In en, this message translates to:
  /// **'Enter access code'**
  String get accessCodeTitle;

  /// No description provided for @accessCodeHint.
  ///
  /// In en, this message translates to:
  /// **'Access code'**
  String get accessCodeHint;

  /// No description provided for @accessCodeRedeem.
  ///
  /// In en, this message translates to:
  /// **'Redeem'**
  String get accessCodeRedeem;

  /// No description provided for @accessCodeInvalid.
  ///
  /// In en, this message translates to:
  /// **'That access code is not valid.'**
  String get accessCodeInvalid;

  /// No description provided for @settingsOurStory.
  ///
  /// In en, this message translates to:
  /// **'Our story'**
  String get settingsOurStory;

  /// No description provided for @founderStoryTitle.
  ///
  /// In en, this message translates to:
  /// **'Why Bangunin exists'**
  String get founderStoryTitle;

  /// No description provided for @founderStoryBody.
  ///
  /// In en, this message translates to:
  /// **'In 2023 I was a third-semester student, living in a kos, a rented room, away from home for the first time.\n\nBack home, my mom always woke me up. \"Wake up, it\'s late!\" Every morning. I never realised how much I leaned on that until it was gone.\n\nIn the kos I set six alarms. I turned them all off with my eyes shut. I missed my 7 AM class three times in one month, my attendance grade tanked, and I hated myself every time I woke at 9 to the class group chat already blowing up.\n\nI tried every alarm on the Play Store. The one with a math problem: I memorised the answer. The one you shake: I shook it in my sleep. All of them were too easy to cheat, because a brain at 5 AM has exactly one goal: get back to bed.\n\nSo I built one I couldn\'t lie to. It only goes quiet once you\'re actually out of bed. Photograph the sky outside, do ten squats, photograph the bathroom sink. Things that are impossible half-asleep.\n\nThe first time I used it, I was furious. The second time, I laughed. By the third week, I hadn\'t overslept once.\n\nI gave it to my kos-mates. Then my whole cohort. Now I\'m giving it to you.\n\nBangunin wasn\'t built by a big startup in Silicon Valley. It was made by one student who was tired of missing class, for you, who feels exactly the same.\n\nGood morning. For real this time.'**
  String get founderStoryBody;

  /// No description provided for @founderStorySignature.
  ///
  /// In en, this message translates to:
  /// **'The founder of Bangunin'**
  String get founderStorySignature;

  /// No description provided for @onboardingSoundTitle.
  ///
  /// In en, this message translates to:
  /// **'Pick your alarm sound'**
  String get onboardingSoundTitle;

  /// No description provided for @onboardingSoundSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Tap one to hear it.'**
  String get onboardingSoundSubtitle;

  /// No description provided for @onboardingMissionTitle.
  ///
  /// In en, this message translates to:
  /// **'How will you prove you\'re awake?'**
  String get onboardingMissionTitle;

  /// No description provided for @onboardingMissionSubtitle.
  ///
  /// In en, this message translates to:
  /// **'The alarm keeps ringing until you do it.'**
  String get onboardingMissionSubtitle;

  /// No description provided for @onboardingMissionBadge.
  ///
  /// In en, this message translates to:
  /// **'Most fun'**
  String get onboardingMissionBadge;

  /// No description provided for @onboardingReadyTitle.
  ///
  /// In en, this message translates to:
  /// **'{when} at {time}.'**
  String onboardingReadyTitle(String when, String time);

  /// No description provided for @onboardingReadyHunt.
  ///
  /// In en, this message translates to:
  /// **'To turn it off you\'ll have to find a random object. We\'ll tell you which one when it rings.'**
  String get onboardingReadyHunt;

  /// No description provided for @onboardingReadyMission.
  ///
  /// In en, this message translates to:
  /// **'To turn it off: {mission}.'**
  String onboardingReadyMission(String mission);

  /// No description provided for @onboardingReadyNoMission.
  ///
  /// In en, this message translates to:
  /// **'One tap turns it off. You can add a mission any time.'**
  String get onboardingReadyNoMission;

  /// No description provided for @onboardingReadyFootnote.
  ///
  /// In en, this message translates to:
  /// **'Change the time, sound or mission whenever you like.'**
  String get onboardingReadyFootnote;

  /// No description provided for @onboardingReadyCta.
  ///
  /// In en, this message translates to:
  /// **'I\'m ready'**
  String get onboardingReadyCta;

  /// No description provided for @onboardingReadyToday.
  ///
  /// In en, this message translates to:
  /// **'Today'**
  String get onboardingReadyToday;

  /// No description provided for @onboardingReadyTomorrow.
  ///
  /// In en, this message translates to:
  /// **'Tomorrow'**
  String get onboardingReadyTomorrow;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'id'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'id':
      return AppLocalizationsId();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
