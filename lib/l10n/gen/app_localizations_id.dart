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
  String get missionSquatsDescription =>
      'Letakkan HP dengan aman dan selesaikan squat.';

  @override
  String get missionPushupsDescription =>
      'Letakkan HP dengan aman dan selesaikan push-up.';

  @override
  String get missionRandomHunt => 'Cari Benda';

  @override
  String get missionRandomHuntDescription =>
      'Bendanya dipilih acak saat alarm bunyi. Cari sampai ketemu. Tanpa setup.';

  @override
  String huntFind(String object) {
    return 'CARI: $object';
  }

  @override
  String get huntInstruction =>
      'Arahkan kamera ke bendanya untuk matikan alarm.';

  @override
  String huntReroll(int left) {
    return 'Nggak punya? Ganti benda (sisa $left)';
  }

  @override
  String get huntNoRerolls => 'Jatah ganti habis. Cari sampai ketemu!';

  @override
  String photoFailTargetNotFound(String object) {
    return '$object belum kelihatan. Masukkan ke dalam frame';
  }

  @override
  String get tryMission => 'Coba misi';

  @override
  String get missionPreviewTitle => 'Pratinjau misi';

  @override
  String get missionPreviewSuccess =>
      'Pratinjau selesai — alarm dan streak kamu tidak berubah.';

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
  String get batteryTitle => 'Biar alarm tetap jalan di HP ini';

  @override
  String get batteryBody =>
      'Penghemat baterai di HP kamu bisa bikin Bangunin gagal membangunkan. Izinkan berjalan di latar belakang supaya alarmnya selalu bunyi.';

  @override
  String get batteryAllow => 'Izinkan berjalan di latar belakang';

  @override
  String get batteryDone => 'Sudah diizinkan';

  @override
  String get batteryStepsXiaomi =>
      'Nyalakan juga Autostart untuk Bangunin, dan set baterainya ke \"Tanpa batasan\". Biasanya di Setelan > Aplikasi > Kelola aplikasi > Bangunin.';

  @override
  String get batteryStepsOppo =>
      'Nyalakan juga Mulai otomatis untuk Bangunin, dan izinkan aktivitas latar belakang. Biasanya di Pengaturan > Aplikasi > Bangunin.';

  @override
  String get batteryStepsVivo =>
      'Nyalakan juga Autostart untuk Bangunin dan izinkan pemakaian daya latar belakang tinggi. Biasanya di Pengaturan > Aplikasi > Bangunin.';

  @override
  String get batteryStepsHuawei =>
      'Set juga Bangunin ke \"Kelola manual\" dan nyalakan Mulai otomatis. Biasanya di Pengaturan > Baterai > Peluncuran aplikasi.';

  @override
  String get batteryStepsTranssion =>
      'Nyalakan juga Autostart untuk Bangunin dan izinkan berjalan di latar belakang. Biasanya di Pengaturan > Aplikasi > Bangunin.';

  @override
  String get batteryStepsGeneric =>
      'Kalau alarm masih suka kelewat, cek pengaturan baterai HP-mu dan izinkan Bangunin berjalan di latar belakang.';

  @override
  String get batteryMenusVary =>
      'Nama menunya beda-beda tiap HP dan versi Android, jadi cari yang paling mirip.';

  @override
  String get notNow => 'Nanti aja';

  @override
  String get alarmEngineFullTitle => 'Bunyi walau mode senyap';

  @override
  String get alarmEngineFallbackBody =>
      'Di iPhone ini alarm pakai notifikasi. Jadi nggak bunyi kalau mode senyap atau Focus aktif, dan berhenti setelah sekitar 30 detik.';

  @override
  String get alarmEngineEnable => 'Aktifkan alarm sungguhan';

  @override
  String get alarmEngineEducationTitle =>
      'Biar Bangunin benar-benar bisa bangunin kamu';

  @override
  String get alarmEngineEducationBody =>
      'iOS bisa mengizinkan Bangunin berbunyi seperti jam bawaan — tembus mode senyap, tembus Focus, dan tampil penuh di layar kunci.\n\nIzin itu yang akan kami minta setelah ini. Tanpa izin tersebut, alarm cuma jadi notifikasi biasa dan gampang kelewat.';

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
  String get onboardingWelcomeTitle =>
      'Alarm biasa gampang dimatiin sambil tidur.';

  @override
  String get onboardingWelcomeSubtitle =>
      'Yang ini nggak akan berhenti sampai kamu beneran bangun.';

  @override
  String get wakeGoalQuestion => 'Mau dibangunin jam berapa?';

  @override
  String get wakeGoalSubtitle => 'Hari kerja. Bisa diubah kapan saja.';

  @override
  String get notificationsTitle => 'Biar alarmmu beneran bunyi';

  @override
  String get notificationsSubtitle =>
      'Izinkan alarm dan notifikasi supaya Bangunin bunyi layar penuh, walau HP mode senyap atau aplikasinya ditutup.';

  @override
  String get allowNotifications => 'Izinkan';

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
  String get settingsTheme => 'Tampilan';

  @override
  String get themeSystem => 'Sistem';

  @override
  String get themeLight => 'Terang';

  @override
  String get themeDark => 'Gelap';

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
  String get linkOpenFailed => 'Tautan tidak dapat dibuka. Silakan coba lagi.';

  @override
  String get supportEmailCopied =>
      'Aplikasi email tidak ditemukan. hello@bangunin.app sudah disalin.';

  @override
  String appVersion(String version) {
    return 'Versi $version';
  }

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
  String get planChartNow => 'Sekarang';

  @override
  String get planChartGoal => 'Target';

  @override
  String get planChartDay1 => 'Hari 1';

  @override
  String get planChartDay30 => 'Hari 30';

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
  String saveBadge(int percent) {
    return 'HEMAT $percent%';
  }

  @override
  String get freeTrialToggle => 'Uji coba gratis aktif';

  @override
  String get trialToday => 'Hari ini';

  @override
  String get trialTodayBody => 'Buka semua misi, suara, dan statistik.';

  @override
  String get trialDay2 => 'Hari ke-2';

  @override
  String trialDay2Body(String store) {
    return 'Batalkan di $store sebelum uji coba berakhir, kamu nggak bayar apa pun.';
  }

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
  String get photoFailTooDark =>
      'Terlalu gelap untuk dicek — coba di tempat yang lebih terang';

  @override
  String get photoFailTooBright =>
      'Terlalu terang — menjauh sedikit dari sumber cahaya';

  @override
  String get photoFailNotEnoughDetail =>
      'Detailnya kurang kelihatan — coba lebih dekat';

  @override
  String get photoFailSurface =>
      'Belum bisa kami pastikan — arahkan kamera ke objek aslinya';

  @override
  String get photoFailNotLive =>
      'Tahan kamera ke objek aslinya, lalu coba lagi';

  @override
  String get photoFailNoMatch =>
      'Sepertinya ini bukan objek yang kamu daftarkan';

  @override
  String get photoFailNoHand =>
      'Masukkan tanganmu ke dalam foto, sentuh rumputnya';

  @override
  String get photoFailNoReference =>
      'Belum ada objek terdaftar — atur dulu di alarmnya';

  @override
  String get missionSafetyNote =>
      'Letakkan ponsel dengan aman agar seluruh tubuh terlihat. Jangan memegang ponsel saat berolahraga. Berhenti kalau kamu merasa sakit atau pusing.';

  @override
  String get poseGuidanceNoPerson =>
      'Kamu belum kelihatan — masuk ke dalam frame';

  @override
  String get poseGuidanceJointsHidden =>
      'Mundur sedikit biar tangan dan kaki kelihatan penuh';

  @override
  String get poseGuidanceGetReady => 'Tahan posisi awal untuk mulai';

  @override
  String get poseGuidanceGoDown => 'Turun';

  @override
  String get poseGuidanceComeUp => 'Naik lagi';

  @override
  String get poseGuidanceComplete => 'Selesai — mantap';

  @override
  String get settingsOurStory => 'Cerita kami';

  @override
  String get founderStoryTitle => 'Kenapa Bangunin ada';

  @override
  String get founderStoryBody =>
      'Tahun 2023 aku mahasiswa semester 3, ngekos jauh dari rumah untuk pertama kalinya.\n\nDi rumah, ibuku yang selalu bangunin aku. \"Bangun, udah siang!\" Setiap pagi. Aku nggak pernah sadar betapa aku mengandalkan itu, sampai nggak ada lagi.\n\nDi kos, aku pasang enam alarm. Semuanya kumatiin sambil merem. Aku bablas kelas jam 7 tiga kali dalam sebulan, absenku jeblok, dan aku benci diriku sendiri tiap kebangun jam 9 lihat grup kelas udah rame.\n\nAku coba semua alarm di Play Store. Yang matiin pakai soal matematika, aku hafal jawabannya. Yang harus di-shake, aku shake sambil tidur. Semuanya terlalu gampang dibohongin, karena otak jam 5 pagi cuma punya satu tujuan: balik tidur.\n\nJadi aku bikin satu yang nggak bisa kubohongin. Dia baru diam kalau aku benar-benar keluar dari kasur: foto langit di luar, squat sepuluh kali, foto wastafel kamar mandi. Hal-hal yang mustahil dilakukan sambil setengah tidur.\n\nPertama kali pakai, aku kesel banget. Kedua kali, aku ketawa. Minggu ketiga, aku belum sekali pun bablas.\n\nAku kasih ke teman-teman sekosan. Terus ke seangkatan. Sekarang aku kasih ke kamu.\n\nBangunin bukan buatan startup gede di Silicon Valley. Ini dibuat satu mahasiswa yang capek ketinggalan kelas, buat kamu yang lagi ngerasain hal yang sama.\n\nSelamat pagi. Beneran kali ini.';

  @override
  String get founderStorySignature => 'Pendiri Bangunin';

  @override
  String get onboardingSoundTitle => 'Pilih suara alarm';

  @override
  String get onboardingSoundSubtitle => 'Geser untuk dengar satu per satu.';

  @override
  String get onboardingMissionTitle => 'Mau buktiin bangun pakai apa?';

  @override
  String get onboardingMissionSubtitle =>
      'Alarm terus bunyi sampai kamu selesaikan.';

  @override
  String get onboardingMissionBadge => 'Paling seru';

  @override
  String onboardingReadyTitle(String when, String time) {
    return '$when jam $time.';
  }

  @override
  String get onboardingReadyHunt =>
      'Buat matiin, kamu harus cari benda acak. Bendanya baru dikasih tahu pas alarm bunyi.';

  @override
  String onboardingReadyMission(String mission) {
    return 'Buat matiin: $mission.';
  }

  @override
  String get onboardingReadyNoMission =>
      'Sekali ketuk langsung mati. Misi bisa ditambah kapan saja.';

  @override
  String get onboardingReadyFootnote =>
      'Jam, suara, atau misi bisa diganti kapan saja.';

  @override
  String get onboardingReadyCta => 'Siap!';

  @override
  String get onboardingReadyToday => 'Hari ini';

  @override
  String get onboardingReadyTomorrow => 'Besok';

  @override
  String get videoAlarmsSection => 'Alarm meme';

  @override
  String get soundsSection => 'Suara';

  @override
  String get missionMath => 'Matematika';

  @override
  String get missionMathDescription =>
      'Kerjakan soal hitungan sampai otakmu nyala.';

  @override
  String get missionShake => 'Goyang HP';

  @override
  String get missionShakeDescription =>
      'Goyang HP kencang sampai hitungannya penuh.';

  @override
  String mathProgress(int current, int total) {
    return 'Soal $current dari $total';
  }

  @override
  String get mathWrong => 'Belum tepat. Coba yang ini.';

  @override
  String get shakeInstruction => 'Goyang! Yang kencang!';

  @override
  String get shakeHint => 'Pegang erat, goyang pakai seluruh lengan.';

  @override
  String get countProblems => 'Jumlah soal';

  @override
  String get countShakes => 'Jumlah goyangan';

  @override
  String get emergencyLink => 'Darurat? Nggak bisa kerjakan misi';

  @override
  String get emergencyTitle => 'Jalan darurat';

  @override
  String emergencyTapBody(int left) {
    return 'Hanya untuk darurat beneran. Ketuk $left kali lagi.';
  }

  @override
  String get emergencyTapButton => 'Ketuk';

  @override
  String get emergencyPledgeBody => 'Ketik ulang ini:';

  @override
  String get emergencyConfirm => 'Matikan alarm';

  @override
  String get emergencyCancel => 'Kembali ke alarm';

  @override
  String get emergencyDone =>
      'Alarm mati. Pagi ini nggak dihitung ke streak-mu.';

  @override
  String get wakeCheckNotificationTitle => 'Masih bangun?';

  @override
  String get wakeCheckNotificationBody =>
      'Ketuk dalam satu menit, atau alarmmu bunyi lagi.';

  @override
  String get wakeCheckRingBody =>
      'Kamu belum konfirmasi sudah bangun. Kerjakan misinya lagi.';

  @override
  String missionStepOf(int step, int total, String mission) {
    return 'Misi $step dari $total: $mission';
  }

  @override
  String get wakeCheckTitle => 'Masih bangun?';

  @override
  String get wakeCheckBody =>
      'Buktikan, atau alarmmu bunyi lagi lengkap dengan misinya.';

  @override
  String wakeCheckCountdown(int seconds) {
    return '$seconds dtk';
  }

  @override
  String get wakeCheckConfirm => 'Aku sudah bangun';

  @override
  String get wakeCheckPassed => 'Mantap. Selamat pagi!';

  @override
  String missionNumber(int number) {
    return 'Misi $number';
  }

  @override
  String get addMission => 'Tambah misi';

  @override
  String addMissionLimit(int max) {
    return 'maks. $max';
  }

  @override
  String get removeMission => 'Hapus misi ini';

  @override
  String get wakeCheckSetting => 'Cek Bangun';

  @override
  String get wakeCheckOff => 'Mati';

  @override
  String wakeCheckAfter(int minutes) {
    return '$minutes menit setelahnya';
  }

  @override
  String get wakeCheckExplainer =>
      'Beberapa menit setelah alarm dimatikan, kami cek kamu masih bangun. Kalau nggak dijawab dalam semenit, alarm bunyi lagi lengkap dengan misinya.';

  @override
  String get chooseMission => 'Pilih misi ini';

  @override
  String get missionCurrent => 'Dipakai';

  @override
  String get missionSwipeHint => 'Geser untuk lihat semua misi';

  @override
  String get chooseSound => 'Pilih suara ini';

  @override
  String get soundSwipeHint => 'Geser untuk dengar satu per satu';

  @override
  String get importSoundShort => 'Impor';

  @override
  String get notifyPointOnTime => 'Bunyi tepat waktu, walau aplikasi ditutup';

  @override
  String get notifyPointLockScreen => 'Muncul di layar kunci';

  @override
  String get notifyPointNoSpam => 'Cuma alarmmu. Nggak ada spam.';

  @override
  String planTrialBadge(int days) {
    return 'GRATIS $days HARI';
  }

  @override
  String thenPricePerYear(String price) {
    return 'lalu $price per tahun';
  }

  @override
  String thenPricePerMonth(String price) {
    return 'lalu $price per bulan';
  }

  @override
  String get alarmsOffTitle => 'Alarm Bangunin lagi mati';

  @override
  String get alarmsOffBody =>
      'Tanpa izin Alarm, iPhone cuma kirim notifikasi biasa: nggak bunyi layar penuh, nggak tembus mode senyap. Bangunin nggak bisa bangunin kamu.';

  @override
  String get alarmsOffEnable => 'Nyalakan alarm';

  @override
  String get alarmsOffSettingsHint =>
      'Buka Pengaturan → Bangunin → nyalakan Alarm.';

  @override
  String get onboardingNoEscape =>
      'Geser buat matiin? Boleh aja. Semenit kemudian alarmnya bunyi lagi, terus, sampai misimu selesai.';

  @override
  String get obProblemTitle => 'Kamu matikan alarm sambil tidur.';

  @override
  String get obProblemBody =>
      'Snooze, snooze, lalu kesiangan lagi. Bukan karena malas: jempol yang masih ngantuk selalu menang.';

  @override
  String get obPromiseTitle =>
      'Bangunin nggak berhenti sampai kamu benar-benar bangun.';

  @override
  String get obPromiseBody =>
      'Untuk mematikannya, kamu harus turun dari kasur dan menyelesaikan misi singkat. Begitu selesai, kamu sudah melek.';

  @override
  String get obDemoTitle => 'Begini cara kerjanya';

  @override
  String get obDemoSubtitle => 'Satu pagi bersama Bangunin.';

  @override
  String get obDemoRinging => 'Alarm berbunyi';

  @override
  String get obDemoStartMission => 'Mulai misi';

  @override
  String get obDemoMission => 'Selesaikan misi untuk mematikannya';

  @override
  String get obDemoDone => 'Kamu bangun. Alarm mati.';

  @override
  String get obDemoGoodMorning => 'Selamat pagi!';

  @override
  String get obNameTitle => 'Kami panggil kamu siapa?';

  @override
  String get obNameSubtitle => 'Untuk menyusun rencanamu.';

  @override
  String get obNameHint => 'Nama depanmu';

  @override
  String get obAgeTitle => 'Berapa umurmu?';

  @override
  String get obAgeUnder18 => 'Di bawah 18';

  @override
  String get obSnoozeTitle => 'Berapa kali kamu snooze tiap pagi?';

  @override
  String get obSnoozeNever => 'Nggak pernah';

  @override
  String get obSnoozeFew => '1–2 kali';

  @override
  String get obSnoozeSome => '3–5 kali';

  @override
  String get obSnoozeLots => 'Lebih dari 5 kali';

  @override
  String obCostTitleNamed(String name, int hours) {
    return '$name, snooze menghabiskan $hours jam setahun.';
  }

  @override
  String obCostTitle(int hours) {
    return 'Snooze menghabiskan $hours jam setahun.';
  }

  @override
  String obCostBody(int days) {
    return 'Itu sama dengan $days hari penuh setengah tidur, bukan memulai harimu.';
  }

  @override
  String get obCostNever =>
      'Tanpa snooze pun, satu alarm yang kamu matikan sudah bikin kesiangan. Bangunin memastikan itu nggak terjadi.';

  @override
  String get obLoseTitle => 'Yang hilang kalau kesiangan';

  @override
  String get obLoseLate => 'Telat ke kantor atau sekolah';

  @override
  String get obLoseSahur => 'Ketinggalan sahur atau Subuh';

  @override
  String get obLoseRush => 'Pagi yang buru-buru dan bikin stres';

  @override
  String get obLoseTrust => 'Ingkar janji ke diri sendiri';

  @override
  String get obFixTitle =>
      'Kabar baiknya: pagi-pagi itu bisa kamu rebut kembali.';

  @override
  String get obFixBody =>
      'Begitu turun dari kasur untuk mematikan alarm, kamu nggak tidur lagi. Mulai besok.';

  @override
  String get obGoalTitle => 'Kenapa kamu ingin bangun tepat waktu?';

  @override
  String get obGoalWork => 'Kerja';

  @override
  String get obGoalSchool => 'Sekolah atau kuliah';

  @override
  String get obGoalSahur => 'Sahur dan Subuh';

  @override
  String get obGoalExercise => 'Olahraga';

  @override
  String get obGoalProductive => 'Hari yang lebih produktif';

  @override
  String get obSourceTitle => 'Dari mana kamu tahu Bangunin?';

  @override
  String get obSourceFriend => 'Teman atau keluarga';

  @override
  String get obSourceStore => 'App Store atau Google Play';

  @override
  String get obSourceOther => 'Lainnya';

  @override
  String get obProofTitle => 'Dibuat untuk yang susah bangun pagi';

  @override
  String get obProofSubtitle =>
      'Semua yang kamu butuhkan untuk mengalahkan tombol snooze.';

  @override
  String get obProofMissions =>
      '7 misi bangun: foto, squat, matematika, dan lainnya';

  @override
  String obProofSounds(int count) {
    return '$count suara alarm, termasuk favorit lokal';
  }

  @override
  String get obProofReal =>
      'Alarm sungguhan yang tetap bunyi walau mode senyap';

  @override
  String get obProofPrivate =>
      'Tanpa akun. Fotomu nggak pernah keluar dari HP.';

  @override
  String obPlanTitleNamed(String name) {
    return 'Rencana bangun 7 hari $name';
  }

  @override
  String get obPlanTitle => 'Rencana bangun 7 harimu';

  @override
  String obPlanGoal(String goal) {
    return 'Untuk: $goal';
  }

  @override
  String obPlanDay1(String time) {
    return 'Hari 1: alarm berbunyi jam $time. Bangun dan selesaikan misinya.';
  }

  @override
  String get obPlanDay3 => 'Hari 3: tanpa snooze. Tubuhmu mulai menyesuaikan.';

  @override
  String get obPlanDay5 => 'Hari 5: bangun terasa lebih mudah.';

  @override
  String get obPlanDay7 =>
      'Hari 7: streak seminggu penuh. Kebiasaan baru terbentuk.';

  @override
  String get obDemoPhotoPrompt => 'Foto langit';

  @override
  String get obDemoVerified => 'Terverifikasi';

  @override
  String get obReminderTitle =>
      'Kami ingatkan sebelum uji coba gratismu berakhir';

  @override
  String obReminderSubtitle(String store) {
    return 'Tanpa kejutan. Batalkan kapan saja di $store.';
  }

  @override
  String get obReminderToday => 'Hari ini';

  @override
  String get obReminderTodayBody => 'Semua misi, suara, dan statistik terbuka.';

  @override
  String obReminderDay(int day) {
    return 'Hari ke-$day';
  }

  @override
  String get obReminderDayBody =>
      'Kami kirim pengingat bahwa uji cobamu berakhir besok.';

  @override
  String get obReminderEndBody =>
      'Langgananmu dimulai, kecuali kamu sudah membatalkan.';

  @override
  String get trialReminderTitle => 'Uji coba gratismu berakhir besok';

  @override
  String trialReminderBody(String store) {
    return 'Bangunin Premium dimulai besok. Nggak cocok? Batalkan di $store sebelum itu.';
  }
}
