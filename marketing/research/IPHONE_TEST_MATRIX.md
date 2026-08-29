# Bangunin — iPhone Test Matrix

**Date:** 4 August 2026 · **Branch:** `agent/ios-alarm-ux-overhaul`

## How to read this

| Mark | Meaning |
|---|---|
| ✅ | Verified automatically (unit/widget/golden test, analyzer, or build) |
| 📱 | **Requires a physical iPhone. Not verified.** |
| ⚠️ | Known limitation — expected behaviour, not a bug to fix |

**Nothing in the 📱 column has been run.** No physical device was available and no signed build was produced. Anything claiming otherwise would be false. Critically, **AlarmKit reliability is inherently 📱** — no simulator or unit test can prove an alarm fires through Silent Mode on a locked, terminated device.

Test devices needed: one iPhone on **iOS 26+** (AlarmKit path) and one on **iOS 15.5–25** (fallback path). Both matter; they are different products.

---

## 1. Install and onboarding

| # | Case | Status | Notes |
|---|---|---|---|
| 1.1 | Fresh install → onboarding completes | 📱 | Widget tests cover the step logic ✅ |
| 1.2 | Onboarding creates the first alarm from answers | ✅ | `createFromOnboarding` unit-tested |
| 1.3 | Re-entering onboarding does not duplicate the alarm | ✅ | Guarded and tested |
| 1.4 | Permission education appears *before* the system prompt | 📱 | Dialog is unit-visible; ordering needs a device |
| 1.5 | Declining our education dialog leaves state untouched | ✅ | No request is made unless confirmed |

## 2. Alarm engine and authorization

| # | Case | Status | Notes |
|---|---|---|---|
| 2.1 | iOS 26+, authorized → AlarmKit engine | ✅ | `alarm_engine_routing_test` |
| 2.2 | iOS 26+, denied → notification fallback | ✅ | Tested |
| 2.3 | iOS 26+, not yet asked → fallback, banner offers upgrade | ✅ | `alarm_capability_test` |
| 2.4 | iOS < 26 → fallback, banner offers no action | ✅ | Tested |
| 2.5 | Only `authorized` ever claims full strength | ✅ | Explicitly pinned |
| 2.6 | Granting authorization re-arms existing alarms | ✅ | `resync()` wired; device confirmation 📱 |
| 2.7 | Declined user is never re-prompted | ✅ | `canUpgrade` false when denied |
| 2.8 | Both engines never armed at once (no double ring) | ✅ | Tested |
| 2.9 | `maximumLimitReached` surfaces rather than silently dropping | ✅ | Tested at the service layer |

## 3. Ringing — the cases that matter most

| # | Case | Status | Notes |
|---|---|---|---|
| 3.1 | Rings on a locked screen (AlarmKit) | 📱 | **The single most important untested case** |
| 3.2 | Rings with the app terminated (AlarmKit) | 📱 | |
| 3.3 | Rings through **Silent Mode** (AlarmKit) | 📱 | The core promise |
| 3.4 | Rings through **Focus / Do Not Disturb** (AlarmKit) | 📱 | |
| 3.5 | Fallback does **not** ring in Silent Mode | 📱 ⚠️ | Expected. Disclosed in the banner |
| 3.6 | Fallback does **not** launch the app | 📱 ⚠️ | Expected. iOS does not permit it |
| 3.7 | Fallback audio stops after ~30s | 📱 ⚠️ | Expected |
| 3.8 | Alert's mission button opens into the ringing screen | ✅ | Router implemented; device flow 📱 |
| 3.9 | Deleted alarm opened from an alert is ignored | ✅ | Guarded |
| 3.10 | Survives reboot | 📱 | AlarmKit persists; fallback re-arms on next launch |
| 3.11 | Low Power Mode | 📱 | |
| 3.12 | Multiple alarms, correct one fires | 📱 | Scheduling logic ✅ |

## 4. Scheduling edges

| # | Case | Status | Notes |
|---|---|---|---|
| 4.1 | Repeating weekday alarm sends ISO weekdays sorted | ✅ | Tested |
| 4.2 | One-off alarm sends an empty weekday list | ✅ | Tested |
| 4.3 | Disabled alarms are not scheduled | ✅ | Tested |
| 4.4 | **Snooze survives an unrelated alarm edit** | ✅ | Regression-tested — was a silent total failure |
| 4.5 | Elapsed snooze is not resurrected | ✅ | Tested |
| 4.6 | Completed wake clears the pending snooze | ✅ | Tested |
| 4.7 | Timezone change re-arms alarms | ✅ | Implemented on resume; device confirmation 📱 |
| 4.8 | >8 repeating alarms on the fallback path | 📱 ⚠️ | iOS 64-notification cap. **Still undisclosed in the UI** |
| 4.9 | App update with alarms scheduled | 📱 | |

## 5. Missions

| # | Case | Status | Notes |
|---|---|---|---|
| 5.1 | Pushups require an extended start position | ✅ | `pose_rep_counter_test` |
| 5.2 | Squats count off knee angle | ✅ | Tested |
| 5.3 | Partial reps and hysteresis bobbing count nothing | ✅ | Tested |
| 5.4 | Debounce rejects implausibly fast reps | ✅ | Tested |
| 5.5 | Low-confidence / missing landmarks give guidance | ✅ | Tested |
| 5.6 | Occlusion mid-rep prevents completion, recovers after | ✅ | Tested |
| 5.7 | Collapsed body line does not count as pushups | ✅ | Tested |
| 5.8 | Live skeleton overlay | ❌ | **Not implemented** — guidance text only |
| 5.9 | Grass rejects a flat green surface | ✅ | Tested |
| 5.10 | Sky rejects a white ceiling | ✅ | Tested |
| 5.11 | Bed rejects blank walls and dark frames | ✅ | Tested |
| 5.12 | Object Hunt rejects same-room-object-absent | ✅ | Tested |
| 5.13 | Identical burst frames rejected as not live | ✅ | Tested |
| 5.14 | Vision recognises grass / bed / sky on real photos | 📱 | **Thresholds uncalibrated** — see model evaluation |
| 5.15 | Touch Grass requires a hand in frame | ✅ | Logic tested; real-hand accuracy 📱 |
| 5.16 | Camera permission denied → recovery screen + Settings | ✅ | Implemented; device flow 📱 |
| 5.17 | Temp attempt photos deleted after verification | ✅ | Pre-existing, verified in audit |
| 5.18 | Object Hunt reference survives, attempts do not | ✅ | Verified in audit |
| 5.19 | Non-exercise alternative on every physical mission | ❌ | **Not implemented** — accessibility gap |

## 6. Billing

| # | Case | Status | Notes |
|---|---|---|---|
| 6.1 | Real StoreKit in release, fake only in debug | ✅ | `fakePaywall` defaults to `kDebugMode` |
| 6.2 | Trial CTA only when the store reports an offer | ✅ | Widget-tested both ways |
| 6.3 | No guaranteed-trial wording for ineligible users | ✅ | Separate ARB keys |
| 6.4 | Localized IDR prices | 📱 | Needs a sandbox account |
| 6.5 | Purchase (trial and non-trial) | 📱 | Sandbox |
| 6.6 | **Restore Purchases after reinstall** | 📱 | Alarmy loses stars here — test it properly |
| 6.7 | Manage Subscription reachable **on iOS** | ✅ | Was Android-only; fixed |
| 6.8 | Access code still grants premium | ✅ | Hashes unchanged, widget-tested |
| 6.9 | Cancellation reflected in the app | 📱 | Sandbox |
| 6.10 | Offline paywall behaviour | 📱 | Error state + access code path ✅ |

## 7. Accessibility

| # | Case | Status | Notes |
|---|---|---|---|
| 7.1 | Reduce Motion stops the ringing pulse | ✅ | Implemented; no widget test yet |
| 7.2 | Ringing screen survives AX5 with both actions reachable | ✅ | Scroll + clamp; **no AX5 widget test yet** |
| 7.3 | VoiceOver through onboarding, home, ringing | 📱 | |
| 7.4 | Swipe-to-delete has a VoiceOver equivalent | ❌ | **Not implemented** — audit D3 |
| 7.5 | Decorative mascots excluded from semantics | ❌ | **Not implemented** — audit D4 |
| 7.6 | No state conveyed by colour alone | ✅ | Failure states pair icon + text |

## 8. Localisation

| # | Case | Status | Notes |
|---|---|---|---|
| 8.1 | id and en only | ✅ | Verified in generated output |
| 8.2 | No inline `isIndonesian` ternaries remain | ✅ | Three removed; grep-verified |
| 8.3 | Access-code dialog localised | ✅ | Fixed |
| 8.4 | Indonesian copy reads naturally | 📱 | Needs a native speaker, not a test |

---

## Summary of what is genuinely unproven

1. **That AlarmKit alarms fire at all on a real device.** Everything about the integration is verified up to the OS boundary — API shape from the SDK interface, compilation, routing logic, engine selection — and nothing past it.
2. **That Vision's labels fire on real photos** at the chosen confidence. Logic is tested with stubs; the thresholds are uncalibrated.
3. **Anything involving StoreKit sandbox.**
4. **VoiceOver and real Dynamic Type rendering.**

## Known gaps still open

- Live skeleton overlay (5.8)
- Non-exercise mission alternative (5.19) — accessibility, not convenience
- VoiceOver delete action (7.4), mascot semantics (7.5)
- Alarm-count ceiling disclosure (4.8)
- AX5 and Reduce Motion widget tests (7.1, 7.2)
- Real-photo calibration set (5.14)
