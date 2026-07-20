// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Spanish Castilian (`es`).
class AppLocalizationsEs extends AppLocalizations {
  AppLocalizationsEs([String locale = 'es']) : super(locale);

  @override
  String get continueLabel => 'Continuar';

  @override
  String get cancel => 'Cancelar';

  @override
  String get save => 'Guardar';

  @override
  String get delete => 'Eliminar';

  @override
  String get done => 'Listo';

  @override
  String get retry => 'Reintentar';

  @override
  String get getStarted => 'Empezar';

  @override
  String get close => 'Cerrar';

  @override
  String get back => 'Atrás';

  @override
  String get abandonMission => 'Cancelar misión, seguir sonando';

  @override
  String get genericError => 'Algo salió mal.\nInténtalo de nuevo.';

  @override
  String get tabAlarms => 'Alarmas';

  @override
  String get tabStats => 'Racha';

  @override
  String get tabSettings => 'Ajustes';

  @override
  String get homeTitle => 'Alarmas';

  @override
  String get noUpcomingAlarm => 'Sin alarmas programadas';

  @override
  String ringsIn(String countdown) {
    return 'Suena en $countdown';
  }

  @override
  String get emptyAlarmsTitle => 'Aún no hay alarmas';

  @override
  String get emptyAlarmsSubtitle =>
      'Crea tu primera alarma y elige una misión que te saque de la cama.';

  @override
  String get deleteAlarmTitle => '¿Eliminar alarma?';

  @override
  String get deleteAlarmMessage => 'Esta alarma se eliminará permanentemente.';

  @override
  String get repeatOnce => 'Una vez';

  @override
  String get repeatEveryDay => 'Cada día';

  @override
  String get repeatWeekdays => 'Entre semana';

  @override
  String get repeatWeekend => 'Fin de semana';

  @override
  String get dayMonShort => 'L';

  @override
  String get dayTueShort => 'M';

  @override
  String get dayWedShort => 'X';

  @override
  String get dayThuShort => 'J';

  @override
  String get dayFriShort => 'V';

  @override
  String get daySatShort => 'S';

  @override
  String get daySunShort => 'D';

  @override
  String get missionNone => 'Sin misión';

  @override
  String get missionObjectHunt => 'Buscar objeto';

  @override
  String get missionSkyPhoto => 'Foto del cielo';

  @override
  String get missionGrassPhoto => 'Foto de hierba';

  @override
  String get missionMakeBed => 'Hacer la cama';

  @override
  String get missionSquats => 'Sentadillas';

  @override
  String get missionPushups => 'Flexiones';

  @override
  String get missionNoneDescription => 'Apaga con un solo toque.';

  @override
  String get missionObjectHuntDescription =>
      'Vuelve a fotografiar un objeto registrado.';

  @override
  String get missionSkyPhotoDescription =>
      'Sal y captura el cielo de la mañana.';

  @override
  String get missionGrassPhotoDescription =>
      'Encuentra algo verde y fotografíalo.';

  @override
  String get missionMakeBedDescription => 'Haz una foto de tu cama hecha.';

  @override
  String get missionSquatsDescription =>
      'Sujeta el teléfono y haz sentadillas.';

  @override
  String get missionPushupsDescription => 'Sujeta el teléfono y haz flexiones.';

  @override
  String get newAlarm => 'Nueva alarma';

  @override
  String get editAlarm => 'Editar alarma';

  @override
  String get repeatSection => 'Repetir';

  @override
  String get missionSection => 'Misión de despertar';

  @override
  String get soundSection => 'Sonido';

  @override
  String get labelField => 'Etiqueta';

  @override
  String get labelHint => 'p. ej. Correr por la mañana';

  @override
  String get labelNone => 'Ninguna';

  @override
  String get repsLabel => 'Repeticiones';

  @override
  String get vibrate => 'Vibración';

  @override
  String get snoozeSection => 'Posponer';

  @override
  String snoozeSummary(int minutes, int count) {
    return '$minutes min, máx. ${count}x';
  }

  @override
  String get soundClassic => 'Clásico';

  @override
  String get soundSunrise => 'Amanecer';

  @override
  String get soundPulse => 'Pulso';

  @override
  String get soundCustom => 'Sonido personalizado';

  @override
  String get importSound => 'Importar de audio o vídeo';

  @override
  String get importSoundSubtitle =>
      'Usa cualquier clip de tu biblioteca como alarma.';

  @override
  String get recordSound => 'Graba el tuyo';

  @override
  String get stopRecording => 'Detener grabación';

  @override
  String get registerObjectTitle => 'Registrar objeto';

  @override
  String get registerObjectSubtitle =>
      'Fotografía un objeto lejos de tu cama: el lavabo, la cafetera. Tendrás que volver a fotografiarlo para parar la alarma.';

  @override
  String get usePhoto => 'Usar esta foto';

  @override
  String get retakePhoto => 'Repetir';

  @override
  String get cameraPermissionNeeded =>
      'Se necesita acceso a la cámara para las misiones con foto.';

  @override
  String get openSettings => 'Abrir Ajustes';

  @override
  String get cameraError => 'La cámara no pudo iniciarse.';

  @override
  String get takePhoto => 'Tomar foto';

  @override
  String get ringingWakeUp => '¡Despierta!';

  @override
  String get startMission => 'Empezar misión';

  @override
  String get dismissAlarm => 'Apagar';

  @override
  String snoozeWithRemaining(int minutes, int remaining) {
    return 'Posponer $minutes min (quedan $remaining)';
  }

  @override
  String get verifyingPhoto => 'Comprobando tu foto…';

  @override
  String get missionPhotoFailed =>
      'Eso no parece correcto. ¡Inténtalo de nuevo!';

  @override
  String get photoInstructionObject =>
      'Encuentra tu objeto registrado y fotografíalo.';

  @override
  String get photoInstructionSky => 'Sal y apunta la cámara al cielo.';

  @override
  String get photoInstructionGrass =>
      'Encuentra hierba o una planta y fotografíala.';

  @override
  String get photoInstructionBed => 'Haz tu cama y luego fotografíala.';

  @override
  String get movementInstructionSquats =>
      'Sujeta el teléfono contra el pecho y haz sentadillas.';

  @override
  String get movementInstructionPushups =>
      'Sujeta el teléfono con una mano y haz flexiones.';

  @override
  String repsOf(int target) {
    return 'de $target';
  }

  @override
  String get movementHint =>
      'Muévete a ritmo constante: las sacudidas no cuentan.';

  @override
  String get notificationDefaultTitle => '¡Despierta!';

  @override
  String get notificationBodyNoMission => 'Hora de levantarse.';

  @override
  String get notificationBodyMission =>
      'Completa tu misión para detener la alarma.';

  @override
  String get notificationBodySnoozeOver => 'La posposición terminó.';

  @override
  String get wakeSuccessTitle => 'Estás en pie. ¡Misión cumplida!';

  @override
  String streakCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Racha de $count días',
      one: 'Racha de 1 día',
    );
    return '$_temp0';
  }

  @override
  String get startMyDay => 'Empezar mi día';

  @override
  String get statsTitle => 'Tus mañanas';

  @override
  String get currentStreak => 'Racha actual';

  @override
  String get bestStreak => 'Mejor racha';

  @override
  String get avgWakeTime => 'Hora media';

  @override
  String get totalWakes => 'Despertares';

  @override
  String get thisMonth => 'Este mes';

  @override
  String get onboardingWelcomeTitle => 'Despierta. Esta vez de verdad.';

  @override
  String get onboardingWelcomeSubtitle =>
      'La alarma que te hace demostrar que saliste de la cama antes de dejar de sonar.';

  @override
  String get snoozeHabitQuestion => '¿Con qué frecuencia pospones la alarma?';

  @override
  String get snoozeHabitNever => 'Casi nunca';

  @override
  String get snoozeHabitSometimes => 'Varias veces por semana';

  @override
  String get snoozeHabitAlways => 'Todas las mañanas';

  @override
  String get wakeGoalQuestion => '¿A qué hora quieres despertarte?';

  @override
  String get wakeGoalSubtitle =>
      'Sugeriremos esta hora para tu primera alarma.';

  @override
  String get strugglesQuestion => '¿Qué pasa después de que suene tu alarma?';

  @override
  String get strugglesSubtitle => 'Elige todo lo que te suene familiar.';

  @override
  String get struggleDismissAsleep => 'La apago medio dormido';

  @override
  String get struggleStayInBed => 'Me quedo en la cama con el móvil';

  @override
  String get strugglePhoneInBed => 'Me vuelvo a dormir';

  @override
  String get struggleNoRoutine => 'Mis mañanas no tienen rutina';

  @override
  String get notificationsTitle => 'Tu alarma necesita voz';

  @override
  String get notificationsSubtitle =>
      'Permite las notificaciones para que tu alarma suene aunque la app esté cerrada.';

  @override
  String get allowNotifications => 'Permitir notificaciones';

  @override
  String get personalizingTitle => 'Creando tu plan de despertar…';

  @override
  String get personalizingItem1 => 'Analizando tus hábitos de posponer';

  @override
  String get personalizingItem2 => 'Eligiendo tu primera misión';

  @override
  String get personalizingItem3 => 'Preparando tu contador de racha';

  @override
  String get paywallTitle => 'No vuelvas a quedarte dormido';

  @override
  String get paywallSubtitle =>
      'Únete a miles que cambiaron posponer por mañanas de verdad.';

  @override
  String get paywallFeatureMissions =>
      'Todas las misiones: fotos, sentadillas, flexiones';

  @override
  String get paywallFeatureSounds =>
      'Sonidos personalizados desde cualquier audio o vídeo';

  @override
  String get paywallFeatureStreaks => 'Rachas y estadísticas matutinas';

  @override
  String get paywallFeatureNoLimit => 'Alarmas ilimitadas';

  @override
  String get planYearly => 'Anual';

  @override
  String get bestValue => 'MEJOR PRECIO';

  @override
  String pricePerYear(String price) {
    return '$price al año';
  }

  @override
  String get restorePurchases => 'Restaurar compras';

  @override
  String get paywallLegal =>
      'Se renueva automáticamente hasta cancelarse. Cancela cuando quieras en los ajustes de tu cuenta.';

  @override
  String get purchaseFailed => 'La compra no se completó. No se te ha cobrado.';

  @override
  String get paywallLoadError =>
      'No se pudieron cargar los planes.\nComprueba tu conexión e inténtalo de nuevo.';

  @override
  String get premiumActive => 'Premium activo';

  @override
  String get premiumActiveSubtitle =>
      'Todas las misiones y funciones desbloqueadas.';

  @override
  String get settingsSectionGeneral => 'GENERAL';

  @override
  String get settingsNotifications => 'Ajustes de notificaciones';

  @override
  String get nextAlarmIn => 'Próxima alarma en';

  @override
  String get settingsLanguage => 'Idioma';

  @override
  String get languageSystemDefault => 'Predeterminado del sistema';

  @override
  String get settingsSectionSupport => 'SOPORTE';

  @override
  String get contactSupport => 'Contactar soporte';

  @override
  String get rateApp => 'Valorar la app';

  @override
  String get settingsSectionLegal => 'LEGAL';

  @override
  String get privacyPolicy => 'Política de privacidad';

  @override
  String get termsOfUse => 'Términos de uso';

  @override
  String appVersion(String version) {
    return 'Versión $version';
  }

  @override
  String get nameQuestion => '¿Cómo te llamamos?';

  @override
  String get nameHint => 'Tu nombre';

  @override
  String get ageQuestion => '¿Cuántos años tienes?';

  @override
  String get ageSubtitle =>
      'Las necesidades de sueño cambian con la edad: esto ajusta tu plan.';

  @override
  String get ageUnder18 => 'Menos de 18';

  @override
  String get age18to24 => '18–24';

  @override
  String get age25to34 => '25–34';

  @override
  String get age35to54 => '35–54';

  @override
  String get age55plus => '55+';

  @override
  String get bedtimeQuestion => '¿A qué hora sueles acostarte?';

  @override
  String get bedtimeSubtitle => 'Lo usaremos para revisar tu ventana de sueño.';

  @override
  String get painStatPrefix => 'Posponer te va a costar unas';

  @override
  String painStatHours(int hours) {
    return '$hours horas';
  }

  @override
  String get painStatSuffix => 'este año: mañanas que no vas a recuperar.';

  @override
  String get painStatFootnote =>
      'Estimado a partir de tus respuestas, con 9 minutos por posposición.';

  @override
  String sleepWindowNote(String duration) {
    return 'Tu ventana de sueño planificada es de unas $duration.';
  }

  @override
  String get motivationsQuestion =>
      '¿Qué harás con tus mañanas más tranquilas?';

  @override
  String get motivationsSubtitle =>
      'Elige todas las que apliquen: esto da forma a tu plan.';

  @override
  String get motivationExercise => 'Mover el cuerpo';

  @override
  String get motivationBreakfast => 'Desayunar de verdad';

  @override
  String get motivationDeepWork => 'Concentrarme antes de que empiece el ruido';

  @override
  String get motivationQuietTime => 'Tiempo tranquilo para mí';

  @override
  String get motivationFamily => 'Más tiempo con las personas que quiero';

  @override
  String get commitmentTitle => 'Hazlo oficial';

  @override
  String get commitmentBody =>
      'Quienes se comprometen con un plan de despertar tienen muchas más probabilidades de mantenerlo. Un toque, sin firmas.';

  @override
  String get commitmentCta => 'Estoy listo para despertar mejor';

  @override
  String get socialProofTitle => 'Estás en buena compañía';

  @override
  String get socialProofSubtitle => 'Amado por madrugadores de todas partes';

  @override
  String get socialProofQuote1 =>
      'La misión de sentadillas suena ridícula hasta que funciona. Llevo tres semanas sin posponer.';

  @override
  String get socialProofAuthor1 => 'Maya';

  @override
  String get socialProofQuote2 =>
      'Fotografiar el cielo me obliga a salir. Mis mañanas por fin son mías.';

  @override
  String get socialProofAuthor2 => 'Jonas';

  @override
  String get socialProofQuote3 =>
      'Antes perdía una hora cada día. Ahora me levanto antes que mis hijos: lo cambia todo.';

  @override
  String get socialProofAuthor3 => 'Priya';

  @override
  String personalizingTitleNamed(String name) {
    return 'Creando el plan de despertar de $name…';
  }

  @override
  String planRevealTitleNamed(String name) {
    return '$name, tu plan está listo';
  }

  @override
  String get planRevealTitle => 'Tu plan está listo';

  @override
  String planRevealSubtitle(String time) {
    return 'Fuera de la cama a las $time en 30 días, una misión a la vez.';
  }

  @override
  String get planChartNow => 'Ahora';

  @override
  String get planChartGoal => 'Meta';

  @override
  String get planChartDay1 => 'Día 1';

  @override
  String get planChartDay30 => 'Día 30';

  @override
  String get planRevealCta => 'Ver mi plan';

  @override
  String paywallTitleNamed(String name) {
    return '$name, no vuelvas a quedarte dormido';
  }

  @override
  String paywallGoalLine(String time) {
    return 'Tu plan: fuera de la cama a las $time, todos los días.';
  }

  @override
  String get planMonthly => 'Mensual';

  @override
  String pricePerMonth(String price) {
    return '$price al mes';
  }

  @override
  String monthlyEquivalent(String price) {
    return '≈ $price/mes';
  }

  @override
  String get saveBadge => 'AHORRA 50%';

  @override
  String get freeTrialToggle => 'Prueba gratis activada';

  @override
  String get trialToday => 'Hoy';

  @override
  String get trialTodayBody =>
      'Desbloquea todas las misiones, sonidos y estadísticas.';

  @override
  String get trialDay2 => 'Día 2';

  @override
  String get trialDay2Body => 'Te avisaremos antes de que termine tu prueba.';

  @override
  String trialDayFinal(int day) {
    return 'Día $day';
  }

  @override
  String get trialDayFinalBody =>
      'Comienza tu suscripción. Cancela en cualquier momento antes.';

  @override
  String paywallCtaTrial(int days) {
    return 'Comenzar mi prueba gratis de $days días';
  }

  @override
  String get paywallCtaNoTrial => 'Continuar';

  @override
  String get noPaymentNow => 'Sin pago ahora';

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
