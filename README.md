~~~~# Bangunin — mission-based alarm clock

**Bangunin** (colloquial Indonesian: "wake someone up") is a production-grade
Flutter alarm app in the mission-based category pioneered by Alarmy and Wakio:
an alarm you can only silence by proving you're out of bed — photographing the
sky, grass, your made bed, or a registered object, or completing squats/pushups
— with morning streaks, wake stats, custom alarm sounds, and a hard
subscription paywall.

Primary market is **Indonesia** (id locale, IDR pricing, student audience);
English ships alongside for the rest of the world. Mascot is a crowing rooster
("kukuruyuk!" is the sound of an Indonesian morning). See `marketing/INDO-LAUNCH.md`
for audience research, pricing rationale, the founder story, and the launch plan.

**All code, copy, artwork, and sounds in this repository are original.**
Nothing was extracted or copied from any competitor app.

> ⚠️ **Naming & trademarks.** "Bangunin" replaced the earlier working title.
> Before any store release, run a proper trademark/App Store search on the
> final name. Display name lives in `lib/core/config/app_config.dart`,
> `ios/Runner/Info.plist` `CFBundleDisplayName`, and
> `android/.../AndroidManifest.xml` `android:label`. The internal Dart
> package is still `wakio` (invisible to users; renaming it would churn
> every import for zero user-facing benefit). Bundle/application ids
> Android package: `app.bangunin`. This becomes permanent after the first
> bundle is uploaded to Play Console.
>
> Brand: electric-yellow crowing rooster on ink; bilingual (ID/EN) waitlist
> landing page in `marketing/landing/`.

## Product reconstruction (research notes)

Reconstructed from the public App Store listing, the developer's privacy
policy, and user reviews:

- **Core loop:** alarm rings → user starts a "wake-up mission" → mission
  verified on-device → alarm stops → streak +1 and success screen.
- **Missions:** photo (Object Hunt, Sky Photo, Grass Photo, Make Your Bed)
  and movement (squats, pushups). Object Hunt requires registering a
  reference photo at alarm-creation time.
- **Custom sounds:** import any audio/video clip or record with the mic.
- **Stats:** morning streak, best streak, average wake time, month calendar.
- **Monetization:** hard paywall after onboarding; weekly ($5.99) and yearly
  ($24.99 / $39.99) auto-renewing subscriptions, restore supported.
- **Architecture posture:** local-first, **no accounts and no backend** —
  alarms/stats never leave the device; entitlements via the store.
- **Onboarding:** short pain-survey (snooze habit → wake goal → struggles),
  notification permission prime, "personalizing" loader, then paywall.

## Architecture

Feature-first Clean Architecture with MVVM presentation:

```
lib/
  bootstrap.dart              # async init → DI overrides
  app/
    app.dart                  # MaterialApp.router
    router/                   # GoRouter + hard-paywall redirects
    theme/                    # colors / spacing / M3 themes (dark-primary)
    di/providers.dart         # composition root (Riverpod)
    widgets/                  # design kit: PressableScale, PrimaryButton, AppCard
  core/
    config/                   # AppConfig (ids, URLs, product ids)
    storage/local_store.dart  # Hive (JSON-per-entity, no adapters)
    services/
      notifications/          # exact, full-screen alarm notifications
      audio/                  # looping alarm playback + vibration
      subscriptions/          # SubscriptionService (StoreKit/Play + debug impl)
      analytics/ crash/ remote_config/   # swappable abstractions
  features/
    alarms/     # entity (freezed), repository, scheduler, home + editor UI
    missions/   # MissionType, photo verifier (pixel heuristics), rep counter
    ringing/    # ringing session state, due-alarm watcher, ringing/success UI
    stats/      # WakeRecord, StreakCalculator (pure), stats UI
    onboarding/ # survey steps + answers state
    paywall/    # plans, purchase flow, hard-gate UI
    settings/   # premium status, support, legal
  l10n/         # en, es, fr, de, ar (gen-l10n)
```

Key decisions:

- **Riverpod 3** for DI + state; router redirects react to
  `onboardingCompleted` and `isPremium` via `refreshListenable`.
- **Hive (hive_ce)** storing entities as JSON strings — models stay the
  single schema source; no generated adapters to drift.
- **Alarm delivery:** each enabled alarm pre-schedules its next 8 occurrences
  as exact OS notifications (iOS has no repeating exact alarms); a foreground
  watcher takes over when the app is open. Notification taps and app-launch
  payloads deep-link straight into the ringing screen, which is excluded from
  the paywall redirect so a ringing alarm can never be gated.
- **Photo verification** is on-device pixel statistics (blue/bright sky,
  green dominance, histogram similarity for Object Hunt) behind a small
  interface — swap in an ML labeler without touching the UI.
- **Rep counting** reads the user accelerometer with dip/rise thresholds and
  debouncing.
- **Subscriptions** behind `SubscriptionService`: `StoreSubscriptionService`
  (in_app_purchase) in release, `DebugSubscriptionService` in debug so the
  full flow works on simulators (`AppConfig.debugUnlockAll`, override with
  `--dart-define=WAKIO_DEBUG_UNLOCK=false`).
- **Analytics/crash/remote-config** are interfaces with local
  implementations; drop in Firebase by binding new implementations in
  `app/di/providers.dart` — no call-site changes.

## Getting started

```bash
flutter pub get
dart run tool/gen_sounds.dart                      # regenerates bundled WAVs (already committed)
dart run build_runner build --delete-conflicting-outputs
flutter gen-l10n
flutter run
```

Store setup (before release): create the three subscription products from
`AppConfig` in App Store Connect / Play Console, set real support/legal URLs,
and rename the app (see the trademark note above).

## Tests

```bash
flutter test                                   # unit + widget + golden (39 tests)
flutter test integration_test/app_test.dart -d <device>   # onboarding → paywall E2E
```

- Unit: alarm next-trigger math, streak/stat calculators, Hive repository,
  photo-verifier heuristics (synthetic images).
- Widget: alarm card, paywall (plans, purchase), onboarding survey gating.
- Golden: alarm card (enabled/disabled) under the dark theme.
