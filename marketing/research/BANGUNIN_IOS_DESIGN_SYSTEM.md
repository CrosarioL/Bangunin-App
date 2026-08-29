# Bangunin iOS Design System

**Date:** 4 August 2026 · **Branch:** `agent/ios-alarm-ux-overhaul`
**Companions:** [competitor research](./IOS_COMPETITOR_UX_RESEARCH.md) · [audit](./BANGUNIN_IOS_AUDIT.md)

---

## 0. Design position

Bangunin keeps its personality — midnight-navy night sky, electric yellow, the crowing rooster, the chunky physical buttons — but stops fighting iOS. The current kit is Duolingo-flavoured Material. The target is **the same warmth, expressed in a way that feels native to iPhone.**

Three principles, in priority order:

1. **Calm over noise.** From the research: Sleep Cycle earns its reputation on restraint, and the whole challenge-alarm category loses trust through clutter and fake urgency. An alarm app is used by someone barely conscious. Every screen should be legible at 5am with one eye open.
2. **The mascot is a host, not wallpaper.** The rooster belongs on emotional beats (empty state, success, ringing, onboarding). It does **not** belong on functional screens where it competes with the thing the user came to do.
3. **Never imply a capability we don't have.** This is a design constraint, not just a copy one — see §11.

### What we deliberately keep

The chunky "lip" buttons and hard-offset cards are genuinely distinctive and not something competitors own. They stay. What changes is **restraint in how often they appear** — a screen where everything is chunky has no hierarchy.

---

## 1. Colour tokens

Existing palette is good and stays. Contrast measured against WCAG AA (4.5:1 body, 3:1 large text ≥24px or ≥19px bold).

### Dark (primary)

| Token | Hex | Use | Contrast on `background` |
|---|---|---|---|
| `background` | `#0E1630` | App canvas | — |
| `surface` | `#16204A` | Cards | — |
| `surfaceRaised` | `#1E2B5C` | Inputs, sheets, pressed states | — |
| `outline` | `#34407A` | Hairlines, dividers | 2.0:1 — **decorative only, never text** |
| `primary` | `#FFD60A` | Accent, CTA fill, countdown | **13.4:1** ✅ |
| `primaryDeep` | `#FFA000` | Gradient end, streak flame | 8.4:1 ✅ |
| `onPrimary` | `#201900` | Text **on** yellow | 13.0:1 on primary ✅ |
| `textPrimary` | `#F4F5F8` | Body, headings | **15.5:1** ✅ |
| `textSecondary` | `#9BA1B0` | Supporting copy | **6.4:1** ✅ |
| `textTertiary` | `#5E6472` | Disabled only | 2.6:1 ❌ — **never for readable text** |
| `success` | `#4CD97B` | Rep counted, mission passed | 9.5:1 ✅ |
| `danger` | `#FF5D5D` | Destructive, verification failure | 5.6:1 ✅ |
| `info` | `#6C8CFF` | Informational, capability notices | 5.8:1 ✅ |

> Figures are computed from the token hexes; re-verify with a contrast checker before store submission rather than trusting them blind.

**Rules**
- `textTertiary` and `outline` are **decorative**. Any text using them is a bug.
- Never encode state in colour alone — always pair with an icon or text (§8).
- Yellow is the accent, not a background for long text. Yellow surfaces carry `onPrimary` only.

### Light

Existing light tokens stay (`backgroundLight #AEB6D4`, `surfaceLight #FFFFFF`, `textPrimaryLight #15171E`). The slate-blue canvas is a deliberate, non-generic choice — keep it. Yellow on white is **2.0:1 and unusable for text**: in light mode, yellow is fill-only, with `onPrimary` text on top.

---

## 2. Typography and Dynamic Type

Two families, unchanged: **Baloo2** (display/headings — the personality) and **Nunito** (body/UI — the legibility).

| Role | Family | Size | Weight | Use |
|---|---|---|---|---|
| `displayLarge` | Baloo2 | 72 | 800 | Ringing clock only |
| `headlineMedium` | Baloo2 | 28 | 800 | Screen titles |
| `titleMedium` | Nunito | 18 | 700 | Card titles, list rows |
| `bodyLarge` | Nunito | 16 | 500 | Primary body |
| `bodyMedium` | Nunito | 14 | 500 | Supporting |
| `labelSmall` | Nunito | 12 | 700 | Overline, all-caps |

### Dynamic Type rules

The audit found the ringing screen will clip at large sizes — the single worst place to lose content.

- **Never** use `MediaQuery.textScalerOf(context).scale()` with a hard cap of 1.0. Users choose large text for a reason.
- Clamp only where the layout genuinely cannot flex, and clamp generously: `TextScaler.linear(scale.clamp(1.0, 1.6))` on the 72pt ringing clock **only**.
- Every screen must survive **AX5** (≈3.1×) without clipping. Achieved by: scrollable bodies, `Flexible`/`Expanded` over fixed `SizedBox` heights, `maxLines` + `TextOverflow.ellipsis` only on genuinely truncatable labels — never on instructions or error text.
- Buttons grow with text. Fixed-height buttons are banned; use `minHeight` (44) instead.
- The ringing screen must remain usable at AX5 with **stop and snooze both reachable** — if something must give, the mascot goes first.

---

## 3. Spacing and radii

The 4pt rhythm in `AppSpacing` is already correct and stays: `xs 4 · sm 8 · md 12 · lg 16 · xl 24 · xxl 32 · xxxl 48`.

Radii stay too (`radiusCard 20`, `radiusControl 16`, `radiusButton 16`, `radiusCapsule 100`), as do the signature depth tokens `buttonLip 5` / `cardLip 4`.

**New rule — depth budget:** at most **one** lipped element per visual group. A card containing a lipped button does not itself get a lip. Stacked chunk-on-chunk is what currently reads as "toy" rather than "warm".

---

## 4. Components

| Component | Spec |
|---|---|
| **Card** (`AppCard`) | `surface`, `radiusCard`, `cardLip` hard offset, `lg` internal padding. No blur shadows anywhere. |
| **Primary button** | Yellow fill, `onPrimary` text, `buttonLip`, min height 44, full-width on action screens. One per screen. |
| **Secondary button** | `surfaceRaised` fill, `textPrimary`, no lip. |
| **Text button** | No fill. Used for snooze, cancel, "not now". |
| **Toggle** | iOS-style `CupertinoSwitch` tinted `primary`. Alarm on/off is the app's most-used control and should feel like the system one. |
| **Segmented control** | `CupertinoSlidingSegmentedControl` on `surfaceRaised`. For repeat-mode and mission-category pickers. |
| **Sheet** | `showModalBottomSheet`, `radiusCard` top corners, grabber, `surface`. Sheets are the default for pickers (sound, mission, repeat) — they keep context, unlike full pages. |
| **Dialog** | Reserve for destructive confirmation only (delete alarm). Everything else is a sheet. |
| **List row** | 44pt min height, leading SF Symbol, trailing value + chevron. |

---

## 5. Icons

**SF Symbols wherever a system concept exists** — they carry weight, scale with Dynamic Type, and read as native.

| Concept | Symbol |
|---|---|
| Alarm | `alarm` / `alarm.fill` |
| Add alarm | `plus` |
| Snooze | `zzz` |
| Stop / dismiss | `stop.circle.fill` |
| Mission (movement) | `figure.run` |
| Mission (camera) | `camera.viewfinder` |
| Streak | `flame.fill` |
| Stats | `chart.bar.fill` |
| Settings | `gearshape` |
| Premium | `crown.fill` |
| Real alarm active | `bell.badge.fill` |
| Fallback mode | `bell.slash` |
| Verification failed | `eye.slash` |

Custom art is reserved for the mascot and mission illustrations. Bangunin does not draw its own gear icon.

---

## 6. Mascot usage

The rooster is the brand. It is also the fastest way to make a functional screen feel unserious.

**Yes:**
- Onboarding (the guide)
- Empty state (sleeping, tap-to-crow easter egg — keep it, it's charming)
- Ringing screen (crowing — this is the one screen where drama is correct)
- Wake success (celebrating)
- Paywall header

**No:**
- Alarm list rows
- Alarm editor
- Settings
- Stats charts
- Mid-mission (it competes with the camera guide the user needs)

**Home hero card:** currently 76pt beside the countdown. Keep, at reduced prominence — the countdown is the information; the rooster is the greeting.

**Semantics:** every decorative instance wrapped in `ExcludeSemantics`. The interactive empty-state one gets a real label.

---

## 7. Motion and haptics

| Event | Motion | Haptic |
|---|---|---|
| Screen transition | iOS default push | — |
| Toggle alarm | — | `selection` |
| Rep counted | Ring tick 350ms `easeOutCubic` | `tap` |
| Mission passed | Scale-in 400ms | `success` |
| Verification failed | 200ms shake | `warning` |
| Delete | — | `warning` |
| Ringing | Slow 1.4s pulse | System alarm handles it |

### Reduce Motion (mandatory)

The audit flagged this as a real accessibility problem: the ringing screen runs a repeating full-screen opacity+scale pulse with no check. A strobing animation aimed at someone half-awake in a dark room is a genuine vestibular and photosensitivity concern.

- When `MediaQuery.disableAnimationsOf(context)` is true: **no looping animations at all.** The ringing mascot renders static.
- Transitions become cross-fades.
- Progress still animates (it conveys information), but at reduced amplitude.

---

## 8. States

Every interactive surface defines all five. No screen ships with only its happy path.

| State | Treatment |
|---|---|
| **Empty** | Mascot + one line of what to do + primary action. Never a bare "No data". |
| **Loading** | Skeletons matching final layout for lists; spinner only for <1s waits. |
| **Disabled** | 38% opacity, `textTertiary`, and the control must explain *why* it's disabled if not obvious. |
| **Success** | Green + `checkmark.circle.fill` + text. Never colour alone. |
| **Failure** | `danger` + `eye.slash`/`exclamationmark` + **a specific, actionable reason** + a retry path. Never a bare "Failed". |

---

## 9. Camera mission visual language

One consistent frame across all camera missions:

1. **Setup line** (top): one sentence, plus the safety note for exercise missions. Localised — no inline ternaries.
2. **Live preview** (centre): `radiusCard` clipped, maximum available height.
3. **Guidance banner** (below preview): the live coaching line. Tracking problems get `danger` + `eye.slash`; ordinary prompts stay quiet. Announced politely to VoiceOver, never interrupting.
4. **Progress** (bottom): rep ring, or capture button.
5. **Escape**: back always abandons to the ringing screen — never traps the user.

**Permission denial** is a first-class screen, not a snackbar: what we need, why, and a button straight to Settings.

**Failure copy is hedged by design.** "We couldn't verify that" — never "that is not grass". The checks are heuristics (see [model evaluation](./MISSION_MODEL_EVALUATION.md)); the copy must not overstate them.

**Accessibility:** camera missions are unusable for blind users and some disabled users. Every physical/camera mission needs an equal-status alternative, presented as a legitimate choice — never framed as a downgrade or a cheat.

---

## 10. Ringing screen

The most important screen in the app, and the one used under the worst conditions.

- Clock is the largest element. Everything else is secondary.
- **Two actions maximum**: the mission/dismiss primary, and snooze as a text button. No third choice at 5am.
- Snooze shows remaining count — a shrinking number is honest pressure, unlike a fake countdown.
- Must survive AX5 with both actions reachable (§2).
- Reduce Motion kills the pulse (§7).
- Under AlarmKit, the system alert comes first; this screen is what the mission button opens into.

---

## 11. Capability disclosure

Design requirement flowing from the brief's honesty constraints. The user must be able to tell which engine is running, without being frightened.

| Engine | Treatment |
|---|---|
| **AlarmKit active** | Quiet `bell.badge.fill` + "Rings even on silent" in the home header. Stated once, calmly. |
| **Notification fallback** | `info`-tinted row (never `danger` — this is not an error): "Alarms use notifications on this iPhone. They won't ring in Silent Mode or Focus." Plus a "Why?" link. |
| **Authorization not yet asked** | Education screen *before* the system prompt, explaining what we're asking for and why. Never prompt cold. |
| **Denied** | Same as fallback, plus a path to Settings. No nagging, no repeat prompts. |

**Banned:** anything implying the fallback can override Silent Mode or Focus, force-launch the app, or guarantee delivery.

---

## 12. Paywall hierarchy

Per the research, the category's paywalls are where trust is lost.

1. Headline — personalised where a name exists
2. Goal line (their chosen wake time) — relevance, not pressure
3. Four feature bullets, benefit-led
4. **Yearly first** (anchor, "PALING HEMAT"), monthly below
5. Trial timeline **only when the store reports a real offer**
6. Single CTA: `paywallCtaTrial` or `paywallCtaNoTrial` — driven by actual eligibility
7. Restore Purchases — visible, not buried
8. Legal: renewal terms, Privacy, Terms

**Banned outright:** countdown timers, fake scarcity, hidden/delayed close, pre-checked consent, guaranteed-trial wording for ineligible users, and paywalling the user's own history (the exact complaint sinking Sleep Cycle's reviews).

---

## 13. Copy style — Indonesian first

**Author in Bahasa Indonesia, then translate to English.** Not the reverse. "Bangunin" is itself colloquial and warm; the copy should match that register, not sound like localised American SaaS.

| Do | Don't |
|---|---|
| "Bangun, udah siang!" | "Your alarm has been activated" |
| "Belum bisa kami pastikan" | "Verification failed" |
| "Mundur sedikit biar tangan kelihatan" | "Error: landmarks not detected" |
| Second person, casual (`kamu`) | Formal `Anda` |
| Say what to do next | Say what went wrong and stop |

- No exclamation marks in error states.
- No blame ("you failed") — the app couldn't verify, that's on us.
- Never guilt the user for snoozing.
- **Every user-facing string goes through ARB.** Inline `isIndonesian ? … : …` ternaries are a bug — three were found and fixed on this branch.

---

## 14. Implementation status

| Area | Status |
|---|---|
| Colour tokens | ✅ Exist, documented, contrast recorded |
| Spacing/radii | ✅ Exist and correct |
| Typography scale | ✅ Exists · ⬜ Dynamic Type audit outstanding |
| Guidance banner (§9) | ✅ Built |
| Hedged failure copy (§8, §9) | ✅ Built |
| Indonesian-first ARB discipline (§13) | ✅ 3 violations fixed |
| Reduce Motion (§7) | ⬜ **Outstanding — accessibility bug** |
| Dynamic Type on ringing (§2) | ⬜ **Outstanding — clipping risk** |
| SF Symbols pass (§5) | ⬜ Outstanding |
| Cupertino toggle/segmented (§4) | ⬜ Outstanding |
| Capability disclosure (§11) | ⬜ Outstanding — blocked on nothing, next up |
| Mascot semantics (§6) | ⬜ Outstanding |
