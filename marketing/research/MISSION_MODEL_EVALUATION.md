# Mission Verification — Bundled-Model Evaluation

**Date:** 4 August 2026 (updated same day with probe results)
**Status:** ✅ **RESOLVED — Apple Vision is sufficient. No bundled model needed. Implemented and shipped on this branch.**
**Requested by:** Phase 4 of the iOS overhaul brief — *"If a robust hand/grass model would require a new bundled model, document its source, license, size, accuracy limitations and App Store impact before adding it."*

---

## ⭐ Outcome (read this first)

Islam approved the Apple Vision probe. It was run and **it answered the question decisively: Option B (bundling a classifier) is unnecessary.**

`VNClassifyImageRequest` exposes its taxonomy programmatically, so the probe needed no device — Vision ships on macOS too, and `knownClassifications(forRevision:)` was queried directly. **1,303 labels**, including everything the missions need:

| Mission | Labels found |
|---|---|
| Touch Grass | `grass` ✅ · plus `foliage`, `garden`, `plant` as supporting |
| Make Your Bed | `bed`, `bedding`, `bedroom`, `pillow` ✅ |
| Sky Photo | `sky`, `blue_sky`, `night_sky`, `cloudy` ✅ |

Notably absent: `lawn`, `turf`, `meadow`, `soil`, `mattress`, `duvet`, `quilt`, `blanket` — so the label sets above are the complete usable vocabulary and should not be padded with guesses.

**Confirmed empirically after implementing:** the release `.app` is **74.2 MB before and after** adding Vision. 0 MB, as predicted.

**What shipped:** `ios/Runner/VisionBridge.swift` (classification + `VNDetectHumanHandPoseRequest`) and `lib/features/missions/data/scene_classifier.dart`, wired into `PhotoMissionVerifier`. Hand detection means Touch Grass now requires a hand in frame — recognising a lawn through a window is not touching it.

**Combination policy** (13 tests): Vision positive → pass even where the heuristic was marginal (prevents rejecting someone on real grass in poor light — the worst possible failure). Vision negative → fail even where the heuristic passed (catches the busy green rug). Vision silent or unavailable → defer to the heuristic; silence is not a rejection. Android is unaffected and keeps heuristics.

**Still outstanding:** the calibration set in §2.1. `supportingConfidence = 0.35` is a starting value, not a validated one.

---

## 1. The question

Can Bangunin verify "you are actually touching grass" / "you actually made your bed" with pixel heuristics, or does it need a real model?

**Short answer: heuristics cannot do it, and I have stopped short of pretending otherwise.**

What shipped on this branch is a substantially harder-to-cheat version of the old heuristics plus honest failure wording. What it is *not* is grass detection.

---

## 2. What the heuristics now do, and where they stop

| Mission | Old behaviour | Now | Still defeated by |
|---|---|---|---|
| Touch Grass | `green pixels > 35%` | green ratio **+ fine-scale texture**, multi-frame liveness available | a busy green rug, a leafy houseplant, dense foliage that isn't a lawn |
| Sky Photo | bright **or** blue → pass (a white ceiling passed) | blue dominance, **or** overcast *plus* brightening toward the top | shooting up at a bright window; a large pale gradient wall |
| Make Your Bed | brightness + edges + L/R symmetry | exposure band + structure band | any similarly-textured surface: a rug, a sofa, a curtain |
| Object Hunt | 1 global 64-bin histogram, cosine > 0.60 | **3×3 grid** of local histograms, median > 0.80 | a deliberate re-shoot of the reference photo on a screen |

### 2.1 A calibration warning that matters

The thresholds above (grass texture `6.0`, bed texture `5.0`–`45.0`, object median `0.80`, liveness `0.9`–`60.0`) are **starting values chosen against synthetic fixtures, not against real photographs.** They are not validated.

While building the tests I hit this directly: a hue-spread gate was implemented, then **removed**, because tuning it would have meant fitting a number to a fixture I had invented myself. That is circular — it would have produced green test ticks and told us nothing about grass.

Two empirical findings from that work, worth keeping:

- The verifier downsamples to 128px before measuring texture. **Per-pixel noise does not survive that resize** (measured contrast collapsed from 23.8 to ~2.4 as fixture detail got coarser). Only detail at blade/clump scale survives — which is the right thing to measure, but it means capture-resolution sharpness is irrelevant.
- **A 1-pixel frame shift is invisible after downsampling** (liveness delta measured 0.00). Liveness therefore only detects movement of roughly 2px or more at analysis scale. Genuine hand shake clears this; a phone on a tripod pointed at a printed photo might not.

**Required before launch:** capture ~30 real photos per mission on a real iPhone (grass in morning light, grass in shade, wet grass, a green rug, a green shirt, a houseplant; a made bed, an unmade bed, a rug, a wall) and re-fit these numbers. Until that happens the honest description is "rejects the obvious cheats", nothing stronger.

---

## 3. Option A — Apple Vision (recommended first step)

**Source:** Apple's own `Vision` framework. Already on every supported device.

| | |
|---|---|
| **Licence** | Apple SDK — no third-party licence, no attribution |
| **Binary size added** | **0 MB** — system framework, nothing bundled |
| **Runs** | Fully on-device |
| **Network** | None |
| **App Store impact** | None. No new privacy-manifest entries beyond the camera use already declared |
| **Min iOS** | Most relevant requests are iOS 14+; hand pose is iOS 14+ |

**Relevant capabilities:**

- `VNDetectHumanHandPoseRequest` — detects hands and 21 joints per hand. This directly addresses the brief's "a visible hand approaching or contacting the detected surface", which the current implementation does not attempt at all.
- `VNGenerateAttentionBasedSaliencyImageRequest` — where the visually interesting region is; useful to confirm the subject is the surface rather than a distant object.
- `VNClassifyImageRequest` — Apple's built-in classifier over a large taxonomy. **Worth checking whether it emits usable labels such as `grass`, `lawn`, `plant`, `bed`, `bedroom`.** If it does, this is the entire problem solved for 0 MB and no licensing.

**Why this is the right first move:** it costs nothing in binary size, nothing in licensing, nothing in review risk, and the hand-pose piece is a capability the heuristics fundamentally cannot replicate. It should be exhausted before anything is bundled.

**Unknown I could not resolve here:** the exact label set of `VNClassifyImageRequest` on iOS 26.5. That needs a 20-line Swift probe on a real device. **This is the single highest-value next experiment**, and it may make Option B unnecessary.

**Android note:** Vision is iOS-only. Android would need ML Kit Image Labeling (already a Google dependency family the project uses for pose). Any design here must keep the two platforms behind one Dart interface.

---

## 4. Option B — a bundled classifier (only if Option A falls short)

Candidates, in rough order of practicality. **None of these has been added, and I have not independently verified the licence text or measured the converted size — those must be confirmed before adoption.**

| Model | Typical size (quantised Core ML) | Licence (verify before use) | Notes |
|---|---|---|---|
| MobileNetV3-Small (ImageNet-1k) | ~2–4 MB | Apache 2.0 (TF/Keras weights) | ImageNet has fine-grained classes but "lawn/grass" coverage is patchy; "bed" and "quilt" exist |
| MobileNetV2 (Apple's Core ML gallery build) | ~5–9 MB | Check Apple's model-gallery terms | Easiest Core ML path, no conversion work |
| EfficientNet-Lite0 | ~4–6 MB | Apache 2.0 | Better accuracy per MB, more conversion effort |
| Places365-trained ResNet18 | ~40–45 MB | **MIT for code; the Places365 *dataset* has research-oriented terms — legal check required** | Scene-level ("lawn", "bedroom") which fits our missions far better than object-level ImageNet |
| Custom Create ML classifier | ~1–3 MB | Ours outright | Needs a few hundred labelled photos per class. Highest quality for *our* exact task, and the only option with no third-party licence question |

### 4.1 App Store impact of bundling

- **Size.** Bangunin's advantage over Alarmy is partly that it is small — Alarmy is ~233 MB and that is a genuine barrier on Indonesian mobile data. Adding 2–9 MB is defensible; adding 45 MB starts eroding a real competitive edge.
- **Review.** A bundled, on-device model with no network access adds no meaningful review risk, and no privacy-manifest change (no data collection, no tracking).
- **Honesty.** A classifier raises confidence; it does not create certainty. The hedged wording must stay either way.
- **Export compliance.** Unchanged — no new cryptography.

### 4.2 My recommendation

1. **Run the Vision probe first** (§3). It is a day's work and may close the whole question for 0 MB.
2. If Vision's labels are insufficient, prefer a **custom Create ML classifier** over a general ImageNet model. Our task is narrow — grass / not-grass, made-bed / not-made-bed — and a small purpose-trained model on a few hundred photos will beat a general 1000-class model at a fraction of the size, with no licence ambiguity.
3. Treat Places365 as a last resort purely because of the dataset-terms question.

---

## 5. What I am NOT proposing

Ruled out explicitly, in line with the brief:

- ❌ **No cloud vision API.** Frames must never leave the device. This is a hard product constraint, not a preference.
- ❌ **No model downloaded at runtime.** The brief forbids it, and it would also break offline wake-ups — the exact moment the app must work.
- ❌ **No claim of certainty.** Whatever ships, the copy stays "we couldn't verify…", never "that is not grass".
- ❌ **No gallery imports as attempts.** Live capture only.

---

## 6. Decisions

1. ~~**Approve the Vision probe?**~~ ✅ **Approved and done.** Result in the Outcome section — Vision has the labels, at 0 MB.
2. ~~**Bundle a model?**~~ ❌ **No longer necessary.** §4 is retained only as a record of what was considered. Given the binary is already 74 MB (ML Kit pose dominates), a 45 MB Places365 model would have been a bad trade regardless.
3. **Custom Create ML classifier** — no longer needed for basic function, but still the best path if real-world accuracy proves disappointing. Parked.
4. **Real-photo calibration set (§2.1) — still needed, still open.** ~30 real photos per mission on a real iPhone. This tunes both the heuristic thresholds and `supportingConfidence`. It does not block the code, but it does block confidence in the numbers.

---

## 7. Interim position

Until one of the above is chosen, the shipped behaviour is:

- Obvious cheats rejected (flat green surfaces, white ceilings, blank walls, same-room-different-angle object shots, identical burst frames).
- Specific, actionable, hedged failure messages instead of a bare "failed".
- Thresholds documented in code as **uncalibrated**, with a pointer to this file.

That is a real improvement on "count the green pixels" and it is honestly labelled. It is not grass detection, and nothing in the UI or store listing should imply that it is.
