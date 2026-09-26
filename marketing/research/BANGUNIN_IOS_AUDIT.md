# Bangunin — iOS Implementation & Screen Audit

**Date:** 3 August 2026
**Branch:** `agent/ios-alarm-ux-overhaul`
**Baseline commit:** `28eed3d` ("Prepare Bangunin store releases"), branched from `release/google-play-readiness`
**Companion doc:** [`IOS_COMPETITOR_UX_RESEARCH.md`](./IOS_COMPETITOR_UX_RESEARCH.md)

---

## 0. Summary and overall verdict

**This is a well-built codebase.** 83 Dart files, ~15,300 lines, clean feature-first architecture (Riverpod 3, go_router, freezed, Hive), and unusually thoughtful inline comments that explain *why* rather than *what*. Several things the brief asked me to check were already done correctly — see §6.

The problems are concentrated in two areas, and both are **truthfulness** problems rather than craft problems:

1. **The alarm does not reliably ring** (§1). On iOS it is a scheduled notification wearing an alarm's clothes.
2. **The mission verification does not reliably verify** (§2). Several missions pass on inputs that clearly should fail, while the UI presents the result as a confident verdict.

Everything else — visual polish, localisation gaps, accessibility — is real but secondary. An alarm app that doesn't ring and a "prove you're awake" app you can fool with a green shirt are existential; imperfect spacing is not.

**Severity key:** 🔴 Critical (blocks a credible release) · 🟠 High · 🟡 Medium · 🟢 Low

---

## 1. Alarm scheduling and reliability

### 🔴 A1 — iOS alarms are notifications, not alarms

**File:** [`lib/features/alarms/data/alarm_scheduler.dart`](../../lib/features/alarms/data/alarm_scheduler.dart)

The scheduler maps each alarm onto `flutter_local_notifications` entries. Its own comment concedes the constraint: *"iOS has no true repeating exact alarms."*

Consequences on a real iPhone, none of which are currently disclosed to the user:

- Will **not** sound through the ringer switch (Silent Mode).
- Will **not** break through a Focus or Sleep Focus schedule.
- Audio stops after roughly 30 seconds; it cannot ring until dismissed.
- Cannot force-launch the app. [`ringing_page.dart`](../../lib/features/ringing/presentation/pages/ringing_page.dart) — the mission takeover, the whole product concept — only renders **if the user chooses to tap the notification**. A heavy sleeper who does not tap it never sees a mission.

`UIBackgroundModes: audio` is declared in `Info.plist`, but that keeps *already-playing* audio alive; it does not resurrect a terminated app at 05:00.

**Fix:** AlarmKit on iOS 26+, honest fallback below that. See Phase 3 plan.

### 🔴 A2 — `NSAlarmKitUsageDescription` absent; no AlarmKit integration

**File:** [`ios/Runner/Info.plist`](../../ios/Runner/Info.plist)

No AlarmKit usage-description key, no AlarmKit code, and no Widget Extension target (AlarmKit's `AlarmAttributes` is an `ActivityKit.ActivityAttributes`, so alarm presentation requires one). Deployment target is 15.5, which is *correct* to keep — AlarmKit is reachable via `@available(iOS 26.0, *)` without abandoning older devices.

### 🟠 A3 — `cancelAll()` on every reschedule destroys pending snoozes

**File:** `alarm_scheduler.dart`, `reschedule()`

```dart
await _notifications.cancelAll();
for (final alarm in alarms.where((a) => a.enabled)) { ... }
```

`scheduleSnooze()` writes to `baseId + occurrencesPerAlarm` — a slot outside the loop's range, so it is **never re-created** after a `cancelAll()`. Any alarm edit, toggle, add or delete that happens while a snooze is pending silently cancels that snooze. The user snoozes at 05:05, toggles a different alarm off at 05:06, and is never woken.

**Failure scenario:** snooze 5 min → toggle any alarm → snooze never fires.

### 🟠 A4 — Undisclosed pending-notification ceiling

`occurrencesPerAlarm = 8`, and iOS caps pending local notifications at **64** per app (long-standing platform limit — worth re-verifying against current docs before quoting it in the UI). That is a hard ceiling of **8 repeating alarms**; beyond that, later alarms are silently dropped by the OS with no warning anywhere in the UI.

Under AlarmKit there is a separate documented cap — `AlarmManager.AlarmError.maximumLimitReached` exists in the SDK and must be caught and surfaced.

### 🟡 A5 — No timezone-change or reboot rehydration hook

No listener re-runs `reschedule()` on `didChangeLocales`/timezone change or on app relaunch after reboot. `flutter_timezone` is a dependency but I found no re-scheduling trigger tied to timezone shifts. A user flying Jakarta → Bali (WIB → WITA) keeps alarms on the old offset until something else triggers a reschedule.

---

## 2. Mission verification

**File:** [`lib/features/missions/data/photo_mission_verifier.dart`](../../lib/features/missions/data/photo_mission_verifier.dart)

All photo missions downscale to 96×96 and run pixel statistics. The file's own doc comment is admirably honest (*"intentionally described as a heuristic"*), but **the UI does not carry that honesty through to the user**, and several thresholds are far too permissive.

### 🔴 B1 — Grass mission is literally green-pixel counting

```dart
if (p.g > p.r * 1.08 && p.g > p.b * 1.08) greenish++;
return (greenish / samples > 0.35) ? pass : fail;
```

This is precisely the approach the brief forbids. **Passes:** a green T-shirt, a green wall, a green notebook, a houseplant, a photo of grass displayed on another screen. There is no hand detection, no texture analysis, no liveness check.

### 🔴 B2 — Sky mission passes a white ceiling

```dart
if (b > r * 1.05 && b > g * 0.95) blueScore++;
if ((r + g + b) / 3 > 175 && saturation < 0.25) blueScore++;   // ← overcast clause
```

The second clause counts *any* bright desaturated pixel as sky-like, to accommodate overcast skies. A white or light-grey ceiling — exactly what the phone faces when you point it up **without getting out of bed** — satisfies it comfortably. This defeats the mission's entire purpose.

### 🔴 B3 — Make Your Bed accepts arbitrary textured photos

Gates are: mean brightness 45–225, edge ratio 0.08–0.72, and left/right mean-brightness delta < 55. A carpet, a desk, a curtain, a wall with a poster, or a jumper on the floor all pass. The brief explicitly requires this mission not accept an arbitrary bright photograph; today it largely does.

### 🟠 B4 — Object Hunt similarity threshold is very weak

A 4×4×4 (64-bin) RGB histogram compared by cosine similarity with a `> 0.60` pass threshold. Normalised histogram cosine similarity is dominated by the largest bins, which are typically wall/floor/lighting — not the object. Two photos of the *same room from different angles*, with the target object entirely absent, will routinely exceed 0.60.

### 🔴 B5 — No liveness: every photo mission is defeated by photographing a photo

Verification runs on a **single still frame**. Photographing a picture of grass, the sky, or a made bed on a second screen passes every check. The brief requires multi-frame verification over a short interval for Touch Grass specifically; the same weakness applies across all four photo missions.

### 🟠 B6 — Pushup counter does not require an extended start state

**File:** [`lib/features/missions/data/pose_rep_counter.dart`](../../lib/features/missions/data/pose_rep_counter.dart)

The state machine initialises `_downConfirmed = false` and then waits for the **down** position first, counting a rep on the subsequent **up**. So the sequence it actually rewards is `bent → extended`. A user already lying on the floor who pushes up once scores a rep without ever completing a full down-up cycle. The brief requires an extended-arm starting state before counting begins.

**Credit where due:** repeated counting while holding a pose *is* correctly prevented — `_downConfirmed` resets to `false` after each rep, forcing a fresh descent. The 3-frame confirmation and 650 ms debounce are also sound in structure.

### 🟠 B7 — No "joints left the frame" feedback channel

`addPose()` returns a bare `bool` meaning "a rep was counted". When landmarks fall below the 0.65 likelihood threshold it returns `false` — indistinguishable from "in progress". The UI therefore cannot tell the user *"I can't see your elbows, move back"*, which the brief explicitly requires and which is the single most common real-world failure of camera exercise counters.

### 🟡 B8 — Square resize distorts geometry

`copyResize(decoded, width: 96, height: 96)` ignores aspect ratio, stretching a 4:3 or 16:9 frame. Harmless for colour histograms, but it will bias any future edge/structure analysis.

---

## 3. Localisation

### 🟠 C1 — Access-code dialog bypasses the localisation system entirely

**File:** [`lib/features/paywall/presentation/pages/paywall_page.dart:311-353`](../../lib/features/paywall/presentation/pages/paywall_page.dart)

```dart
final isIndonesian = Localizations.localeOf(context).languageCode == 'id';
title: Text(isIndonesian ? 'Masukkan kode akses' : 'Enter access code'),
hintText: isIndonesian ? 'Kode akses' : 'Access code',
child: Text(isIndonesian ? 'Batal' : 'Cancel'),
child: Text(isIndonesian ? 'Gunakan' : 'Redeem'),
```

Six user-facing strings hardcoded with an inline ternary instead of ARB keys. Users in the four other shipped locales get English. This is also the **reviewer/friend access-code path** — the flow an App Review tester is most likely to exercise.

### 🟡 C2 — Four locales missing keys, falling back to English mid-screen

`app_en.arb` has 212 keys; `ar`, `de`, `es`, `fr` have 208 each. Missing from all four:
`founderStoryBody`, `founderStorySignature`, `founderStoryTitle`, `settingsOurStory`.

A French user opens Settings and sees an English menu item leading to an English story page.

### 🟡 C3 — Three dead keys in `app_id.arb`

`paywallCta`, `planWeekly`, `pricePerWeek` exist in Indonesian only, with no counterpart in the `app_en.arb` template — leftovers from a removed weekly plan. Harmless at runtime, but they are noise and imply a pricing tier that no longer exists.

### 🟡 C4 — Shipping `ar`/`de`/`es`/`fr` for an Indonesia-first launch

Five non-primary locales are a maintenance and quality liability (C2 is already the first symptom). Recommend **shipping `id` + `en` only** and archiving the rest until they can be reviewed by native speakers. This is a product decision for Islam, not something I should change unilaterally — flagged in §7.

---

## 4. Accessibility

### 🟠 D1 — Ringing screen animation ignores Reduce Motion

**File:** `ringing_page.dart`

A continuously repeating opacity (0.55→1.0) and scale (0.97→1.03) animation runs full-screen with no `MediaQuery.disableAnimations` / `accessibleNavigation` check. A pulsing full-screen animation aimed at someone half-awake in a dark room is a genuine vestibular and photosensitivity concern, not a nitpick.

### 🟠 D2 — Dynamic Type overflow risk on the ringing screen

The clock uses `displayLarge` inside a fixed `Column` with `Spacer`s. At the largest accessibility text sizes the clock, label, mission name, button and snooze row will not co-exist in the available height. The ringing screen is the *worst* place to clip content.

### 🟡 D3 — Swipe-to-delete has no VoiceOver-accessible equivalent

**File:** `home_page.dart` — `Dismissible` swipe is the only delete affordance on the alarm list. VoiceOver users have no custom action or alternative path to delete an alarm.

### 🟡 D4 — Decorative mascot needs explicit semantics audit

`BanguninMascot` appears on functional screens (home hero card, ringing screen). Decorative instances should be `ExcludeSemantics`; the interactive tap-to-crow easter-egg instance on the empty state needs a real label.

---

## 5. App Review risk register

| # | Risk | Guideline area | Severity |
|---|---|---|---|
| R1 | Marketing or UI implying the app overrides Silent Mode/Focus when running the pre-26 notification fallback | 2.3 Accurate Metadata | 🔴 |
| R2 | Mission verification presented as certainty when it is a weak heuristic (§2) | 2.3 / user trust | 🟠 |
| R3 | `UIBackgroundModes: audio` must be genuinely justified by shipped behaviour | 2.5.4 | 🟠 |
| R4 | Restore Purchases must be present, prominent and functional — Alarmy is actively losing stars on reinstall-recognition failures | 3.1.1 | 🟠 |
| R5 | Access-code path is a reviewer entry point and is currently the least-localised, least-polished flow in the app (§C1) | 2.1 completeness | 🟠 |
| R6 | Subscription screen must show price, period, renewal terms, and links to Terms/Privacy adjacent to purchase | 3.1.2 | 🟠 |
| R7 | Camera/mic usage strings must match actual use; `NSPhotoLibraryUsageDescription` is declared — confirm the library is genuinely accessed, or remove the key | 5.1.1 | 🟡 |

Per Islam's standing pre-submission rules (from prior HayatTime submissions, which apply here): confirm no promo-code bypass ships in the binary, EULA/terms links present, Parental Controls declared correctly, and a working demo account plus sandbox note supplied in App Review notes.

---

## 6. What is already correct — do not "fix" these

Recording these explicitly so later work doesn't regress them:

- ✅ **Temporary mission photos are deleted.** `photo_mission_page.dart:67,85` and `object_registration_page.dart:29-45` both delete attempts promptly, and `alarms_provider.dart:60` cleans up a replaced Object Hunt reference. The privacy posture in the brief is already implemented.
- ✅ **Object Hunt reference images are kept distinct** from temporary attempts, as the brief requires.
- ✅ **No content leaves the device.** Verification is entirely local; no network calls in any mission path.
- ✅ **Trial wording is already honest.** Separate `paywallCtaTrial` / `paywallCtaNoTrial` keys driven by real store-reported eligibility (`_appleFreeTrialDays` reads `introductoryPrice` / SK2 `freeTrial` offers). The app does **not** hardcode trial entitlement — exactly what the brief demands.
- ✅ **`fakePaywall` defaults to `kDebugMode`**, overridable only by an explicit `--dart-define`. Real billing in release is correctly wired.
- ✅ **Access codes are SHA-256 hashed**, not plaintext, in `subscription_service.dart:331`.
- ✅ **Manage-subscription URLs exist for both stores**, correctly branched.
- ✅ **No secrets, keystores, provisioning profiles or build output are tracked in git.** Verified by pattern scan across `git ls-files`.
- ✅ **Repetition-hold guarding and debounce** in the pose counter are structurally sound (§B6).

---

## 7. Decisions I need from Islam

These change scope and I should not make them unilaterally:

1. **Locales** — ship `id` + `en` only and archive `ar`/`de`/`es`/`fr` (§C4)? My recommendation: yes.
2. **Grass/Bed verification ceiling** — a genuinely robust hand-on-grass check likely needs a bundled on-device model (size, licence and accuracy implications, per the brief's requirement to document before adding). The alternative is to keep it heuristic but **relabel the missions honestly** and make failure recoverable. My recommendation: honesty-first now, model evaluated separately.
3. **Minimum iOS version** — staying at 15.5 as the brief instructs. Confirm you accept that pre-26 devices get the clearly-labelled weaker fallback.

---

## 8. Priority order for implementation

1. 🔴 AlarmKit + honest fallback + capability disclosure UI (A1, A2)
2. 🔴 Snooze-cancellation bug (A3) — small fix, silent total failure
3. 🔴 Mission verification honesty: multi-frame liveness, tighter thresholds, truthful copy (B1–B5)
4. 🟠 Pose counter start-state + out-of-frame feedback (B6, B7)
5. 🟠 Design system + accessibility pass (D1–D4)
6. 🟠 Localisation cleanup (C1–C3)
7. 🟡 Alarm-count ceiling disclosure (A4), timezone rehydration (A5)
