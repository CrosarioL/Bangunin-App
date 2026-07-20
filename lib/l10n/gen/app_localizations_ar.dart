// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Arabic (`ar`).
class AppLocalizationsAr extends AppLocalizations {
  AppLocalizationsAr([String locale = 'ar']) : super(locale);

  @override
  String get continueLabel => 'متابعة';

  @override
  String get cancel => 'إلغاء';

  @override
  String get save => 'حفظ';

  @override
  String get delete => 'حذف';

  @override
  String get done => 'تم';

  @override
  String get retry => 'إعادة المحاولة';

  @override
  String get getStarted => 'ابدأ الآن';

  @override
  String get close => 'إغلاق';

  @override
  String get back => 'رجوع';

  @override
  String get abandonMission => 'إلغاء المهمة، إبقاء المنبه يرن';

  @override
  String get genericError => 'حدث خطأ ما.\nحاول مرة أخرى.';

  @override
  String get tabAlarms => 'المنبهات';

  @override
  String get tabStats => 'السلسلة';

  @override
  String get tabSettings => 'الإعدادات';

  @override
  String get homeTitle => 'المنبهات';

  @override
  String get noUpcomingAlarm => 'لا يوجد منبه مجدول';

  @override
  String ringsIn(String countdown) {
    return 'يرن بعد $countdown';
  }

  @override
  String get emptyAlarmsTitle => 'لا توجد منبهات بعد';

  @override
  String get emptyAlarmsSubtitle => 'أنشئ أول منبه واختر مهمة تخرجك من السرير.';

  @override
  String get deleteAlarmTitle => 'حذف المنبه؟';

  @override
  String get deleteAlarmMessage => 'سيتم حذف هذا المنبه نهائيًا.';

  @override
  String get repeatOnce => 'مرة واحدة';

  @override
  String get repeatEveryDay => 'كل يوم';

  @override
  String get repeatWeekdays => 'أيام الأسبوع';

  @override
  String get repeatWeekend => 'عطلة الأسبوع';

  @override
  String get dayMonShort => 'ن';

  @override
  String get dayTueShort => 'ث';

  @override
  String get dayWedShort => 'ر';

  @override
  String get dayThuShort => 'خ';

  @override
  String get dayFriShort => 'ج';

  @override
  String get daySatShort => 'س';

  @override
  String get daySunShort => 'ح';

  @override
  String get missionNone => 'بدون مهمة';

  @override
  String get missionObjectHunt => 'البحث عن غرض';

  @override
  String get missionSkyPhoto => 'صورة السماء';

  @override
  String get missionGrassPhoto => 'صورة العشب';

  @override
  String get missionMakeBed => 'رتّب سريرك';

  @override
  String get missionSquats => 'تمرين القرفصاء';

  @override
  String get missionPushups => 'تمرين الضغط';

  @override
  String get missionNoneDescription => 'أوقفه بلمسة واحدة.';

  @override
  String get missionObjectHuntDescription =>
      'صوّر غرضًا سجّلته من قبل مرة أخرى.';

  @override
  String get missionSkyPhotoDescription => 'اخرج والتقط صورة لسماء الصباح.';

  @override
  String get missionGrassPhotoDescription => 'ابحث عن شيء أخضر وصوّره.';

  @override
  String get missionMakeBedDescription => 'التقط صورة لسريرك بعد ترتيبه.';

  @override
  String get missionSquatsDescription => 'أمسك هاتفك وقم بتمارين القرفصاء.';

  @override
  String get missionPushupsDescription => 'أمسك هاتفك وقم بتمارين الضغط.';

  @override
  String get newAlarm => 'منبه جديد';

  @override
  String get editAlarm => 'تعديل المنبه';

  @override
  String get repeatSection => 'التكرار';

  @override
  String get missionSection => 'مهمة الاستيقاظ';

  @override
  String get soundSection => 'الصوت';

  @override
  String get labelField => 'التسمية';

  @override
  String get labelHint => 'مثال: جري الصباح';

  @override
  String get labelNone => 'بدون';

  @override
  String get repsLabel => 'عدد التكرارات';

  @override
  String get vibrate => 'الاهتزاز';

  @override
  String get snoozeSection => 'الغفوة';

  @override
  String snoozeSummary(int minutes, int count) {
    return '$minutes دقيقة، بحد أقصى $count مرات';
  }

  @override
  String get soundClassic => 'كلاسيكي';

  @override
  String get soundSunrise => 'شروق';

  @override
  String get soundPulse => 'نبض';

  @override
  String get soundCustom => 'صوت مخصص';

  @override
  String get importSound => 'استيراد من ملف صوتي أو فيديو';

  @override
  String get importSoundSubtitle => 'استخدم أي مقطع من مكتبتك كنغمة للمنبه.';

  @override
  String get recordSound => 'سجّل صوتك';

  @override
  String get stopRecording => 'إيقاف التسجيل';

  @override
  String get registerObjectTitle => 'تسجيل غرض';

  @override
  String get registerObjectSubtitle =>
      'صوّر غرضًا بعيدًا عن سريرك، مثل حوض الحمام أو آلة القهوة. ستحتاج إلى تصويره مجددًا لإيقاف المنبه.';

  @override
  String get usePhoto => 'استخدام هذه الصورة';

  @override
  String get retakePhoto => 'إعادة الالتقاط';

  @override
  String get cameraPermissionNeeded =>
      'الوصول إلى الكاميرا مطلوب لإكمال مهام التصوير.';

  @override
  String get openSettings => 'فتح الإعدادات';

  @override
  String get cameraError => 'تعذّر تشغيل الكاميرا.';

  @override
  String get takePhoto => 'التقاط صورة';

  @override
  String get ringingWakeUp => 'استيقظ!';

  @override
  String get startMission => 'ابدأ المهمة';

  @override
  String get dismissAlarm => 'إيقاف';

  @override
  String snoozeWithRemaining(int minutes, int remaining) {
    return 'غفوة $minutes دقيقة (متبقٍ $remaining)';
  }

  @override
  String get verifyingPhoto => 'جارٍ التحقق من صورتك…';

  @override
  String get missionPhotoFailed => 'هذا لا يبدو صحيحًا. حاول مرة أخرى!';

  @override
  String get photoInstructionObject => 'اعثر على الغرض المسجل وصوّره.';

  @override
  String get photoInstructionSky => 'اخرج ووجّه الكاميرا نحو السماء.';

  @override
  String get photoInstructionGrass => 'اعثر على عشب أو نبتة وصوّرها.';

  @override
  String get photoInstructionBed => 'رتّب سريرك ثم صوّره.';

  @override
  String get movementInstructionSquats =>
      'أمسك هاتفك على صدرك وقم بتمارين القرفصاء.';

  @override
  String get movementInstructionPushups =>
      'أمسك هاتفك بيد واحدة وقم بتمارين الضغط.';

  @override
  String repsOf(int target) {
    return 'من $target';
  }

  @override
  String get movementHint => 'تحرّك بوتيرة ثابتة. الهزّ السريع لا يُحتسب.';

  @override
  String get notificationDefaultTitle => 'استيقظ!';

  @override
  String get notificationBodyNoMission => 'حان وقت النهوض.';

  @override
  String get notificationBodyMission => 'أكمل مهمتك لإيقاف المنبه.';

  @override
  String get notificationBodySnoozeOver => 'انتهت الغفوة.';

  @override
  String get wakeSuccessTitle => 'لقد استيقظت. اكتملت المهمة!';

  @override
  String streakCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'سلسلة $count يومًا',
      few: 'سلسلة $count أيام',
      two: 'سلسلة يومين',
      one: 'سلسلة يوم واحد',
    );
    return '$_temp0';
  }

  @override
  String get startMyDay => 'ابدأ يومي';

  @override
  String get statsTitle => 'صباحاتك';

  @override
  String get currentStreak => 'السلسلة الحالية';

  @override
  String get bestStreak => 'أفضل سلسلة';

  @override
  String get avgWakeTime => 'متوسط الاستيقاظ';

  @override
  String get totalWakes => 'مرات الاستيقاظ';

  @override
  String get thisMonth => 'هذا الشهر';

  @override
  String get onboardingWelcomeTitle => 'استيقظ. هذه المرة حقًا.';

  @override
  String get onboardingWelcomeSubtitle =>
      'المنبه الذي يطلب منك إثبات أنك غادرت السرير قبل أن يتوقف عن الرنين.';

  @override
  String get snoozeHabitQuestion => 'كم مرة تضغط على الغفوة؟';

  @override
  String get snoozeHabitNever => 'نادرًا جدًا';

  @override
  String get snoozeHabitSometimes => 'عدة مرات في الأسبوع';

  @override
  String get snoozeHabitAlways => 'كل صباح';

  @override
  String get wakeGoalQuestion => 'متى تريد أن تستيقظ؟';

  @override
  String get wakeGoalSubtitle => 'سنقترح هذا الوقت لأول منبه لك.';

  @override
  String get strugglesQuestion => 'ماذا يحدث بعد أن يرن المنبه؟';

  @override
  String get strugglesSubtitle => 'اختر كل ما ينطبق عليك.';

  @override
  String get struggleDismissAsleep => 'أوقفه وأنا نصف نائم';

  @override
  String get struggleStayInBed => 'أبقى في السرير أتصفح الهاتف';

  @override
  String get strugglePhoneInBed => 'أعود للنوم';

  @override
  String get struggleNoRoutine => 'صباحاتي بلا روتين';

  @override
  String get notificationsTitle => 'منبهك يحتاج إلى صوت';

  @override
  String get notificationsSubtitle =>
      'اسمح بالإشعارات ليتمكن المنبه من الرنين حتى مع إغلاق التطبيق.';

  @override
  String get allowNotifications => 'السماح بالإشعارات';

  @override
  String get personalizingTitle => 'جارٍ إنشاء خطة استيقاظك…';

  @override
  String get personalizingItem1 => 'تحليل عادات الغفوة لديك';

  @override
  String get personalizingItem2 => 'اختيار مهمتك الأولى';

  @override
  String get personalizingItem3 => 'تجهيز متتبع السلسلة';

  @override
  String get paywallTitle => 'لا تفوّت صباحك مجددًا';

  @override
  String get paywallSubtitle =>
      'انضم إلى الآلاف الذين استبدلوا الغفوة بصباحات حقيقية.';

  @override
  String get paywallFeatureMissions =>
      'كل مهام الاستيقاظ: الصور والقرفصاء والضغط';

  @override
  String get paywallFeatureSounds => 'نغمات مخصصة من أي ملف صوتي أو فيديو';

  @override
  String get paywallFeatureStreaks => 'السلاسل وإحصاءات الصباح';

  @override
  String get paywallFeatureNoLimit => 'منبهات غير محدودة';

  @override
  String get planYearly => 'سنوي';

  @override
  String get bestValue => 'أفضل قيمة';

  @override
  String pricePerYear(String price) {
    return '$price سنويًا';
  }

  @override
  String get restorePurchases => 'استعادة المشتريات';

  @override
  String get paywallLegal =>
      'يتجدد تلقائيًا حتى الإلغاء. يمكنك الإلغاء في أي وقت من إعدادات حسابك.';

  @override
  String get purchaseFailed => 'لم تكتمل عملية الشراء. لم يتم خصم أي مبلغ.';

  @override
  String get paywallLoadError =>
      'تعذّر تحميل الخطط.\nتحقق من اتصالك وحاول مجددًا.';

  @override
  String get premiumActive => 'بريميوم مفعّل';

  @override
  String get premiumActiveSubtitle => 'كل المهام والميزات مفتوحة.';

  @override
  String get settingsSectionGeneral => 'عام';

  @override
  String get settingsNotifications => 'إعدادات الإشعارات';

  @override
  String get nextAlarmIn => 'المنبه التالي بعد';

  @override
  String get settingsLanguage => 'اللغة';

  @override
  String get languageSystemDefault => 'افتراضي النظام';

  @override
  String get settingsSectionSupport => 'الدعم';

  @override
  String get contactSupport => 'تواصل مع الدعم';

  @override
  String get rateApp => 'قيّم التطبيق';

  @override
  String get settingsSectionLegal => 'قانوني';

  @override
  String get privacyPolicy => 'سياسة الخصوصية';

  @override
  String get termsOfUse => 'شروط الاستخدام';

  @override
  String appVersion(String version) {
    return 'الإصدار $version';
  }

  @override
  String get nameQuestion => 'بماذا نناديك؟';

  @override
  String get nameHint => 'اسمك الأول';

  @override
  String get ageQuestion => 'كم عمرك؟';

  @override
  String get ageSubtitle => 'احتياجات النوم تتغيّر مع العمر. هذا يضبط خطتك.';

  @override
  String get ageUnder18 => 'أقل من 18';

  @override
  String get age18to24 => '18–24';

  @override
  String get age25to34 => '25–34';

  @override
  String get age35to54 => '35–54';

  @override
  String get age55plus => '55+';

  @override
  String get bedtimeQuestion => 'متى تخلد إلى النوم عادةً؟';

  @override
  String get bedtimeSubtitle => 'سنستخدم هذا للتحقق من نافذة نومك.';

  @override
  String get painStatPrefix => 'الغفوة ستكلفك نحو';

  @override
  String painStatHours(int hours) {
    return '$hours ساعة';
  }

  @override
  String get painStatSuffix => 'هذا العام: صباحات لن تستعيدها أبدًا.';

  @override
  String get painStatFootnote =>
      'تقدير مبني على إجاباتك، بمعدل 9 دقائق لكل غفوة.';

  @override
  String sleepWindowNote(String duration) {
    return 'نافذة نومك المخطط لها تبلغ نحو $duration.';
  }

  @override
  String get motivationsQuestion => 'ماذا ستفعل بصباحاتك الأكثر هدوءًا؟';

  @override
  String get motivationsSubtitle => 'اختر كل ما ينطبق. هذا يشكّل خطتك.';

  @override
  String get motivationExercise => 'تحريك جسدي';

  @override
  String get motivationBreakfast => 'تناول فطور حقيقي';

  @override
  String get motivationDeepWork => 'التركيز قبل أن تبدأ الضوضاء';

  @override
  String get motivationQuietTime => 'وقت هادئ لنفسي';

  @override
  String get motivationFamily => 'وقت أطول مع من أحب';

  @override
  String get commitmentTitle => 'اجعلها رسمية';

  @override
  String get commitmentBody =>
      'الأشخاص الذين يلتزمون بخطة استيقاظ أكثر عرضة بكثير للاستمرار بها. لمسة واحدة، بلا توقيع.';

  @override
  String get commitmentCta => 'أنا مستعد للاستيقاظ بشكل أفضل';

  @override
  String get socialProofTitle => 'أنت في رفقة جيدة';

  @override
  String get socialProofSubtitle => 'محبوب من المستيقظين الباكرين في كل مكان';

  @override
  String get socialProofQuote1 =>
      'مهمة القرفصاء تبدو سخيفة إلى أن تنجح. لم أضغط زر الغفوة منذ ثلاثة أسابيع.';

  @override
  String get socialProofAuthor1 => 'مايا';

  @override
  String get socialProofQuote2 =>
      'تصوير السماء يجبرني على الخروج. صباحاتي أصبحت أخيرًا ملكي.';

  @override
  String get socialProofAuthor2 => 'يوناس';

  @override
  String get socialProofQuote3 =>
      'كنت أخسر ساعة كل يوم. الآن أستيقظ قبل أطفالي، وهذا يغيّر كل شيء.';

  @override
  String get socialProofAuthor3 => 'بريا';

  @override
  String personalizingTitleNamed(String name) {
    return 'جارٍ إعداد خطة استيقاظ $name…';
  }

  @override
  String planRevealTitleNamed(String name) {
    return '$name، خطتك جاهزة';
  }

  @override
  String get planRevealTitle => 'خطتك جاهزة';

  @override
  String planRevealSubtitle(String time) {
    return 'خارج السرير عند الساعة $time خلال 30 يومًا، مهمة تلو الأخرى.';
  }

  @override
  String get planChartNow => 'الآن';

  @override
  String get planChartGoal => 'الهدف';

  @override
  String get planChartDay1 => 'اليوم 1';

  @override
  String get planChartDay30 => 'اليوم 30';

  @override
  String get planRevealCta => 'عرض خطتي';

  @override
  String paywallTitleNamed(String name) {
    return '$name، لا تفوّت صباحك مجددًا';
  }

  @override
  String paywallGoalLine(String time) {
    return 'خطتك: خارج السرير عند الساعة $time، كل يوم.';
  }

  @override
  String get planMonthly => 'شهري';

  @override
  String pricePerMonth(String price) {
    return '$price شهريًا';
  }

  @override
  String monthlyEquivalent(String price) {
    return '≈ $price/شهريًا';
  }

  @override
  String get saveBadge => 'وفّر 50٪';

  @override
  String get freeTrialToggle => 'التجربة المجانية مفعّلة';

  @override
  String get trialToday => 'اليوم';

  @override
  String get trialTodayBody => 'افتح كل مهمة ونغمة وإحصائية.';

  @override
  String get trialDay2 => 'اليوم 2';

  @override
  String get trialDay2Body => 'سنذكّرك قبل انتهاء تجربتك.';

  @override
  String trialDayFinal(int day) {
    return 'اليوم $day';
  }

  @override
  String get trialDayFinalBody =>
      'يبدأ اشتراكك. يمكنك الإلغاء في أي وقت قبل ذلك.';

  @override
  String paywallCtaTrial(int days) {
    return 'ابدأ تجربتي المجانية لمدة $days أيام';
  }

  @override
  String get paywallCtaNoTrial => 'متابعة';

  @override
  String get noPaymentNow => 'لا دفع مطلوب الآن';

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
