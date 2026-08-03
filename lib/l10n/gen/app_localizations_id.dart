// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Indonesian (`id`).
class AppLocalizationsId extends AppLocalizations {
  AppLocalizationsId([String locale = 'id']) : super(locale);

  @override
  String get continueLabel => 'Lanjut';

  @override
  String get cancel => 'Batal';

  @override
  String get save => 'Simpan';

  @override
  String get delete => 'Hapus';

  @override
  String get done => 'Selesai';

  @override
  String get retry => 'Coba lagi';

  @override
  String get getStarted => 'Mulai';

  @override
  String get close => 'Tutup';

  @override
  String get back => 'Kembali';

  @override
  String get abandonMission => 'Batalkan misi, alarm tetap bunyi';

  @override
  String get genericError => 'Ada yang salah.\nCoba lagi ya.';

  @override
  String get tabAlarms => 'Alarm';

  @override
  String get tabStats => 'Streak';

  @override
  String get tabSettings => 'Pengaturan';

  @override
  String get homeTitle => 'Alarm';

  @override
  String get noUpcomingAlarm => 'Belum ada alarm terjadwal';

  @override
  String ringsIn(String countdown) {
    return 'Bunyi dalam $countdown';
  }

  @override
  String get emptyAlarmsTitle => 'Belum ada alarm';

  @override
  String get emptyAlarmsSubtitle =>
      'Buat alarm pertamamu dan pilih misi yang bikin kamu keluar dari kasur.';

  @override
  String get deleteAlarmTitle => 'Hapus alarm?';

  @override
  String get deleteAlarmMessage => 'Alarm ini akan dihapus permanen.';

  @override
  String get repeatOnce => 'Sekali';

  @override
  String get repeatEveryDay => 'Setiap hari';

  @override
  String get repeatWeekdays => 'Hari kerja';

  @override
  String get repeatWeekend => 'Akhir pekan';

  @override
  String get dayMonShort => 'S';

  @override
  String get dayTueShort => 'S';

  @override
  String get dayWedShort => 'R';

  @override
  String get dayThuShort => 'K';

  @override
  String get dayFriShort => 'J';

  @override
  String get daySatShort => 'S';

  @override
  String get daySunShort => 'M';

  @override
  String get missionNone => 'Tanpa misi';

  @override
  String get missionObjectHunt => 'Cari Benda';

  @override
  String get missionSkyPhoto => 'Foto Langit';

  @override
  String get missionGrassPhoto => 'Foto Rumput';

  @override
  String get missionMakeBed => 'Rapikan Kasur';

  @override
  String get missionSquats => 'Squat';

  @override
  String get missionPushups => 'Push-up';

  @override
  String get missionNoneDescription => 'Matikan dengan sekali ketuk.';

  @override
  String get missionObjectHuntDescription =>
      'Foto ulang benda yang sudah kamu daftarkan.';

  @override
  String get missionSkyPhotoDescription => 'Keluar rumah dan foto langit pagi.';

  @override
  String get missionGrassPhotoDescription =>
      'Cari sesuatu yang hijau dan fotokan.';

  @override
  String get missionMakeBedDescription => 'Foto kasurmu yang sudah rapi.';

  @override
  String get missionSquatsDescription => 'Pegang HP-mu dan selesaikan squat.';

  @override
  String get missionPushupsDescription =>
      'Pegang HP-mu dan selesaikan push-up.';

  @override
  String get newAlarm => 'Alarm baru';

  @override
  String get editAlarm => 'Ubah alarm';

  @override
  String get repeatSection => 'Ulangi';

  @override
  String get missionSection => 'Misi bangun';

  @override
  String get soundSection => 'Suara';

  @override
  String get labelField => 'Label';

  @override
  String get labelHint => 'misal: Lari pagi';

  @override
  String get labelNone => 'Tidak ada';

  @override
  String get repsLabel => 'Jumlah repetisi';

  @override
  String get vibrate => 'Getar';

  @override
  String get snoozeSection => 'Snooze';

  @override
  String snoozeSummary(int minutes, int count) {
    return '$minutes menit, maks. ${count}x';
  }

  @override
  String get soundClassic => 'Klasik';

  @override
  String get soundSunrise => 'Fajar';

  @override
  String get soundPulse => 'Denyut';

  @override
  String get soundCustom => 'Suara sendiri';

  @override
  String get importSound => 'Impor dari audio atau video';

  @override
  String get importSoundSubtitle =>
      'Pakai klip apa pun dari galerimu sebagai alarm.';

  @override
  String get recordSound => 'Rekam suaramu';

  @override
  String get stopRecording => 'Berhenti merekam';

  @override
  String get registerObjectTitle => 'Daftarkan benda';

  @override
  String get registerObjectSubtitle =>
      'Foto benda yang jauh dari kasurmu, misalnya wastafel kamar mandi atau mesin kopi. Kamu harus memfotonya lagi untuk mematikan alarm.';

  @override
  String get usePhoto => 'Pakai foto ini';

  @override
  String get retakePhoto => 'Ulangi';

  @override
  String get cameraPermissionNeeded =>
      'Akses kamera dibutuhkan untuk misi foto.';

  @override
  String get openSettings => 'Buka Pengaturan';

  @override
  String get cameraError => 'Kamera tidak bisa dinyalakan.';

  @override
  String get takePhoto => 'Ambil foto';

  @override
  String get ringingWakeUp => 'Bangun!';

  @override
  String get startMission => 'Mulai misi';

  @override
  String get dismissAlarm => 'Matikan';

  @override
  String snoozeWithRemaining(int minutes, int remaining) {
    return 'Snooze $minutes menit (sisa $remaining)';
  }

  @override
  String get verifyingPhoto => 'Memeriksa fotomu…';

  @override
  String get missionPhotoFailed => 'Kayaknya belum pas. Coba lagi!';

  @override
  String get photoInstructionObject =>
      'Cari benda yang kamu daftarkan dan fotokan.';

  @override
  String get photoInstructionSky =>
      'Keluar rumah dan arahkan kamera ke langit.';

  @override
  String get photoInstructionGrass => 'Cari rumput atau tanaman dan fotokan.';

  @override
  String get photoInstructionBed => 'Rapikan kasurmu, lalu fotokan.';

  @override
  String get movementInstructionSquats =>
      'Pegang HP di dadamu dan lakukan squat.';

  @override
  String get movementInstructionPushups =>
      'Pegang HP dengan satu tangan dan lakukan push-up.';

  @override
  String repsOf(int target) {
    return 'dari $target';
  }

  @override
  String get movementHint =>
      'Bergeraklah dengan ritme stabil. Goyangan asal tidak dihitung.';

  @override
  String get notificationDefaultTitle => 'Bangun!';

  @override
  String get notificationBodyNoMission => 'Waktunya bangun.';

  @override
  String get notificationBodyMission =>
      'Selesaikan misimu untuk mematikan alarm.';

  @override
  String get notificationBodySnoozeOver => 'Snooze sudah habis.';

  @override
  String get wakeSuccessTitle => 'Kamu sudah bangun. Misi selesai!';

  @override
  String streakCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Streak $count hari',
    );
    return '$_temp0';
  }

  @override
  String get startMyDay => 'Mulai hariku';

  @override
  String get statsTitle => 'Pagimu';

  @override
  String get currentStreak => 'Streak saat ini';

  @override
  String get bestStreak => 'Streak terbaik';

  @override
  String get avgWakeTime => 'Rata-rata bangun';

  @override
  String get totalWakes => 'Total bangun';

  @override
  String get thisMonth => 'Bulan ini';

  @override
  String get onboardingWelcomeTitle => 'Bangun. Kali ini beneran.';

  @override
  String get onboardingWelcomeSubtitle =>
      'Alarm yang minta bukti kamu sudah keluar dari kasur sebelum berhenti bunyi.';

  @override
  String get snoozeHabitQuestion => 'Seberapa sering kamu pencet snooze?';

  @override
  String get snoozeHabitNever => 'Hampir tidak pernah';

  @override
  String get snoozeHabitSometimes => 'Beberapa kali seminggu';

  @override
  String get snoozeHabitAlways => 'Setiap pagi';

  @override
  String get wakeGoalQuestion => 'Jam berapa kamu mau bangun?';

  @override
  String get wakeGoalSubtitle =>
      'Kami akan sarankan jam ini untuk alarm pertamamu.';

  @override
  String get strugglesQuestion => 'Apa yang terjadi setelah alarmmu bunyi?';

  @override
  String get strugglesSubtitle => 'Pilih semua yang terasa familiar.';

  @override
  String get struggleDismissAsleep => 'Kumatikan sambil setengah tidur';

  @override
  String get struggleStayInBed => 'Aku tetap di kasur scrolling';

  @override
  String get strugglePhoneInBed => 'Aku ketiduran lagi';

  @override
  String get struggleNoRoutine => 'Pagiku tidak punya rutinitas';

  @override
  String get notificationsTitle => 'Alarmmu butuh suara';

  @override
  String get notificationsSubtitle =>
      'Izinkan notifikasi supaya alarmmu tetap bunyi walau aplikasi ditutup.';

  @override
  String get allowNotifications => 'Izinkan notifikasi';

  @override
  String get personalizingTitle => 'Menyusun rencana bangunmu…';

  @override
  String get personalizingItem1 => 'Menganalisis kebiasaan snooze-mu';

  @override
  String get personalizingItem2 => 'Memilih misi pertamamu';

  @override
  String get personalizingItem3 => 'Menyiapkan pelacak streak-mu';

  @override
  String get paywallTitle => 'Jangan kesiangan lagi';

  @override
  String get paywallSubtitle =>
      'Gabung dengan ribuan orang yang menukar snooze dengan pagi yang beneran.';

  @override
  String get paywallFeatureMissions =>
      'Semua misi bangun: foto, squat, push-up';

  @override
  String get paywallFeatureSounds =>
      'Suara alarm sendiri dari audio atau video apa pun';

  @override
  String get paywallFeatureStreaks => 'Streak dan statistik pagi';

  @override
  String get paywallFeatureNoLimit => 'Alarm tanpa batas';

  @override
  String get planYearly => 'Tahunan';

  @override
  String get bestValue => 'PALING HEMAT';

  @override
  String pricePerYear(String price) {
    return '$price per tahun';
  }

  @override
  String get restorePurchases => 'Pulihkan pembelian';

  @override
  String get paywallLegal =>
      'Diperpanjang otomatis sampai dibatalkan. Batalkan kapan saja di pengaturan akun tokomu.';

  @override
  String get purchaseFailed =>
      'Pembelian tidak selesai. Kamu tidak dikenai biaya.';

  @override
  String get paywallLoadError =>
      'Paket tidak bisa dimuat.\nPeriksa koneksimu dan coba lagi.';

  @override
  String get premiumActive => 'Premium aktif';

  @override
  String get premiumActiveSubtitle => 'Semua misi dan fitur terbuka.';

  @override
  String get settingsSectionGeneral => 'UMUM';

  @override
  String get settingsNotifications => 'Pengaturan notifikasi';

  @override
  String get nextAlarmIn => 'Alarm berikutnya dalam';

  @override
  String get settingsLanguage => 'Bahasa';

  @override
  String get languageSystemDefault => 'Bawaan sistem';

  @override
  String get settingsSectionSupport => 'BANTUAN';

  @override
  String get contactSupport => 'Hubungi bantuan';

  @override
  String get rateApp => 'Beri nilai aplikasi';

  @override
  String get settingsSectionLegal => 'LEGAL';

  @override
  String get privacyPolicy => 'Kebijakan privasi';

  @override
  String get termsOfUse => 'Ketentuan penggunaan';

  @override
  String appVersion(String version) {
    return 'Versi $version';
  }

  @override
  String get nameQuestion => 'Kami panggil kamu siapa?';

  @override
  String get nameHint => 'Nama panggilanmu';

  @override
  String get ageQuestion => 'Berapa umurmu?';

  @override
  String get ageSubtitle =>
      'Kebutuhan tidur berubah seiring usia. Ini menyetel rencanamu.';

  @override
  String get ageUnder18 => 'Di bawah 18';

  @override
  String get age18to24 => '18–24';

  @override
  String get age25to34 => '25–34';

  @override
  String get age35to54 => '35–54';

  @override
  String get age55plus => '55+';

  @override
  String get bedtimeQuestion => 'Biasanya jam berapa kamu tidur?';

  @override
  String get bedtimeSubtitle =>
      'Kami pakai ini untuk mengecek jendela tidurmu.';

  @override
  String get painStatPrefix => 'Snooze akan merampas sekitar';

  @override
  String painStatHours(int hours) {
    return '$hours jam';
  }

  @override
  String get painStatSuffix =>
      'tahun ini: pagi yang tidak akan pernah kembali.';

  @override
  String get painStatFootnote =>
      'Diperkirakan dari jawabanmu, 9 menit per snooze.';

  @override
  String sleepWindowNote(String duration) {
    return 'Jendela tidurmu sekitar $duration.';
  }

  @override
  String get motivationsQuestion =>
      'Mau kamu pakai apa pagimu yang lebih tenang?';

  @override
  String get motivationsSubtitle =>
      'Pilih semua yang cocok. Ini membentuk rencanamu.';

  @override
  String get motivationExercise => 'Olahraga';

  @override
  String get motivationBreakfast => 'Sarapan beneran';

  @override
  String get motivationDeepWork => 'Fokus sebelum dunia berisik';

  @override
  String get motivationQuietTime => 'Waktu tenang untuk diriku';

  @override
  String get motivationFamily => 'Lebih banyak waktu dengan orang tersayang';

  @override
  String get commitmentTitle => 'Resmikan niatmu';

  @override
  String get commitmentBody =>
      'Orang yang berkomitmen pada rencana bangun jauh lebih mungkin bertahan. Satu ketukan, tanpa tanda tangan.';

  @override
  String get commitmentCta => 'Aku siap bangun lebih baik';

  @override
  String get socialProofTitle => 'Kamu tidak sendirian';

  @override
  String get socialProofSubtitle => 'Disukai para pejuang pagi di mana-mana';

  @override
  String get socialProofQuote1 =>
      'Misi squat kedengarannya konyol sampai benar-benar berhasil. Tiga minggu aku tidak pencet snooze.';

  @override
  String get socialProofAuthor1 => 'Maya';

  @override
  String get socialProofQuote2 =>
      'Foto langit memaksaku keluar rumah. Akhirnya pagiku jadi milikku.';

  @override
  String get socialProofAuthor2 => 'Jonas';

  @override
  String get socialProofQuote3 =>
      'Dulu aku kehilangan satu jam tiap hari. Sekarang aku bangun sebelum anak-anakku, dan semuanya berubah.';

  @override
  String get socialProofAuthor3 => 'Priya';

  @override
  String personalizingTitleNamed(String name) {
    return 'Menyusun rencana bangun $name…';
  }

  @override
  String planRevealTitleNamed(String name) {
    return '$name, rencanamu sudah siap';
  }

  @override
  String get planRevealTitle => 'Rencanamu sudah siap';

  @override
  String planRevealSubtitle(String time) {
    return 'Bangun jam $time dalam 30 hari, satu misi setiap pagi.';
  }

  @override
  String get planChartNow => 'Sekarang';

  @override
  String get planChartGoal => 'Target';

  @override
  String get planChartDay1 => 'Hari 1';

  @override
  String get planChartDay30 => 'Hari 30';

  @override
  String get planRevealCta => 'Lihat rencanaku';

  @override
  String paywallTitleNamed(String name) {
    return '$name, jangan kesiangan lagi';
  }

  @override
  String paywallGoalLine(String time) {
    return 'Rencanamu: keluar dari kasur jam $time, setiap hari.';
  }

  @override
  String get planMonthly => 'Bulanan';

  @override
  String pricePerMonth(String price) {
    return '$price per bulan';
  }

  @override
  String monthlyEquivalent(String price) {
    return '≈ $price/bulan';
  }

  @override
  String get saveBadge => 'HEMAT 66%';

  @override
  String get freeTrialToggle => 'Uji coba gratis aktif';

  @override
  String get trialToday => 'Hari ini';

  @override
  String get trialTodayBody => 'Buka semua misi, suara, dan statistik.';

  @override
  String get trialDay2 => 'Hari ke-2';

  @override
  String get trialDay2Body => 'Kami ingatkan sebelum uji cobamu berakhir.';

  @override
  String trialDayFinal(int day) {
    return 'Hari ke-$day';
  }

  @override
  String get trialDayFinalBody =>
      'Langgananmu dimulai. Batalkan kapan saja sebelumnya.';

  @override
  String paywallCtaTrial(int days) {
    return 'Mulai uji coba gratis $days hari';
  }

  @override
  String get paywallCtaNoTrial => 'Lanjutkan';

  @override
  String get noPaymentNow => 'Tidak ada tagihan hari ini';

  @override
  String get manageSubscription => 'Kelola langganan';

  @override
  String get accessCodeTitle => 'Masukkan kode akses';

  @override
  String get accessCodeHint => 'Kode akses';

  @override
  String get accessCodeRedeem => 'Gunakan';

  @override
  String get accessCodeInvalid => 'Kode akses tidak valid.';

  @override
  String get settingsOurStory => 'Cerita kami';

  @override
  String get founderStoryTitle => 'Kenapa Bangunin ada';

  @override
  String get founderStoryBody =>
      'Tahun 2023 aku mahasiswa semester 3, ngekos jauh dari rumah untuk pertama kalinya.\n\nDi rumah, ibuku yang selalu bangunin aku. \"Bangun, udah siang!\" Setiap pagi. Aku nggak pernah sadar betapa aku mengandalkan itu, sampai nggak ada lagi.\n\nDi kos, aku pasang enam alarm. Semuanya kumatiin sambil merem. Aku bablas kelas jam 7 tiga kali dalam sebulan, absenku jeblok, dan aku benci diriku sendiri tiap kebangun jam 9 lihat grup kelas udah rame.\n\nAku coba semua alarm di Play Store. Yang matiin pakai soal matematika, aku hafal jawabannya. Yang harus di-shake, aku shake sambil tidur. Semuanya terlalu gampang dibohongin, karena otak jam 5 pagi cuma punya satu tujuan: balik tidur.\n\nJadi aku bikin satu yang nggak bisa kubohongin. Dia baru diam kalau aku benar-benar keluar dari kasur: foto langit di luar, squat sepuluh kali, foto wastafel kamar mandi. Hal-hal yang mustahil dilakukan sambil setengah tidur.\n\nPertama kali pakai, aku kesel banget. Kedua kali, aku ketawa. Minggu ketiga, aku belum sekali pun bablas.\n\nAku kasih ke teman-teman sekosan. Terus ke seangkatan. Sekarang aku kasih ke kamu.\n\nBangunin bukan buatan startup gede di Silicon Valley. Ini dibuat satu mahasiswa yang capek ketinggalan kelas, buat kamu yang lagi ngerasain hal yang sama.\n\nSelamat pagi. Beneran kali ini.';

  @override
  String get founderStorySignature => 'Pendiri Bangunin';
}
