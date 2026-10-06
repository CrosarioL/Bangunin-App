"""Builds bangunin.app into marketing/bangunin-site.

Flat output on purpose: the site is deployed by dragging that folder into
Netlify, and Netlify's pretty URLs serve /cara-agar-tidak-kesiangan for
cara-agar-tidak-kesiangan.html.

No prices and no free trial anywhere on the site (there is no trial): the
only call to action is to download. Pricing lives in the stores.

    python3 marketing/site_build.py
"""

from __future__ import annotations

import html
import json
from pathlib import Path

OUT = Path(__file__).parent / "bangunin-site"
SITE = "https://bangunin.app"
APP_STORE = "https://apps.apple.com/app/id6817837690"
PLAY = "https://play.google.com/store/apps/details?id=app.bangunin"
UPDATED = "2026-10-01"

FONTS = (
    '<link rel="preconnect" href="https://fonts.googleapis.com">'
    '<link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>'
    '<link href="https://fonts.googleapis.com/css2?family=Baloo+2:wght@600;700;800'
    '&family=Nunito:wght@500;600;700;800;900&display=swap" rel="stylesheet">'
)

APPLE_SVG = (
    '<svg viewBox="0 0 24 24" fill="currentColor" aria-hidden="true"><path d="M16.37 12.6c-.02-2.2 1.8-3.26 '
    "1.88-3.31-1.03-1.5-2.62-1.7-3.18-1.73-1.35-.14-2.64.8-3.33.8-.69 0-1.74-.78-2.86-.76-1.47.02-2.83.86-3.59 "
    "2.17-1.53 2.66-.39 6.59 1.1 8.74.73 1.05 1.6 2.24 2.73 2.2 1.1-.05 1.51-.71 2.84-.71 1.32 0 1.7.71 2.85.69 "
    "1.18-.02 1.93-1.07 2.65-2.13.84-1.22 1.18-2.4 1.2-2.46-.03-.01-2.3-.88-2.32-3.5zM14.2 6.13c.6-.73 1.01-1.75.9-2.76"
    '-.87.04-1.92.58-2.55 1.31-.56.64-1.05 1.68-.92 2.67.97.08 1.96-.49 2.57-1.22z"/></svg>'
)
PLAY_SVG = (
    '<svg viewBox="0 0 24 24" aria-hidden="true"><path fill="#34A853" d="M3.6 1.8 13.8 12 3.6 22.2c-.4-.2-.6-.7-.6-1.2V3c0-.5.2-1 .6-1.2z"/>'
    '<path fill="#FBBC04" d="m17.2 15.4-3.4-3.4 3.4-3.4 3.9 2.2c1.1.6 1.1 1.8 0 2.4z"/>'
    '<path fill="#EA4335" d="M13.8 12 3.6 22.2c.4.2.9.2 1.4-.1l12.2-6.7z"/>'
    '<path fill="#4285F4" d="M3.6 1.8c.5-.3 1-.3 1.4-.1l12.2 6.9-3.4 3.4z"/></svg>'
)


def store_buttons(lang: str = "id") -> str:
    """Bilingual on the home page (data-*), fixed language on articles."""
    def label(id_text: str, en_text: str) -> str:
        if lang == "both":
            return f'<small data-id="{id_text}" data-en="{en_text}">{id_text}</small>'
        return f"<small>{id_text if lang == 'id' else en_text}</small>"

    return (
        '<div class="cta-row">'
        f'<a class="btn btn-sun" href="{APP_STORE}" rel="noopener">{APPLE_SVG}'
        f'<span>{label("Unduh di", "Download on the")}App Store</span></a>'
        f'<a class="btn btn-ghost" href="{PLAY}" rel="noopener">{PLAY_SVG}'
        f'<span>{label("Unduh di", "Get it on")}Google Play</span></a>'
        "</div>"
    )


def head(*, lang: str, title: str, description: str, path: str, extra: str = "",
         og_type: str = "website", alternates: dict[str, str] | None = None) -> str:
    url = f"{SITE}/{path}".rstrip("/") if path else SITE + "/"
    alt = ""
    for hl, href in (alternates or {}).items():
        alt += f'<link rel="alternate" hreflang="{hl}" href="{href}">'
    return f"""<!doctype html>
<html lang="{lang}">
<head>
<meta charset="utf-8">
<meta name="viewport" content="width=device-width, initial-scale=1">
<title>{html.escape(title)}</title>
<meta name="description" content="{html.escape(description)}">
<link rel="canonical" href="{url}">{alt}
<meta property="og:type" content="{og_type}">
<meta property="og:title" content="{html.escape(title)}">
<meta property="og:description" content="{html.escape(description)}">
<meta property="og:url" content="{url}">
<meta property="og:image" content="{SITE}/og.jpg">
<meta name="twitter:card" content="summary_large_image">
<meta name="theme-color" content="#06152d">
<link rel="icon" href="/favicon.png">
<link rel="apple-touch-icon" href="/apple-touch-icon.png">
{FONTS}
<link rel="stylesheet" href="/styles.css?v={UPDATED}">
{extra}
</head>
<body>"""


def header(lang_toggle: bool, blog_label: str = "Blog") -> str:
    toggle = (
        '<div class="lang" role="group" aria-label="Language">'
        '<button type="button" data-lang="id" aria-pressed="true">ID</button>'
        '<button type="button" data-lang="en" aria-pressed="false">EN</button></div>'
        if lang_toggle else ""
    )
    return f"""<header class="top"><div class="wrap">
<a class="brand" href="/"><img src="/icon.webp" alt="" width="34" height="34">Bangunin</a>
<nav>
<a class="hide-sm" href="/#misi" data-id="Misi" data-en="Missions">Misi</a>
<a class="hide-sm" href="/#fitur" data-id="Fitur" data-en="Features">Fitur</a>
<a href="/blog">{blog_label}</a>
{toggle}
</nav></div></header>"""


FOOTER = f"""<footer><div class="wrap">
<a class="brand" href="/"><img src="/icon.webp" alt="" width="28" height="28">Bangunin</a>
<a href="/blog">Blog</a>
<a href="/privacy" data-id="Privasi" data-en="Privacy">Privasi</a>
<a href="/terms" data-id="Ketentuan" data-en="Terms">Ketentuan</a>
<a href="mailto:hello@bangunin.app">hello@bangunin.app</a>
<span class="copy">© 2026 HAYAT TIME LTD</span>
</div></footer>"""

LANG_JS = """<script>
(function () {
  var KEY = 'bangunin-lang';
  function apply(lang) {
    document.documentElement.lang = lang;
    document.querySelectorAll('[data-' + lang + ']').forEach(function (el) {
      var v = el.getAttribute('data-' + lang);
      if (el.hasAttribute('data-html')) el.innerHTML = v; else el.textContent = v;
    });
    document.querySelectorAll('.lang button').forEach(function (b) {
      b.setAttribute('aria-pressed', String(b.dataset.lang === lang));
    });
    try { localStorage.setItem(KEY, lang); } catch (e) {}
  }
  var saved = null;
  try { saved = localStorage.getItem(KEY); } catch (e) {}
  var initial = saved || ((navigator.language || 'id').toLowerCase().indexOf('id') === 0 ? 'id' : 'en');
  document.querySelectorAll('.lang button').forEach(function (b) {
    b.addEventListener('click', function () { apply(b.dataset.lang); });
  });
  if (initial !== 'id') apply(initial);
})();
</script>"""


def t(id_text: str, en_text: str, tag: str = "span", attrs: str = "", html_mode: bool = False) -> str:
    """A bilingual element: Indonesian rendered (and indexed), English swapped in by JS."""
    mode = " data-html" if html_mode else ""
    return (f'<{tag}{attrs}{mode} data-id="{html.escape(id_text)}" data-en="{html.escape(en_text)}">'
            f"{id_text}</{tag}>")


# --------------------------------------------------------------------------
# Articles
# --------------------------------------------------------------------------

POSTS = [
    {
        "slug": "cara-agar-tidak-kesiangan",
        "lang": "id",
        "tag": "Bangun pagi",
        "title": "Cara Agar Tidak Kesiangan: 9 Trik yang Benar-Benar Berhasil",
        "description": "Sering kesiangan padahal alarm sudah bunyi? Ini 9 cara agar tidak kesiangan lagi, dari jam tidur sampai alarm yang tidak bisa dimatikan sambil tidur.",
        "dek": "Kesiangan jarang soal malas. Biasanya soal alarm yang terlalu gampang dimatikan dan jam tidur yang berantakan. Ini cara memperbaikinya.",
        "body": """
<p>Hampir semua orang pernah mengalaminya: alarm bunyi, kamu mematikannya tanpa sadar, lalu terbangun satu jam kemudian dengan panik. Kabar baiknya, kesiangan bukan sifat bawaan. Ada beberapa kebiasaan kecil yang membuatnya jauh lebih jarang terjadi.</p>

<h2>1. Tidur dan bangun di jam yang sama, termasuk akhir pekan</h2>
<p>Tubuh punya jam internal. Kalau hari Senin kamu bangun jam 6 tapi Sabtu jam 10, jam itu terus "jet lag". Pilih satu jam bangun dan pertahankan, bahkan saat libur, dengan selisih paling banyak satu jam.</p>

<h2>2. Hitung mundur jam tidurmu</h2>
<p>Kebanyakan orang dewasa butuh sekitar 7–9 jam tidur. Kalau harus bangun jam 05.30, berarti kamu sebaiknya sudah tidur sekitar jam 21.30–22.30. Kesiangan sering terjadi karena alarmnya tepat, tapi jam tidurnya yang terlambat.</p>

<h2>3. Taruh HP jauh dari kasur</h2>
<p>Kalau alarm bisa dimatikan sambil tetap berbaring, kemungkinan besar akan dimatikan. Taruh HP di meja di seberang kamar supaya kamu harus berdiri untuk menghentikannya. Berdiri adalah setengah dari perjuangan bangun.</p>

<h2>4. Berhenti mengandalkan tombol snooze</h2>
<p>Tidur 5–10 menit tambahan setelah snooze jarang terasa menyegarkan. Kamu justru masuk ke tidur ringan yang terputus-putus, lalu bangun dengan lebih pusing. Atur alarm di jam kamu benar-benar harus bangun, bukan 30 menit sebelumnya "biar bisa snooze".</p>

<h2>5. Buat alarm yang menuntut otakmu bekerja</h2>
<p>Masalah utama kesiangan adalah kamu mematikan alarm dalam kondisi setengah sadar. Solusinya: alarm yang hanya bisa dimatikan setelah kamu melakukan sesuatu, seperti mengerjakan soal matematika sederhana, memotret sesuatu di ruangan lain, atau bergerak. Begitu otak dan badanmu aktif, kemungkinan kembali tidur turun drastis.</p>

<div class="callout"><p><strong>Contoh:</strong> di Bangunin, alarm baru diam setelah kamu menyelesaikan misi, misalnya memotret langit, mencari benda acak di rumah, atau 15 squat. Kalau kamu menggeser untuk mematikannya, semenit kemudian alarm bunyi lagi sampai misinya selesai.</p></div>

<h2>6. Pastikan alarm benar-benar bunyi</h2>
<p>Banyak kasus "alarm tidak bunyi" ternyata karena HP dalam mode senyap, Fokus (Jangan Ganggu), atau penghemat baterai yang mematikan aplikasi. Cek pengaturan ini sekali, jangan menunggu sampai kamu kesiangan. Kami membahasnya di artikel <a href="/alarm-tidak-bunyi">alarm tidak bunyi saat tidur</a>.</p>

<h2>7. Kena cahaya segera setelah bangun</h2>
<p>Cahaya pagi memberi sinyal kuat ke tubuh bahwa hari sudah dimulai. Buka gorden, nyalakan lampu, atau keluar sebentar. Ini juga membantu kamu lebih gampang mengantuk di malam hari.</p>

<h2>8. Kurangi layar dan kafein di malam hari</h2>
<p>Scroll TikTok sampai tengah malam adalah penyebab kesiangan nomor satu yang jarang diakui. Coba berhenti main HP 30 menit sebelum tidur, dan hindari kopi di sore hari.</p>

<h2>9. Rayakan streak kecil</h2>
<p>Kebiasaan lebih mudah dijaga kalau kamu melihat progresnya. Catat berapa hari berturut-turut kamu bangun tepat waktu. Tiga hari pertama paling berat; setelah seminggu, rasanya jauh lebih wajar.</p>

<h2>Intinya</h2>
<p>Agar tidak kesiangan, kamu butuh dua hal: jam tidur yang cukup dan konsisten, serta alarm yang tidak bisa dimatikan tanpa benar-benar bangun. Mulai dari satu atau dua trik di atas malam ini juga.</p>
""",
    },
    {
        "slug": "cara-berhenti-snooze-alarm",
        "lang": "id",
        "tag": "Snooze",
        "title": "Kebiasaan Snooze Alarm: Kenapa Kita Terus Menunda dan Cara Berhentinya",
        "description": "Kenapa kita terus menekan snooze, apa efeknya ke tubuh, dan 7 cara praktis berhenti menunda alarm setiap pagi.",
        "dek": "Tombol snooze terasa seperti hadiah kecil. Kenyataannya, ia mencuri pagimu sedikit demi sedikit.",
        "body": """
<p>Kamu atur alarm jam 6. Lalu snooze. Lalu snooze lagi. Tahu-tahu sudah jam 6.40 dan kamu tetap merasa lelah. Kalau ini terdengar familiar, kamu tidak sendirian. Tapi kebiasaan snooze bisa dihentikan.</p>

<h2>Kenapa kita suka menekan snooze?</h2>
<p>Saat alarm berbunyi, otak masih dalam kondisi yang disebut <em>sleep inertia</em>: setengah tidur, sulit berpikir jernih, dan sangat ingin kembali tidur. Di kondisi ini, keputusan "lima menit lagi" terasa sangat masuk akal. Snooze dirancang persis untuk momen terlemahmu.</p>

<h2>Apa efek snooze?</h2>
<p>Tidur beberapa menit di antara alarm biasanya hanya tidur ringan yang terputus-putus. Banyak orang justru merasa lebih pusing dan lambat setelah beberapa kali snooze dibanding langsung bangun. Ditambah lagi, waktu yang hilang terasa kecil per hari, tapi kalau dijumlahkan dalam setahun, jumlahnya bisa puluhan jam.</p>

<h2>7 cara berhenti snooze</h2>
<h3>1. Atur alarm di jam yang sebenarnya</h3>
<p>Jangan pasang alarm 30 menit lebih awal "untuk jatah snooze". Pasang di jam kamu memang harus bangun, dan tidur 30 menit lebih lama di awal.</p>
<h3>2. Matikan opsi snooze, atau batasi</h3>
<p>Kalau aplikasimu mengizinkan, nonaktifkan snooze sepenuhnya atau batasi jadi sekali saja.</p>
<h3>3. Jauhkan HP dari jangkauan</h3>
<p>Kalau harus jalan untuk mematikan alarm, tubuhmu sudah setengah bangun saat sampai di HP.</p>
<h3>4. Pakai alarm dengan misi</h3>
<p>Alarm yang menuntut tindakan, seperti memotret sesuatu, mengerjakan soal, atau bergerak, memaksa otakmu keluar dari sleep inertia sebelum alarm diam. Ini cara paling efektif untuk orang yang "matikan alarm tanpa sadar".</p>
<h3>5. Siapkan alasan untuk bangun</h3>
<p>Kopi favorit, sarapan enak, atau lagu yang kamu suka. Otak lebih mau bangun kalau ada sesuatu yang ditunggu.</p>
<h3>6. Langsung kena cahaya</h3>
<p>Nyalakan lampu atau buka jendela begitu alarm berbunyi. Cahaya membantu mengurangi rasa kantuk.</p>
<h3>7. Lacak progresmu</h3>
<p>Hitung berapa hari berturut-turut kamu bangun tanpa snooze. Melihat streak bertambah itu memotivasi.</p>

<div class="callout"><p>Bangunin dibuat untuk masalah ini: alarm baru diam setelah misi selesai, snooze dibatasi sesuai pengaturanmu, dan streak pagimu tercatat otomatis.</p></div>

<h2>Kesimpulan</h2>
<p>Snooze bukan masalah karakter. Snooze adalah desain yang memanfaatkan momen paling lemahmu. Ubah desainnya dengan alarm di jam sebenarnya, HP di luar jangkauan, dan misi yang membuatmu benar-benar bangun.</p>
""",
    },
    {
        "slug": "alarm-tidak-bunyi",
        "lang": "id",
        "tag": "Pengaturan HP",
        "title": "Alarm Tidak Bunyi atau Tidak Terdengar Saat Tidur? Ini Penyebab dan Solusinya",
        "description": "Alarm HP tidak bunyi di pagi hari? Cek penyebab paling umum di iPhone dan Android: mode senyap, Fokus, penghemat baterai, dan volume alarm.",
        "dek": "Kadang kamu tidak salah. Alarmnya memang tidak sempat bunyi. Ini daftar yang perlu dicek di iPhone dan Android.",
        "body": """
<p>Tidak ada yang lebih menyebalkan daripada kesiangan lalu sadar alarmnya bahkan tidak bunyi. Biasanya penyebabnya bukan HP rusak, tapi satu pengaturan kecil. Berikut yang perlu dicek.</p>

<h2>Di iPhone</h2>
<h3>1. Izin Alarm untuk aplikasi alarm</h3>
<p>Di iOS 26 ke atas, aplikasi alarm pihak ketiga butuh izin <strong>Alarm</strong> supaya bisa berbunyi layar penuh dan menembus mode senyap. Tanpa izin itu, aplikasi biasanya hanya bisa mengirim notifikasi biasa yang mudah terlewat. Cek di <strong>Pengaturan → [nama aplikasi] → Alarm</strong>.</p>
<h3>2. Mode senyap dan Fokus</h3>
<p>Notifikasi biasa tidak menembus mode senyap atau Fokus (Jangan Ganggu/Tidur). Kalau aplikasimu mengandalkan notifikasi, pastikan ia dikecualikan di pengaturan Fokus, atau gunakan aplikasi yang memakai sistem alarm iOS.</p>
<h3>3. Volume dering</h3>
<p>Alarm bawaan dan aplikasi alarm modern memakai volume alarm, tapi notifikasi mengikuti volume dering. Naikkan volume sebelum tidur.</p>

<h2>Di Android</h2>
<h3>1. Penghemat baterai dan pengelola aplikasi</h3>
<p>Beberapa merek (Xiaomi, Oppo, Vivo, Samsung, dan lainnya) agresif mematikan aplikasi di latar belakang. Izinkan aplikasi alarm berjalan di latar belakang dan kecualikan dari optimasi baterai.</p>
<h3>2. Izin alarm & pengingat</h3>
<p>Di Android 12 ke atas, aplikasi butuh izin "Alarm & pengingat" untuk menjadwalkan alarm tepat waktu. Cek di pengaturan aplikasi.</p>
<h3>3. Jangan Ganggu</h3>
<p>Pastikan mode Jangan Ganggu mengizinkan alarm berbunyi.</p>

<h2>Untuk semua HP</h2>
<ul>
<li>Uji alarmmu 2 menit ke depan setelah mengubah pengaturan.</li>
<li>Jangan tutup paksa aplikasi alarm dari daftar aplikasi terbuka.</li>
<li>Pastikan baterai cukup atau HP sedang dicas.</li>
<li>Pilih suara alarm yang keras dan tidak biasa. Suara yang terlalu lembut gampang tenggelam dalam tidur.</li>
</ul>

<div class="callout"><p>Di iPhone, Bangunin memakai sistem alarm iOS (AlarmKit), sehingga alarm berbunyi layar penuh dan tetap bunyi walau HP dalam mode senyap atau Fokus. Kalau izin Alarm dimatikan, Bangunin langsung memberi tahu dan menunjukkan cara menyalakannya.</p></div>

<h2>Kesimpulan</h2>
<p>Alarm yang tidak bunyi hampir selalu karena izin, mode senyap/Fokus, atau penghemat baterai. Cek sekali, uji, dan pagimu akan jauh lebih bisa diandalkan.</p>
""",
    },
    {
        "slug": "tips-bangun-sahur",
        "lang": "id",
        "tag": "Ramadan",
        "title": "Susah Bangun Sahur? 8 Tips Bangun Sahur Tepat Waktu",
        "description": "Tips bangun sahur tepat waktu tanpa kesiangan: atur jam tidur, alarm sahur yang tidak bisa dimatikan sambil tidur, dan persiapan malam sebelumnya.",
        "dek": "Bangun jam 3 pagi itu berat, apalagi kalau badan masih kaget. Ini cara supaya sahurmu tidak terlewat.",
        "body": """
<p>Melewatkan sahur bikin puasa terasa jauh lebih berat. Masalahnya, bangun di dini hari bertentangan dengan jam tubuh kita. Berikut tips supaya kamu tetap bangun sahur, bahkan di minggu pertama Ramadan.</p>

<h2>1. Geser jam tidur lebih awal</h2>
<p>Kalau biasanya tidur jam 23.00, coba mulai tidur jam 21.30–22.00 selama Ramadan. Tidur cukup sebelum sahur membuat bangun jauh lebih mudah.</p>

<h2>2. Pasang alarm yang tidak bisa dimatikan sambil tidur</h2>
<p>Jam 3 pagi adalah waktu paling mudah mematikan alarm tanpa sadar. Pakai alarm yang menuntut tindakan, seperti misi foto, soal matematika, atau gerakan, supaya kamu benar-benar terjaga sebelum alarm diam.</p>

<h2>3. Pilih suara alarm yang "nendang"</h2>
<p>Suara lembut gampang tenggelam. Suara keras atau lucu, seperti teriakan "SAHUR!" khas bapak-bapak kampung, justru membuat kamu langsung melek.</p>

<div class="callout"><p>Di Bangunin ada suara khusus sahur seperti <strong>Tung Tung Tung Sahur</strong> dan <strong>Bapak Bangunin Sahur</strong>, plus misi yang harus diselesaikan sebelum alarm diam.</p></div>

<h2>4. Siapkan makanan sahur dari malam</h2>
<p>Kalau makanan sudah siap, rasa malas bangun berkurang. Kamu tahu begitu bangun, tinggal makan.</p>

<h2>5. Taruh HP di luar jangkauan</h2>
<p>Paksa dirimu berdiri untuk mematikan alarm. Begitu berdiri, kemungkinan kembali tidur turun jauh.</p>

<h2>6. Pasang pengecekan ulang</h2>
<p>Bahaya terbesar saat sahur adalah bangun, mematikan alarm, lalu tertidur lagi di kasur. Pasang pengingat beberapa menit setelahnya, atau gunakan fitur yang membunyikan alarm lagi kalau kamu tidak merespons.</p>

<h2>7. Bangun bersama keluarga atau teman</h2>
<p>Saling membangunkan lewat telepon atau chat membuat semua orang lebih bertanggung jawab.</p>

<h2>8. Tidur siang singkat</h2>
<p>Tidur siang 15–20 menit membantu menutup kekurangan tidur selama Ramadan tanpa membuatmu susah tidur di malam hari.</p>

<h2>Kesimpulan</h2>
<p>Bangun sahur jadi jauh lebih mudah dengan jam tidur yang lebih awal, alarm yang benar-benar membangunkan, dan persiapan dari malam. Semoga puasamu lancar!</p>
""",
    },
    {
        "slug": "cara-bangun-pagi",
        "lang": "id",
        "tag": "Kebiasaan",
        "title": "Cara Bangun Pagi Tanpa Ngantuk dan Langsung Semangat",
        "description": "Cara bangun pagi tanpa rasa ngantuk berlebihan: atur ritme tidur, hadapi sleep inertia, dan bangun dengan misi supaya langsung segar.",
        "dek": "Bangun pagi bukan soal tekad sekali. Ini soal membuat jam tubuhmu bekerja untukmu, bukan melawanmu.",
        "body": """
<p>Banyak orang ingin jadi "orang pagi", tapi setiap kali mencoba, rasanya seperti disiksa. Kuncinya bukan memaksa diri sekuat tenaga, tapi menyiapkan kondisi supaya bangun pagi terasa wajar.</p>

<h2>Kenapa bangun pagi terasa berat?</h2>
<p>Begitu bangun, otak butuh waktu untuk benar-benar aktif. Rasa berat, pusing, dan ingin tidur lagi di beberapa menit pertama itu normal. Yang penting adalah tidak memberi otak kesempatan untuk kembali tidur di menit-menit itu.</p>

<h2>Langkah-langkahnya</h2>
<h3>1. Maju pelan-pelan, 15 menit per beberapa hari</h3>
<p>Kalau sekarang bangun jam 8 dan ingin jam 6, jangan langsung lompat. Majukan 15 menit setiap 2–3 hari sampai mencapai target.</p>
<h3>2. Konsisten setiap hari</h3>
<p>Jam bangun yang sama setiap hari, termasuk akhir pekan, adalah cara tercepat membuat bangun pagi terasa otomatis.</p>
<h3>3. Gerak di menit pertama</h3>
<p>Beberapa squat, peregangan, atau jalan ke dapur membuat darah mengalir dan rasa kantuk berkurang. Itulah kenapa alarm dengan misi gerakan efektif.</p>
<h3>4. Minum air dan cari cahaya</h3>
<p>Segelas air dan cahaya terang (matahari atau lampu) membantu tubuh beralih ke mode siang.</p>
<h3>5. Punya rutinitas pagi yang menyenangkan</h3>
<p>Kopi, musik, atau waktu tenang lima menit. Bangun pagi lebih gampang kalau ada yang ditunggu.</p>
<h3>6. Lindungi jam tidurmu</h3>
<p>Bangun pagi tanpa tidur cukup hanya memindahkan rasa lelah ke siang hari. Tetapkan jam tidur dan patuhi.</p>

<div class="callout"><p>Bangunin membantu langkah 3 dan konsistensi: misi bangun (squat, foto, matematika) membuatmu bergerak sejak menit pertama, dan streak pagi menunjukkan progresmu setiap hari.</p></div>

<h2>Kesimpulan</h2>
<p>Bangun pagi tanpa ngantuk berlebihan bisa dilatih: geser jam bangun pelan-pelan, konsisten, bergerak di menit pertama, dan jaga jam tidur. Dalam dua minggu, pagi akan terasa jauh lebih ringan.</p>
""",
    },
    {
        "slug": "how-to-stop-turning-off-your-alarm",
        "lang": "en",
        "tag": "Snoozing",
        "title": "How to Stop Turning Off Your Alarm in Your Sleep (and Actually Get Up)",
        "description": "Keep turning off your alarm without remembering it? Why it happens and 7 practical ways to stop snoozing and switching your alarm off half-asleep.",
        "dek": "If you wake up with no memory of switching your alarm off, you're not lazy. You're half-asleep, and your alarm is too easy to beat.",
        "body": """
<p>You set the alarm. It rang. You turned it off. And you don't remember any of it. This is one of the most common reasons people wake up late, and it has a simple explanation.</p>

<h2>Why you turn your alarm off without remembering</h2>
<p>When an alarm goes off, your brain is still in <em>sleep inertia</em>: groggy, slow, and strongly biased towards going back to sleep. In that state, reaching over and tapping "stop" is almost a reflex. Most alarms are designed to be stopped with one tap, which is exactly what a half-asleep brain can manage.</p>

<h2>7 ways to stop it happening</h2>
<h3>1. Put your phone across the room</h3>
<p>If you have to stand up and walk to stop the alarm, you're already halfway awake when you get there.</p>
<h3>2. Use an alarm that needs a task to switch off</h3>
<p>Alarms that make you solve maths problems, take a photo of something in another room, or move your body force your brain out of sleep inertia before the alarm stops. This is the most effective fix for people who switch alarms off unconsciously.</p>
<h3>3. Remove or limit snooze</h3>
<p>Snooze gives your half-asleep brain an easy "yes". Turn it off, or limit it to once.</p>
<h3>4. Make sure the alarm can't be swiped away for good</h3>
<p>Some alarm apps keep coming back if you dismiss them without finishing the task. That removes the "just swipe it" escape route.</p>
<h3>5. Set the alarm for when you really need to get up</h3>
<p>Setting it 30 minutes early "to allow snoozing" just trains you to ignore it.</p>
<h3>6. Use a loud, unusual sound</h3>
<p>Gentle chimes are easy to sleep through or tune out. A sound you don't hear all day is harder to ignore.</p>
<h3>7. Get enough sleep in the first place</h3>
<p>If you're regularly sleeping five hours, no alarm will feel easy. Most adults need around 7–9 hours.</p>

<div class="callout"><p>Bangunin is built for exactly this: the alarm only stops after you complete a wake-up mission, and if you swipe it away without finishing, it rings again a minute later until you do.</p></div>

<h2>The bottom line</h2>
<p>You don't need more willpower at 6am. You need an alarm that a half-asleep brain can't beat. Combine distance, a task-based alarm and a consistent bedtime, and switching off your alarm in your sleep becomes a thing of the past.</p>
""",
    },
    {
        "slug": "how-to-stop-waking-up-late",
        "lang": "en",
        "tag": "Morning routine",
        "title": "How to Stop Waking Up Late: A Practical Guide for Heavy Sleepers",
        "description": "Always waking up late? A practical guide for heavy sleepers: fix your sleep schedule, make sure your alarm really rings, and use an alarm you can't sleep through.",
        "dek": "Waking up late is usually two problems at once: too little sleep, and an alarm that is too easy to ignore. Fix both.",
        "body": """
<p>If you're always late in the morning, you've probably tried more alarms, louder alarms, or alarms every five minutes. Here's a more reliable approach.</p>

<h2>Step 1: Work out your real bedtime</h2>
<p>Count back from when you need to get up. Most adults need around 7–9 hours of sleep. If you have to be up at 6:00, that means lights out around 22:00–23:00. Late mornings often start the night before.</p>

<h2>Step 2: Keep the same wake-up time every day</h2>
<p>Your body clock adjusts to consistency. Sleeping in at weekends makes Monday mornings feel like jet lag.</p>

<h2>Step 3: Make sure your alarm actually rings</h2>
<ul>
<li><strong>iPhone:</strong> on iOS 26, alarm apps need the Alarms permission to ring full-screen through Silent mode and Focus. Without it, many can only send a notification.</li>
<li><strong>Android:</strong> allow the app to run in the background and exclude it from battery optimisation, especially on Xiaomi, Oppo, Vivo and Samsung.</li>
<li>Test the alarm two minutes ahead after changing any setting.</li>
</ul>

<h2>Step 4: Use an alarm you can't sleep through</h2>
<p>Heavy sleepers rarely fail to hear the alarm. They fail to stay awake after stopping it. An alarm that only stops once you've done something, like solving a problem, taking a photo or doing a few squats, keeps you awake long enough to actually get up.</p>

<h2>Step 5: Add a check-in</h2>
<p>The classic heavy-sleeper mistake: you get up, switch off the alarm, sit on the bed, and wake up 40 minutes later. A follow-up check a few minutes after you dismiss the alarm catches this.</p>

<h2>Step 6: Build a streak</h2>
<p>Track how many days in a row you've woken up on time. It turns a daily struggle into something you don't want to break.</p>

<div class="callout"><p>Bangunin combines these: real iOS alarms through Silent mode, wake-up missions, a Wake Up Check that rings again if you fall back asleep, and a morning streak.</p></div>

<h2>The bottom line</h2>
<p>Stop waking up late by fixing both halves: enough, consistent sleep, and an alarm that rings reliably and can't be dismissed without you actually waking up.</p>
""",
    },
]


def article_page(post: dict) -> str:
    is_id = post["lang"] == "id"
    url = f"{SITE}/{post['slug']}"
    ld = {
        "@context": "https://schema.org",
        "@type": "BlogPosting",
        "headline": post["title"],
        "description": post["description"],
        "inLanguage": post["lang"],
        "datePublished": UPDATED,
        "dateModified": UPDATED,
        "mainEntityOfPage": url,
        "image": f"{SITE}/og.jpg",
        "author": {"@type": "Organization", "name": "Bangunin"},
        "publisher": {"@type": "Organization", "name": "HAYAT TIME LTD",
                      "logo": {"@type": "ImageObject", "url": f"{SITE}/apple-touch-icon.png"}},
    }
    extra = f'<script type="application/ld+json">{json.dumps(ld, ensure_ascii=False)}</script>'
    cta_title = "Alarm yang nggak bisa dimatiin sambil tidur" if is_id else "The alarm you can't turn off in your sleep"
    cta_body = ("Bangunin baru diam setelah kamu selesaikan misi bangun. Unduh sekarang."
                if is_id else "Bangunin only stops once you finish a wake-up mission. Download it now.")
    home = "Beranda" if is_id else "Home"
    return (
        head(lang=post["lang"], title=f"{post['title']} | Bangunin", description=post["description"],
             path=post["slug"], extra=extra, og_type="article")
        + header(False)
        + f"""<main>
<div class="article-hero"><div class="wrap">
<div class="crumbs"><a href="/">{home}</a> / <a href="/blog">Blog</a> / {html.escape(post['tag'])}</div>
<h1>{html.escape(post['title'])}</h1>
<p class="dek">{html.escape(post['dek'])}</p>
</div></div>
<article class="article"><div class="wrap">
{post['body']}
<div class="card article-cta">
<img src="/chick-crowing.webp" alt="" width="96" height="96">
<div><h3>{cta_title}</h3><p>{cta_body}</p>{store_buttons(post['lang'])}</div>
</div>
</div></article>
</main>"""
        + FOOTER + "</body></html>"
    )


def post_card(post: dict) -> str:
    more = "Baca" if post["lang"] == "id" else "Read"
    return (f'<a class="card post-card" href="/{post["slug"]}" lang="{post["lang"]}">'
            f'<span class="tag">{html.escape(post["tag"])}</span>'
            f'<h3>{html.escape(post["title"])}</h3>'
            f'<p>{html.escape(post["description"])}</p>'
            f'<span class="more">{more} →</span></a>')


def blog_page() -> str:
    id_posts = [p for p in POSTS if p["lang"] == "id"]
    en_posts = [p for p in POSTS if p["lang"] == "en"]
    return (
        head(lang="id", title="Blog Bangunin: Tips Bangun Pagi, Berhenti Snooze, dan Tidak Kesiangan",
             description="Artikel praktis tentang cara agar tidak kesiangan, berhenti snooze, alarm yang tidak bunyi, dan bangun sahur.",
             path="blog")
        + header(False)
        + f"""<main>
<section class="alt"><div class="wrap">
<div class="sec-head"><span class="kicker">Blog</span>
<h2>Tips bangun pagi yang beneran berguna</h2>
<p>Cara agar tidak kesiangan, berhenti snooze, dan memastikan alarmmu benar-benar bunyi.</p></div>
<div class="posts">{''.join(post_card(p) for p in id_posts)}</div>
<div class="sec-head" style="margin-top:64px"><span class="kicker">In English</span>
<h2>Wake-up guides</h2></div>
<div class="posts">{''.join(post_card(p) for p in en_posts)}</div>
</div></section>
</main>"""
        + FOOTER + "</body></html>"
    )


MISSIONS = [
    ("☀️", "Foto langit", "Photograph the sky", "Keluar dan foto langit pagi.", "Step outside and snap the morning sky."),
    ("🌿", "Foto rumput", "Photograph grass", "Cari rumput atau tanaman dan foto.", "Find grass or plants and take a photo."),
    ("🛏️", "Rapikan kasur", "Make your bed", "Foto kasurmu yang sudah rapi.", "Photograph your freshly made bed."),
    ("🔎", "Cari benda acak", "Random object hunt", "Bangunin memilih benda, kamu cari dan foto.", "Bangunin picks an object; find it and snap it."),
    ("🎯", "Benda pilihanmu", "Your own object", "Daftarkan benda di ruangan lain, foto saat alarm.", "Register an object in another room, photograph it to stop."),
    ("➗", "Matematika", "Maths", "Selesaikan soal hitungan sampai otak menyala.", "Solve sums until your brain switches on."),
    ("📳", "Kocok HP", "Shake", "Kocok HP sampai alarm menyerah.", "Shake your phone until the alarm gives up."),
    ("🏋️", "Squat & push-up", "Squats & push-ups", "Kamera menghitung gerakanmu.", "The camera counts your reps."),
]

FEATURES = [
    {
        "img": "poster-2.webp",
        "kick": ("Nggak bisa dikabur", "No escape"),
        "h": ("Geser buat matiin? Semenit lagi dia bunyi lagi.", "Swipe it away? It's back in a minute."),
        "p": ("Alarm baru diam setelah misimu selesai. Di iPhone, kalau kamu menggeser untuk mematikan tanpa menyelesaikan misi, alarm yang sama bunyi lagi semenit kemudian, terus, sampai kamu benar-benar bangun.",
              "The alarm only stops once your mission is done. On iPhone, swipe it away without finishing and the same alarm rings again a minute later, again and again, until you're actually up."),
        "li": [("Snooze dibatasi sesuai pengaturanmu", "Snooze limited to your own setting"),
               ("Emergency Escape untuk keadaan darurat sungguhan", "An Emergency Escape for genuine emergencies")],
    },
    {
        "img": "poster-4.webp",
        "kick": ("Alarm iPhone asli", "Real iPhone alarms"),
        "h": ("Tembus mode senyap dan Fokus.", "Rings through Silent mode and Focus."),
        "p": ("Bangunin memakai sistem alarm iOS (AlarmKit): layar penuh, tampil di layar kunci, dan tetap berbunyi walau HP dalam mode senyap. Di Android, alarm tepat waktu dengan layar penuh.",
              "Bangunin uses iOS's own alarm system (AlarmKit): full screen, on the Lock Screen, and ringing even in Silent mode. On Android: exact, full-screen alarms."),
        "li": [("Wake Up Check: dicek lagi beberapa menit kemudian", "Wake Up Check: a check-in a few minutes later"),
               ("Alarm bunyi lagi kalau kamu ketiduran", "Rings again if you drift back to sleep")],
    },
    {
        "img": "poster-5.webp",
        "kick": ("Streak & statistik", "Streaks & stats"),
        "h": ("Lihat pagimu makin konsisten.", "Watch your mornings get consistent."),
        "p": ("Setiap misi yang selesai menambah streak-mu. Lihat rekor terbaik, rata-rata jam bangun, dan kalender bulanan.",
              "Every mission you finish grows your streak. See your best run, average wake-up time and a monthly calendar."),
        "li": [("Tanpa akun, tanpa iklan", "No account, no ads"),
               ("Foto & kamera diproses di HP-mu", "Photos and camera stay on your phone")],
    },
]

SOUNDS = ["Tung Tung Tung Sahur", "Bapak Bangunin Sahur", "Om Telolet Om", "Tahu Bulat", "Sayuuur!",
          "Rem Truk", "Emotional Damage", "Vine Boom", "Sirine Nuklir", "Bombardiro Crocodilo",
          "Brr Brr Patapim", "Metal Gear Alert"]

FAQ = [
    ("Bangunin gratis?", "Is Bangunin free?",
     "Bangunin gratis diunduh. Untuk memakainya kamu berlangganan Bangunin Premium, bulanan atau tahunan, lewat App Store atau Google Play. Harganya tertera di aplikasi sebelum kamu membayar.",
     "Bangunin is free to download. To use it you subscribe to Bangunin Premium, monthly or yearly, through the App Store or Google Play. The price is shown in the app before you pay."),
    ("Bagaimana kalau ada keadaan darurat?", "What if there's a real emergency?",
     "Selalu ada Emergency Escape. Sengaja dibuat sedikit merepotkan supaya tidak jadi tombol snooze baru, tapi kamu tidak akan pernah terjebak.",
     "There's always an Emergency Escape. It's deliberately a little tedious so it doesn't become a new snooze button, but you're never trapped."),
    ("Apakah fotoku diunggah?", "Are my photos uploaded?",
     "Tidak. Foto, kamera, dan gerakan diproses di HP-mu dan tidak dikirim ke mana pun.",
     "No. Photos, the camera and movement checks are processed on your phone and never sent anywhere."),
    ("Alarmku bunyi kalau HP mode senyap?", "Will it ring on Silent?",
     "Di iPhone dengan iOS 26 dan izin Alarm aktif, ya. Bangunin memakai sistem alarm iOS. Kalau izin Alarm mati, Bangunin langsung memberi tahu dan menunjukkan cara menyalakannya.",
     "On iPhone with iOS 26 and the Alarms permission on, yes. Bangunin uses the iOS alarm system. If Alarms is off, Bangunin tells you straight away and shows you how to switch it on."),
    ("Bisa untuk sahur?", "Can I use it for sahur?",
     "Bisa banget. Ada suara khusus seperti Tung Tung Tung Sahur dan Bapak Bangunin Sahur, plus misi supaya kamu tidak tidur lagi setelah alarm.",
     "Absolutely. There are dedicated sounds like Tung Tung Tung Sahur and Bapak Bangunin Sahur, plus missions so you don't fall back asleep."),
]


def index_page() -> str:
    ld = {
        "@context": "https://schema.org",
        "@type": "MobileApplication",
        "name": "Bangunin: Alarm Misi",
        "operatingSystem": "iOS, Android",
        "applicationCategory": "LifestyleApplication",
        "description": "Alarm yang baru berhenti setelah kamu menyelesaikan misi bangun.",
        "url": SITE + "/",
        "image": f"{SITE}/apple-touch-icon.png",
        "publisher": {"@type": "Organization", "name": "HAYAT TIME LTD"},
    }
    extra = f'<script type="application/ld+json">{json.dumps(ld, ensure_ascii=False)}</script>'
    missions = "".join(
        f'<div class="card mission"><div class="ico">{ico}</div>{t(ti, te, "h3")}{t(di, de, "p")}</div>'
        for ico, ti, te, di, de in MISSIONS
    )
    feats = ""
    for n, f in enumerate(FEATURES):
        lis = "".join(t(a, b, "li") for a, b in f["li"])
        feats += f"""<div class="feature-row{' flip' if n % 2 else ''}">
<div>{t(*f['kick'], 'span', ' class="kicker"')}{t(*f['h'], 'h3')}{t(*f['p'], 'p')}<ul>{lis}</ul></div>
<div class="feature-media"><img src="/{f['img']}" alt="" width="720" height="1080" loading="lazy"></div>
</div>"""
    chips = "".join(f'<span class="chip">{html.escape(s)}</span>' for s in SOUNDS)
    gallery = "".join(
        f'<img src="/poster-{i}.webp" alt="Bangunin screen {i}" width="720" height="1080" loading="lazy">'
        for i in range(1, 7)
    )
    faq = "".join(f"<details>{t(qi, qe, 'summary')}{t(ai, ae, 'p')}</details>" for qi, qe, ai, ae in FAQ)
    posts = "".join(post_card(p) for p in POSTS[:3])
    return (
        head(lang="id", title="Bangunin: Alarm Misi, Alarm yang Bikin Kamu Benar-Benar Bangun",
             description="Alarm yang baru berhenti setelah kamu menyelesaikan misi bangun: foto, cari benda, matematika, squat. Nggak bisa dimatiin sambil tidur.",
             path="", extra=extra,
             alternates={"id": SITE + "/", "x-default": SITE + "/"})
        + header(True)
        + f"""<main>
<section class="hero"><div class="stars"></div><div class="wrap hero-grid">
<div class="hero-copy">
{t("⏰ Alarm misi untuk yang susah bangun", "⏰ The mission alarm for heavy sleepers", "span", ' class="eyebrow"')}
{t('Alarm yang <span class="hl">nggak bisa</span> kamu matiin sambil tidur.', 'The alarm you <span class="hl">can&#39;t</span> turn off in your sleep.', "h1", "", True)}
{t("Bangunin baru diam setelah kamu menyelesaikan misi bangun: foto langit, cari benda, matematika, atau squat. Geser buat matiin? Semenit lagi dia bunyi lagi.", "Bangunin only stops once you finish a wake-up mission: snap the sky, find an object, do some maths or squats. Swipe it away? It's back a minute later.", "p", ' class="lead"')}
{store_buttons("both")}
<div class="trust">{t("Tanpa akun", "No account")}{t("Tanpa iklan", "No ads")}{t("Foto tetap di HP-mu", "Photos stay on your phone")}</div>
</div>
<div class="hero-art"><img class="poster" src="/poster-1.webp" alt="" width="720" height="1080">
<img class="chick" src="/chick-crowing.webp" alt="" width="150" height="150"></div>
</div></section>

<section class="pain"><div class="wrap">
<div class="sec-head center">{t("Kenal rasanya?", "Sound familiar?", "span", ' class="kicker"')}
{t("Alarm biasa terlalu gampang dikalahkan.", "Normal alarms are too easy to beat.", "h2")}</div>
<div class="grid-3">
<div class="card"><div class="big">5×</div>{t("Snooze lagi, lagi, lagi", "Snooze, snooze, snooze", "h3")}{t("Lima menit lagi, katanya. Tahu-tahu sudah setengah jam.", "Just five more minutes. Then it's half an hour later.", "p")}</div>
<div class="card"><div class="big">🔇</div>{t("Dimatiin tanpa sadar", "Switched off half-asleep", "h3")}{t("Kamu nggak ingat pernah mematikannya, tapi alarmnya mati.", "You don't remember turning it off, but it's off.", "p")}</div>
<div class="card"><div class="big">😵</div>{t("Kesiangan lagi", "Late again", "h3")}{t("Kuliah pagi, kerja, sahur. Semuanya kelewat.", "Early class, work, sahur. All missed.", "p")}</div>
</div></div></section>

<section class="alt steps"><div class="wrap">
<div class="sec-head center">{t("Cara kerjanya", "How it works", "span", ' class="kicker"')}
{t("Tiga langkah ke pagi yang beneran.", "Three steps to a real morning.", "h2")}</div>
<div class="grid-3">
<div class="card"><div class="num">1</div>{t("Atur alarm & misi", "Set an alarm & mission", "h3")}{t("Pilih jam, hari, suara, dan misi yang harus kamu selesaikan.", "Pick the time, days, sound, and the mission you'll have to finish.", "p")}</div>
<div class="card"><div class="num">2</div>{t("Alarm bunyi, layar penuh", "It rings, full screen", "h3")}{t("Alarm asli yang tembus mode senyap dan muncul di layar kunci.", "A real alarm that rings through Silent and shows on the Lock Screen.", "p")}</div>
<div class="card"><div class="num">3</div>{t("Selesaikan misi, baru diam", "Finish the mission, then silence", "h3")}{t("Begitu misi selesai, kamu sudah melek. Streak-mu bertambah.", "By the time it's done, you're awake. Your streak grows.", "p")}</div>
</div></div></section>

<section id="misi"><div class="wrap">
<div class="sec-head center">{t("Misi bangun", "Wake-up missions", "span", ' class="kicker"')}
{t("Pilih caramu membuktikan sudah bangun.", "Choose how you prove you're up.", "h2")}
{t("Dari yang santai sampai yang bikin keringetan. Gabungkan beberapa misi kalau kamu raja tidur.", "From easy to sweaty. Chain several missions if you're a champion sleeper.", "p")}</div>
<div class="grid-4">{missions}</div>
</div></section>

<section id="fitur" class="alt"><div class="wrap">
<div class="sec-head center">{t("Fitur", "Features", "span", ' class="kicker"')}
{t("Dibuat supaya kamu benar-benar bangun.", "Built so you actually get up.", "h2")}</div>
{feats}
</div></section>

<section class="sahur"><div class="wrap">
<div class="card"><img src="/chick-celebrating.webp" alt="" width="140" height="140" loading="lazy">
<div>{t("Suara alarm", "Alarm sounds", "span", ' class="kicker"')}
{t("20+ suara meme & sahur yang bikin melek.", "20+ meme & sahur sounds that wake you up.", "h2", ' style="font-size:clamp(28px,3.6vw,42px);margin:8px 0 10px"')}
{t("Dari teriakan bapak bangunin sahur sampai Vine Boom. Atau rekam dan impor suaramu sendiri.", "From the sahur dad's yell to Vine Boom. Or record and import your own.", "p", ' style="color:var(--muted);margin:0"')}
<div class="chips">{chips}</div></div></div>
</div></section>

<section class="alt"><div class="wrap">
<div class="sec-head center">{t("Lihat aplikasinya", "See the app", "span", ' class="kicker"')}
{t("Bangunin di HP-mu.", "Bangunin on your phone.", "h2")}</div>
<div class="gallery">{gallery}</div>
</div></section>

<section><div class="wrap">
<div class="sec-head">{t("Dari blog", "From the blog", "span", ' class="kicker"')}
{t("Tips bangun pagi.", "Wake-up tips.", "h2")}</div>
<div class="posts">{posts}</div>
<p style="margin-top:22px"><a href="/blog" style="font-weight:800">{t("Semua artikel →", "All articles →")}</a></p>
</div></section>

<section class="alt"><div class="wrap" style="max-width:820px">
<div class="sec-head center">{t("Pertanyaan", "Questions", "span", ' class="kicker"')}
{t("Pertanyaan wajar dari raja snooze.", "Fair questions from pro snoozers.", "h2")}</div>
{faq}
</div></section>

<section class="final"><div class="wrap">
<img src="/chick-happy.webp" alt="" width="160" height="160" loading="lazy">
{t("Besok pagi adalah misi pertamamu.", "Tomorrow morning is your first mission.", "h2")}
{t("Unduh sekarang, dan rasakan bangun tanpa drama snooze.", "Download it now, and wake up without the snooze drama.", "p")}
{store_buttons("both")}
</div></section>
</main>"""
        + FOOTER + LANG_JS + "</body></html>"
    )


LEGAL_SRC = Path(__file__).parent / "site-legal"


def legal_page(name: str) -> str:
    """Privacy and terms, in the site's look. Wording lives in site-legal/."""
    src = (LEGAL_SRC / f"{name}.html").read_text(encoding="utf-8")
    meta = dict(line[5:-4].split(": ", 1) for line in src.splitlines()[:2])
    body = "\n".join(src.splitlines()[2:])
    return (
        head(lang="en", title=f"{meta['title']} | Bangunin", description=meta["description"], path=name)
        + header(False)
        + f'<main class="legal"><div class="wrap article">{body}</div></main>'
        + FOOTER + "</body></html>"
    )


def sitemap() -> str:
    urls = [SITE + "/", SITE + "/blog"] + [f"{SITE}/{p['slug']}" for p in POSTS] + [SITE + "/privacy", SITE + "/terms"]
    body = "".join(f"<url><loc>{u}</loc><lastmod>{UPDATED}</lastmod></url>" for u in urls)
    return f'<?xml version="1.0" encoding="UTF-8"?><urlset xmlns="http://www.sitemaps.org/schemas/sitemap/0.9">{body}</urlset>\n'


def main() -> None:
    (OUT / "index.html").write_text(index_page(), encoding="utf-8")
    (OUT / "blog.html").write_text(blog_page(), encoding="utf-8")
    for post in POSTS:
        (OUT / f"{post['slug']}.html").write_text(article_page(post), encoding="utf-8")
    for name in ("privacy", "terms"):
        (OUT / f"{name}.html").write_text(legal_page(name), encoding="utf-8")
    (OUT / "sitemap.xml").write_text(sitemap(), encoding="utf-8")
    (OUT / "robots.txt").write_text(f"User-agent: *\nAllow: /\nSitemap: {SITE}/sitemap.xml\n", encoding="utf-8")
    print("built", len(POSTS), "articles")


if __name__ == "__main__":
    main()
