// Injects the interactive mascot into marketing/landing/index.html:
//   * hero: a living chick above the headline — bobs and wing-flaps on an
//     idle loop, crows with a "Kukuruyuk!" bubble on click/tap, and gets
//     excited (celebrating pose) when the email field is focused;
//   * phone mockup: the alarm orb becomes the crowing chick (pulse rings
//     kept).
// Poses are embedded as data URIs from marketing/brand/poses_web/ so the
// page stays a single self-contained file.
//
// Run once: dart run tool/inject_landing_mascot.dart
import 'dart:convert';
import 'dart:io';

String uri(String name) =>
    'data:image/png;base64,${base64Encode(File('marketing/brand/poses_web/$name.png').readAsBytesSync())}';

void main() {
  final htmlFile = File('marketing/landing/index.html');
  var html = htmlFile.readAsStringSync();

  if (html.contains('id="hero-mascot"')) {
    stderr.writeln('Mascot already injected — aborting to avoid duplicates.');
    exit(1);
  }

  final happy = uri('happy');
  final flap = uri('flap_down');
  final crowing = uri('crowing');
  final celebrating = uri('celebrating');

  // ---- 1. CSS ----
  const cssAnchor = '  /* Live phone mockup */';
  const mascotCss = '''
  /* Hero mascot — the living chick */
  .hero-mascot-wrap { position: relative; width: 130px; height: 130px; margin-bottom: 6px; }
  .hero-mascot {
    width: 130px; height: 130px; display: block; cursor: pointer;
    animation: mascot-bob 2.6s ease-in-out infinite;
    transition: transform 0.15s ease;
    -webkit-user-select: none; user-select: none;
  }
  .hero-mascot.jump { animation: mascot-jump 0.55s ease; }
  @keyframes mascot-bob {
    0%, 100% { transform: translateY(0) rotate(-1deg); }
    50% { transform: translateY(-7px) rotate(1deg); }
  }
  @keyframes mascot-jump {
    0% { transform: translateY(0) scale(1); }
    35% { transform: translateY(-22px) scale(1.08); }
    70% { transform: translateY(0) scale(0.96); }
    100% { transform: translateY(0) scale(1); }
  }
  .mascot-bubble {
    position: absolute; left: 108px; top: 2px;
    background: var(--sunrise); color: #201900;
    font-size: 14px; font-weight: 800; white-space: nowrap;
    padding: 8px 14px; border-radius: 14px 14px 14px 4px;
    opacity: 0; transform: translateY(6px) scale(0.9);
    transition: opacity 0.18s ease, transform 0.18s ease;
    pointer-events: none;
  }
  .mascot-bubble.show { opacity: 1; transform: translateY(0) scale(1); }
  @media (prefers-reduced-motion: reduce) {
    .hero-mascot { animation: none; }
  }
  @media (max-width: 880px) {
    .hero-mascot-wrap { margin-inline: auto; }
  }

$cssAnchor''';
  if (!html.contains(cssAnchor)) {
    stderr.writeln('CSS anchor not found.');
    exit(1);
  }
  html = html.replaceFirst(cssAnchor, mascotCss);

  // ---- 2. Hero markup ----
  const heroAnchor =
      '    <p class="eyebrow" data-id="Alarm yang ngecek kamu beneran bangun"';
  final heroMascot =
      '''
    <div class="hero-mascot-wrap">
      <img id="hero-mascot" class="hero-mascot" src="$happy" alt="Maskot Bangunin" draggable="false">
      <span class="mascot-bubble" id="mascot-bubble">Kukuruyuk!</span>
    </div>
$heroAnchor''';
  if (!html.contains(heroAnchor)) {
    stderr.writeln('Hero anchor not found.');
    exit(1);
  }
  html = html.replaceFirst(heroAnchor, heroMascot);

  // ---- 3. Phone orb → crowing chick ----
  const orbBlock = '''
          <span class="orb">
            <svg viewBox="0 0 24 24" fill="none" stroke="#fff" stroke-width="2" stroke-linecap="round">
              <circle cx="12" cy="13" r="7"></circle><path d="M12 10v3l2 2"></path><path d="M5 4 3 6M19 4l2 2"></path>
            </svg>
          </span>''';
  final orbChick = '''
          <img class="orb" style="background: none; object-fit: contain;" src="$crowing" alt="" aria-hidden="true">''';
  if (!html.contains(orbBlock)) {
    stderr.writeln('Orb block not found.');
    exit(1);
  }
  html = html.replaceFirst(orbBlock, orbChick);

  // ---- 4. JS ----
  const jsAnchor =
      '  /* ============ Live ticking clock in the hero phone ============ */';
  final mascotJs =
      '''
  /* ============ Hero mascot: flap, crow on click, react to form ============ */
  (function () {
    var poses = {
      happy: "$happy",
      flap: "$flap",
      crowing: "$crowing",
      celebrating: "$celebrating"
    };
    var el = document.getElementById("hero-mascot");
    var bubble = document.getElementById("mascot-bubble");
    if (!el) return;
    var reduced = window.matchMedia("(prefers-reduced-motion: reduce)").matches;
    var state = "idle"; // idle | crowing | excited
    var flapFrame = false;

    // Idle wing-flap: alternate the two keyframes.
    if (!reduced) {
      setInterval(function () {
        if (state !== "idle") return;
        flapFrame = !flapFrame;
        el.src = flapFrame ? poses.flap : poses.happy;
      }, 1300);
    }

    // Click → jump + crow + bubble.
    el.addEventListener("click", function () {
      if (state === "crowing") return;
      state = "crowing";
      el.src = poses.crowing;
      el.classList.add("jump");
      bubble.classList.add("show");
      setTimeout(function () {
        el.classList.remove("jump");
        bubble.classList.remove("show");
        el.src = poses.happy;
        state = "idle";
      }, 1400);
    });

    // Email focus → excited chick cheering you on.
    document.querySelectorAll('.waitlist input[type="email"]').forEach(function (input) {
      input.addEventListener("focus", function () {
        if (state === "crowing") return;
        state = "excited";
        el.src = poses.celebrating;
      });
      input.addEventListener("blur", function () {
        if (state === "crowing") return;
        state = "idle";
        el.src = poses.happy;
      });
    });
  })();

$jsAnchor''';
  if (!html.contains(jsAnchor)) {
    stderr.writeln('JS anchor not found.');
    exit(1);
  }
  html = html.replaceFirst(jsAnchor, mascotJs);

  htmlFile.writeAsStringSync(html);
  stdout.writeln('Injected interactive mascot into landing page.');
}
