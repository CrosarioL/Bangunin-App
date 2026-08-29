# Bangunin — iPhone Alarm App Competitor UX Research

**Author:** Bangunin engineering/design agent
**Date of research:** 3 August 2026
**Branch:** `agent/ios-alarm-ux-overhaul`

---

## 0. Method, scope and honesty statement

Read this section before trusting anything below it.

**What this research is based on:**

- Public App Store listings (title, subtitle, rating counts, IAP tier names and prices, description copy, screenshot captions).
- Publicly readable review aggregations and review-roundup articles.
- Apple's own developer documentation and the iOS 26.5 SDK installed on this machine.

**What this research is NOT based on:**

- I did not install, purchase, or operate any competitor app. I have no first-hand recording of their onboarding, ringing screens, or mission flows.
- I cannot see competitor screenshot *images* — only the textual captions and descriptions that accompany them, plus third-party written descriptions.
- I did not access any competitor's private assets, code, or design files.

**Consequence:** claims below marked **[Evidence]** are traceable to a cited source. Claims marked **[Inference]** are my professional reading, and could be wrong. Claims marked **[Bangunin decision]** are original design conclusions for our app and are not descriptions of anyone else's product. Do not let these categories blur — several published "app comparison" articles are affiliate-driven and repeat each other's errors, and at least one factual conflict is documented in §1.1.

**Copying policy applied throughout:** this document studies *interaction patterns and information architecture*, which are not protectable. It deliberately records no competitor illustration, mascot, icon, animation, colour formula, or marketing sentence for reuse. Section 8 lists what we must specifically avoid.

---

## 1. Competitor: Alarmy (Delight Room Co., Ltd.)

The category leader and Bangunin's closest conceptual competitor — it is the app that made "you must complete a task to dismiss the alarm" mainstream.

### 1.1 A factual conflict worth recording

Two different Alarmy apps exist on the US App Store and secondary sources routinely conflate them:

| App ID | Listing name | Rating | Ratings count |
|---|---|---|---|
| `1163786766` | Alarmy - Loud alarm clock | 4.8 ★ | ~242,000 |
| `1668848747` | Alarmy · Smart Alarm Clock | 4.1 ★ (per secondary source) | ~817 |

Roundup articles citing "Alarmy is 4.1 stars" are describing the second, much smaller listing. The flagship product is the first. **[Evidence]** — [App Store: Alarmy - Loud alarm clock](https://apps.apple.com/us/app/alarmy-loud-alarm-clock/id1163786766) (accessed 3 Aug 2026); [appshunter listing for id1668848747](https://appshunter.io/ios/app/alarmy-smart-alarm-clock/id1668848747) (accessed 3 Aug 2026).

**Why this matters for us:** when Islam benchmarks Bangunin's rating against "Alarmy," the honest bar is 4.8 with a quarter-million ratings, not 4.1.

### 1.2 Positioning and audience

**[Evidence]** Subtitle: "Heavy sleepers, Sleep tracker". Age rating 4+. Size ~233 MB. Latest version 26.31.1, updated 27 July 2026. Developer: Delight Room Co., Ltd. Source: App Store listing above.

**[Inference]** Alarmy has expanded well past "alarm" into a sleep-wellness suite (snore recording, sleep tracking, ASMR/white-noise libraries, bedtime reminders). The 233 MB binary is consistent with a large bundled audio library.

**[Bangunin decision]** We should *not* chase the sleep-tracking suite. Bangunin's edge is a focused, culturally-specific wake-up product. Competing on breadth against a 233 MB incumbent is a losing trade; competing on "the alarm that actually gets Indonesians out of bed, in Bahasa, with a mascot people like" is winnable. A small binary is itself a feature in Indonesia (see §6).

### 1.3 Missions / challenge presentation

**[Evidence]** Missions named in the listing description: math solving, memory games, shaking, squats, photo mission, QR/barcode scanning, voice alarms. Multiple missions can be chained on one alarm. Source: App Store listing above.

**[Evidence]** A secondary review states the free tier exposes 4 missions (Squat, Typing, Step, Photo) with the rest paywalled. Source: [alar.my blog — best alarm apps 2026](https://alar.my/en/blog/best-alarm-apps-2026-compared) (accessed 3 Aug 2026). Note this is the vendor's *own* blog and should be treated as marketing, not neutral review.

**[Inference]** The strategically important pattern is **mission chaining** — requiring two missions in sequence for genuinely heavy sleepers. Bangunin currently supports one mission per alarm.

**[Bangunin decision]** Mission chaining is a strong, non-protectable interaction concept and a credible premium differentiator. Worth considering, but *after* the reliability and verification work lands — chaining an unreliable mission just doubles the frustration.

### 1.4 Signature feature: Power Off Prevention

**[Evidence]** "Power Off Prevention & Anti-Snooze" is a headline bullet. Source: App Store listing above.

**[Inference]** On iOS this cannot literally prevent powering off the device. It is near-certainly a detection-and-penalty pattern (notice the app was killed / device restarted, then re-alert or mark the wake-up failed) rather than true prevention.

**[Bangunin decision]** **Do not imitate the naming.** "Power Off Prevention" on iOS is close to the line of claiming a capability the OS does not grant. Bangunin should describe what it actually does, in plain language. This is a *reason to differentiate on honesty*, which also happens to be our App Review risk mitigation.

### 1.5 Complaints (the most valuable section)

**[Evidence]** Recurring complaints across review aggregations: heavy paywalling of features; repeated prompts to rate the app; **alarms not firing as expected**; volume problems; subscription not recognised after reinstall. Sources: [alar.my comparison](https://alar.my/en/blog/best-alarm-apps-2026-compared), [App Store reviews page](https://apps.apple.com/us/app/alarmy-loud-alarm-clock/id1163786766?see-all=reviews) (accessed 3 Aug 2026).

**[Inference]** "Alarm didn't fire" against the category leader, in the AlarmKit era, is the single most damaging complaint an alarm app can carry. "Subscription not recognised after reinstall" is a Restore Purchases failure.

**[Bangunin decision]** Three direct product requirements fall out of this:
1. Reliability is the feature. Ship AlarmKit properly (Phase 3) — this is our chance to be *more* reliable than the leader, not just prettier.
2. Restore Purchases must be prominent, testable, and actually work. This is also an App Review checklist item.
3. Rate-prompt discipline: use `in_app_review` at most once, after a *successful* wake-up streak, never on launch, never repeatedly. Alarmy is actively losing stars on this.

### 1.6 Pricing structure

**[Evidence]** Many overlapping IAP tiers visible on the listing: "Premium Basic" $4.99, "Premium Light" $4.99, "Premium - Standard" $7.49, "Premium Standard" $59.99, "Alarmy Pro" $8.99 / $69.99. Secondary sources cite ~$7/month or ~$59/year with a 7-day trial. Sources as above.

**[Inference]** That tier list is a mess — near-duplicate names at different prices strongly suggest years of pricing experiments left visible on the listing. It is confusing to a shopper.

**[Bangunin decision]** Bangunin's two-SKU structure (`bangunin.premium.monthly` Rp49,000 / `bangunin.premium.yearly` Rp199,000) is *cleaner than the market leader's*. Keep it at two. Clarity is a competitive advantage here, and the yearly at Rp199,000 is a ~66% saving versus monthly — that's an honest number we can state without manufacturing urgency.

---

## 2. Competitor: Sleep Cycle

### 2.1 Positioning

**[Evidence]** Sleep-phase-aware "smart wake" tracker; App Store "App of the Day" and "Editors' Choice" recognition; ~4.6 App Store / ~4.5 Play rating; markets having analysed 3+ billion sleep sessions. Source: [liveworksleep — Sleep Cycle review 2026](https://liveworksleep.com/sleep-cycle-app-review/) (accessed 3 Aug 2026).

### 2.2 Interface and data visualisation

**[Evidence]** Reviewers describe the interface as more polished and its data visualisation more intuitive than direct competitors such as Pillow. Source: as above, and [apprundown sleep tracker rankings](https://apprundown.com/best/sleep-tracker-apps) (accessed 3 Aug 2026).

**[Inference]** Sleep Cycle's reputation rests substantially on *charts done well* — calm, legible, non-gamified data presentation. This is the strongest transferable lesson for Bangunin's Stats screen.

**[Bangunin decision]** Bangunin's stats/streak screen should aim for Sleep Cycle's *restraint*, not Duolingo's confetti. A wake-up history deserves a calm, well-typeset chart. This is compatible with keeping the mascot elsewhere in the app.

### 2.3 Complaints

**[Evidence]** Free tier progressively hollowed out, with sounds moved behind subscription; history/data paywalled — "subscription paywalls that hide the data the user actually came for"; alarm reliability failures; sleep stages that look randomly generated. Sources: [liveworksleep](https://liveworksleep.com/sleep-cycle-app-review/), [unstar.app ranking](https://unstar.app/blog/sleep-cycle-pillow-sleepscore-oura-calm-sleep-tracking-apps-ranked-2026) (accessed 3 Aug 2026).

**[Bangunin decision]** **Never paywall a user's own history.** If Bangunin records that you woke up on time for 30 days, that record is the user's, and locking it is the exact pattern earning Sleep Cycle its 1-star reviews. Paywall *capabilities* (advanced missions, mission chaining, custom sounds), never *the user's own data*.

---

## 3. Competitors: the challenge/puzzle cluster

Grouped because they share one design thesis: cognitive load as the dismissal gate.

### 3.1 Challenges Alarm Clock (`id1247289889`)

**[Evidence]** Mini-game dismissal; the app persists with notifications and vibration until the user opens it and plays a randomly selected mini-game; reported games include math problems and a "kitty bingo" game. Reviewers praise the difficulty calibration — "challenging enough to wake you up, but not too challenging that they become frustrating." Sources: [App Store listing](https://apps.apple.com/us/app/challenges-alarm-clock/id1247289889), [reviews page](https://apps.apple.com/us/app/challenges-alarm-clock/id1247289889?see-all=reviews&platform=ipad) (accessed 3 Aug 2026).

**[Inference]** The *randomly selected* mini-game is a deliberate anti-habituation mechanism: a mission you can complete on autopilot stops waking you after a few weeks. This is the sharpest insight in the whole competitive set.

**[Bangunin decision]** Bangunin should offer an optional **"Kejutan" (Surprise) mission mode** that randomises among the user's enabled missions. Habituation is the real long-term failure mode of mission alarms, and almost nobody addresses it. Original to us in execution; the underlying idea is not protectable.

### 3.2 I Can't Wake Up! Alarm Clock

**[Evidence]** Puzzle and math dismissal tasks over a chosen song. Documented in an occupational-therapy context as appropriate for people with difficulty waking, including individuals on the autism spectrum with sleep inertia. Sources: [MIOTA review PDF](https://www.miota.org/docs/I_Cant_Wake_Up.pdf), [AlternativeTo entry](https://alternativeto.net/software/i-can-t-wake-up-alarm-clock) (accessed 3 Aug 2026).

**[Inference]** This is the only competitor with evidence of *clinical/therapeutic* framing. It implies a real audience who needs a **non-physical, non-camera** dismissal path — and who may be poorly served by squats and photo hunts.

**[Bangunin decision]** This validates a requirement already in our brief: **every physical mission needs a safe non-exercise alternative**, and it should be framed as a legitimate equal option, not a "cheat" or a downgrade. Users with disabilities, injuries, small rooms, or shared bedrooms all need it. See §7.

### 3.3 WakeUp Challenge — Smart Alarm (`id6753803167`)

**[Evidence]** Positioned for "heavy sleepers who can't wake up with regular alarms"; math challenge to dismiss. Source: [App Store listing](https://apps.apple.com/us/app/wakeup-challenge-smart-alarm/id6753803167) (accessed 3 Aug 2026).

**[Inference]** A high app ID (`675…`) indicates a recent entrant — the category still has room, which is encouraging for Bangunin but also means the AlarmKit-native cohort is arriving now.

### 3.4 Wakey — Challenge Alarm Clock (`id1576452482`)

**[Evidence]** Listed with a public reviews page. Source: [App Store reviews](https://apps.apple.com/us/app/wakey-challenge-alarm-clock/id1576452482?see-all=reviews&platform=iphone) (accessed 3 Aug 2026). Not examined in depth.

---

## 4. The AlarmKit shift — the most important finding in this document

This changes the competitive landscape more than any visual design decision.

### 4.1 What Apple now permits

**[Evidence]** iOS 26 introduced **AlarmKit**, giving third-party apps alarm capabilities previously reserved for Apple's Clock app: alerts that fire **even in Silent Mode or an active Focus**, full-screen stop/snooze presentation, and Lock Screen / Dynamic Island / Apple Watch presence. Sources: [MacRumors — iOS 26 makes third-party alarm apps better](https://www.macrumors.com/2025/06/11/ios-26-third-party-alarm-apps/), [Apple: AlarmKit](https://developer.apple.com/documentation/AlarmKit), [WWDC25 session 230 "Wake up to the AlarmKit API"](https://developer.apple.com/videos/play/wwdc2025/230/) (accessed 3 Aug 2026).

**[Evidence — primary, verified locally]** I read the actual framework interface from the iOS 26.5 SDK installed on this machine, at:
`/Applications/Xcode.app/.../iPhoneOS.sdk/System/Library/Frameworks/AlarmKit.framework/Modules/AlarmKit.swiftmodule/arm64e-apple-ios.swiftinterface`

Confirmed API facts (these are ground truth, not blog claims):
- Everything is gated `@available(iOS 26.0, *)`; `macCatalyst` unavailable.
- `AlarmManager.shared` with `requestAuthorization() async throws -> AuthorizationState`, `authorizationState`, and an `authorizationUpdates` async sequence. `AuthorizationState` is `.notDetermined | .denied | .authorized`.
- Scheduling: `schedule(id:configuration:)`; control via `countdown(id:)`, `cancel(id:)`, `stop(id:)`, `pause(id:)`, `resume(id:)`.
- `Alarm.Schedule` is `.fixed(Date)` or `.relative(Relative)`, where `Relative` carries an hour/minute `Time` plus `Recurrence` of `.weekly([Locale.Weekday])` or `.never`.
- `Alarm.State` is `.scheduled | .countdown | .paused | .alerting`.
- `AlarmManager.AlarmError.maximumLimitReached` exists — **there is a cap on concurrent alarms** and we must handle it.
- `AlarmConfiguration` accepts `stopIntent` and `secondaryIntent`, both `AppIntents.LiveActivityIntent`, plus an `ActivityKit.AlertConfiguration.AlertSound`.
- **`AlarmAttributes` conforms to `ActivityKit.ActivityAttributes`** — so alarm presentation is Live Activity infrastructure and requires a **Widget Extension target**, which Bangunin does not currently have.
- `AlarmPresentation.Alert.init(title:secondaryButton:secondaryButtonBehavior:)` is the iOS 26.1+ initialiser; the older `stopButton:` variant is deprecated as of 26.1. `SecondaryButtonBehavior` is `.countdown` or `.custom`.

### 4.2 A widely-repeated falsehood, corrected

**[Evidence]** Multiple blog posts and at least one AI-generated skill registry state that AlarmKit "requires a special entitlement that you must request from Apple" via the Developer Portal. **This is false.**

On the Apple Developer Forums, a developer hit a build error demanding a `com.apple.developer.alarmkit` entitlement. An Apple engineer replied:

> "Did some LLM/AI put `com.apple.developer.alarmkit` there for you? I searched that entitlement on the web and the only result I got was this very forums post."

The developer confirmed an LLM had inserted it; removing it fixed the build immediately. Apple's engineer added a general warning about LLMs inventing non-existent entitlements. Source: [Apple Developer Forums thread 797950](https://developer.apple.com/forums/thread/797950) (accessed 3 Aug 2026).

**[Evidence — verified locally]** `grep -r "com.apple.developer.alarmkit"` across the entire Xcode 26.5 installation returns **zero matches**. The entitlement does not exist.

**Actual requirements:** `NSAlarmKitUsageDescription` in the host app's Info.plist, plus runtime authorization. Source: [Apple: NSAlarmKitUsageDescription](https://developer.apple.com/documentation/BundleResources/Information-Property-List/NSAlarmKitUsageDescription) (accessed 3 Aug 2026).

**Why this matters commercially:** there is **no Apple approval gate** and therefore **no external blocker** on Bangunin shipping real alarms. Anyone who believed the entitlement myth has been sitting on their hands.

### 4.3 Widget extension requirement

**[Evidence]** A widget extension is required if the app schedules anything with a `CountdownDuration`; without it the system may dismiss alarms and fail to alert. The Live Activity must be registered via an `ActivityConfiguration` over `AlarmAttributes` with the app's metadata type. Sources: [BleepingSwift — Scheduling Alarms with AlarmKit](https://bleepingswift.com/blog/scheduling-alarms-with-alarmkit), [Nil Coalescing — countdown timer with AlarmKit](https://nilcoalescing.com/blog/CountdownTimerWithAlarmKit/) (accessed 3 Aug 2026). Consistent with the `ActivityAttributes` conformance verified in §4.1.

**[Bangunin decision]** Bangunin must gain a Widget Extension target. Snooze maps naturally onto `CountdownDuration`, so this is not optional for us.

### 4.4 Competitive implication

**[Inference]** Alarmy's most damaging review theme is "the alarm didn't go off," and the whole category historically shared that weakness because notification-based alarms genuinely cannot override Silent Mode or Focus. AlarmKit removes that excuse. For roughly the next year, "actually rings, every time, verifiably" is an available and defensible position — and it is the *one* claim that matters most in this category.

**[Bangunin decision]** This is Bangunin's wedge. Phase 3 outranks all visual work. A beautiful alarm that doesn't ring is worthless; a plain alarm that always rings gets 5 stars.

---

## 5. Cross-cutting accessibility findings

**[Evidence]** The MIOTA occupational-therapy review of *I Can't Wake Up!* documents alarm apps being used by people with sleep inertia disorder and by individuals on the autism spectrum. Source: [MIOTA PDF](https://www.miota.org/docs/I_Cant_Wake_Up.pdf) (accessed 3 Aug 2026).

**[Inference]** I found **no** competitor marketing VoiceOver support, Dynamic Type support, or Reduce Motion support as a feature. Absence of evidence is not evidence of absence — I could not test the apps — but it does suggest accessibility is not a competitive battleground in this category.

**[Bangunin decision]** Accessibility is therefore cheap differentiation *and* the right thing to do. Specific requirements:
- A ringing screen is used by a barely-conscious person in the dark. It must survive the largest Dynamic Type sizes without clipping, and its controls must be large and unambiguous.
- Camera-based missions are unusable for blind users, and physical missions are unusable for some disabled users. The non-physical alternative is an accessibility requirement, not a convenience.
- Reduce Motion must suppress the pulsing/scaling ringing animation — a strobing full-screen animation at 6am is a genuine vestibular and photosensitivity concern.
- Never encode mission success/failure in colour alone.

---

## 6. Indonesia-specific considerations

**[Inference — flagged as lower-confidence, not from a cited source]** These follow from general knowledge of the Indonesian mobile market rather than from research I performed today, and should be validated before being used for major decisions:

- Mid-tier and older iPhones are common; a 233 MB binary like Alarmy's is a real download barrier on metered mobile data. Bangunin staying small is a genuine advantage worth protecting.
- Rp49,000/month is meaningfully more price-sensitive than a $7 US subscription in local purchasing terms; the yearly plan at Rp199,000 is the tier to make attractive, and the honest saving (~66%) is strong enough to state plainly without any countdown-timer theatrics.
- Bahasa Indonesia must be the *primary* voice, not a translation layer over English. "Bangunin" is itself colloquial and warm ("wake someone up") — the copy throughout should match that register rather than sounding like localised American SaaS.

**[Bangunin decision]** Copy is authored in Bahasa Indonesia first, then translated to English — not the reverse. See the design system doc for the copy-style rules.

---

## 7. Patterns Bangunin should learn from

| # | Pattern | Source | Bangunin application |
|---|---|---|---|
| 1 | Reliability is the product | Alarmy + Sleep Cycle complaint themes (§1.5, §2.3) | AlarmKit first, everything else second |
| 2 | Randomised missions prevent habituation | Challenges Alarm Clock (§3.1) | Optional "Kejutan" random-mission mode |
| 3 | Mission chaining for heavy sleepers | Alarmy (§1.3) | Candidate premium feature, after reliability |
| 4 | Calm, restrained data visualisation | Sleep Cycle (§2.2) | Stats screen — charts, not confetti |
| 5 | Never paywall the user's own history | Sleep Cycle complaints (§2.3) | Streaks/history always free |
| 6 | Rate-prompt discipline | Alarmy complaints (§1.5) | One prompt, after a genuine success, ever |
| 7 | Restore Purchases must actually work | Alarmy reinstall complaints (§1.5) | Prominent, tested, in settings and paywall |
| 8 | Non-physical dismissal path is a real need | I Can't Wake Up! (§3.2) | Equal-status alternative on every physical mission |
| 9 | Simple pricing beats tier sprawl | Alarmy's overlapping SKUs (§1.6) | Hold at exactly two SKUs |
| 10 | Accessibility is an open flank | §5 | VoiceOver, Dynamic Type, Reduce Motion done properly |

---

## 8. What Bangunin must NOT copy

Explicit prohibitions for everyone working on this branch:

1. **No competitor illustrations, mascots, icons, or animation curves.** The Bangunin rooster/chick is ours and stays ours. Do not reference any competitor character.
2. **No competitor marketing copy**, headlines, App Store description phrasing, or feature naming. Specifically **do not use "Power Off Prevention"** or close variants — it is Alarmy's distinctive naming and, worse, over-claims what iOS permits (§1.4).
3. **No pixel-level recreation** of any competitor screen, screenshot layout, or App Store screenshot template.
4. **No trade dress**: Alarmy's red identity is theirs. Bangunin's midnight-navy + electric-yellow is already differentiated and should stay.
5. **No copying of Sleep Cycle's chart designs** as artefacts — we take the *principle* of restraint, and draw our own.
6. **No dark patterns observed in the category**: repeated rate prompts, paywalled personal history, hollowed-out free tiers, near-duplicate confusing SKUs, fake countdowns, or hidden close buttons.
7. **No capability over-claiming.** We do not state or imply that the pre-iOS-26 fallback can override Silent Mode or Focus, force-launch the app, or guarantee delivery. This is both an honesty commitment and App Review protection.

---

## 9. Open questions for Islam

1. **Mission chaining** — worth building as a premium differentiator, or does it make the app feel punishing? My recommendation: defer until reliability and verification quality are proven.
2. **"Kejutan" random-mission mode** (§3.1) — I think this is the strongest original product idea to come out of this research. Want it in scope?
3. **Sleep tracking** — I recommend explicitly *not* competing here. Confirm you agree, so we can stop treating it as a gap.
4. Any market intelligence you have on Indonesian competitors? §6 is the weakest-sourced section in this document and I'd rather strengthen it with your knowledge than guess.

---

## Sources

- [App Store — Alarmy - Loud alarm clock (id1163786766)](https://apps.apple.com/us/app/alarmy-loud-alarm-clock/id1163786766) — accessed 3 Aug 2026
- [App Store — Alarmy reviews](https://apps.apple.com/us/app/alarmy-loud-alarm-clock/id1163786766?see-all=reviews) — accessed 3 Aug 2026
- [appshunter — Alarmy · Smart Alarm Clock (id1668848747)](https://appshunter.io/ios/app/alarmy-smart-alarm-clock/id1668848747) — accessed 3 Aug 2026
- [alar.my — Best Alarm App in 2026 (vendor blog, treat as marketing)](https://alar.my/en/blog/best-alarm-apps-2026-compared) — accessed 3 Aug 2026
- [liveworksleep — Sleep Cycle App Review 2026](https://liveworksleep.com/sleep-cycle-app-review/) — accessed 3 Aug 2026
- [unstar.app — sleep app rankings 2026](https://unstar.app/blog/sleep-cycle-pillow-sleepscore-oura-calm-sleep-tracking-apps-ranked-2026) — accessed 3 Aug 2026
- [apprundown — best sleep tracker apps](https://apprundown.com/best/sleep-tracker-apps) — accessed 3 Aug 2026
- [App Store — Challenges Alarm Clock](https://apps.apple.com/us/app/challenges-alarm-clock/id1247289889) — accessed 3 Aug 2026
- [App Store — WakeUp Challenge](https://apps.apple.com/us/app/wakeup-challenge-smart-alarm/id6753803167) — accessed 3 Aug 2026
- [App Store — Wakey Challenge Alarm Clock](https://apps.apple.com/us/app/wakey-challenge-alarm-clock/id1576452482?see-all=reviews&platform=iphone) — accessed 3 Aug 2026
- [MIOTA — I Can't Wake Up! review (PDF)](https://www.miota.org/docs/I_Cant_Wake_Up.pdf) — accessed 3 Aug 2026
- [AlternativeTo — I Can't Wake Up! alternatives](https://alternativeto.net/software/i-can-t-wake-up-alarm-clock) — accessed 3 Aug 2026
- [Apple Developer — AlarmKit](https://developer.apple.com/documentation/AlarmKit) — accessed 3 Aug 2026
- [Apple Developer — Scheduling an alarm with AlarmKit](https://developer.apple.com/documentation/AlarmKit/scheduling-an-alarm-with-alarmkit) — accessed 3 Aug 2026
- [Apple Developer — NSAlarmKitUsageDescription](https://developer.apple.com/documentation/BundleResources/Information-Property-List/NSAlarmKitUsageDescription) — accessed 3 Aug 2026
- [Apple Developer Forums — thread 797950 (entitlement myth debunked by Apple staff)](https://developer.apple.com/forums/thread/797950) — accessed 3 Aug 2026
- [WWDC25 Session 230 — Wake up to the AlarmKit API](https://developer.apple.com/videos/play/wwdc2025/230/) — accessed 3 Aug 2026
- [MacRumors — iOS 26 makes third-party alarm apps better](https://www.macrumors.com/2025/06/11/ios-26-third-party-alarm-apps/) — accessed 3 Aug 2026
- [BleepingSwift — Scheduling Alarms with AlarmKit](https://bleepingswift.com/blog/scheduling-alarms-with-alarmkit) — accessed 3 Aug 2026
- [Nil Coalescing — Schedule a countdown timer with AlarmKit](https://nilcoalescing.com/blog/CountdownTimerWithAlarmKit/) — accessed 3 Aug 2026
- iOS 26.5 SDK `AlarmKit.framework` swiftinterface, read locally from Xcode 26.5 (Build 17F42) — 3 Aug 2026
