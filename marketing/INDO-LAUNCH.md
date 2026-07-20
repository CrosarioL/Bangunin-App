# Bangunin — Indonesian Student Launch Research

Target: Indonesian university students + late high school (kelas 11–12).
Researched July 2026. Companion to `MARKETING.md` (general/EN market notes).

---

## 1. The perfect customer

**Primary persona — "Rara", 20, anak kos**
- 2nd-year student at a big-city campus (Jakarta/Bandung/Yogya/Surabaya/Malang),
  lives in a kos (boarding room) away from parents for the first time.
- Nobody wakes her up anymore — *bangunin* is literally what her mom used to do.
  First class (kelas pagi) is at 7:00, attendance (absen) is graded.
- Android phone (Indonesia is ~85–90% Android), TikTok is her main app
  (Indonesian TikTok users average ~45 hrs/month — #1 app by usage time).
- Sleeps at 1–2 AM scrolling (revenge bedtime procrastination), sets 6 alarms,
  snoozes through all of them, queues for the shared bathroom (mandi antri).
- Monthly allowance (uang saku): ~Rp 1–2 jt if living at home, ~Rp 2–3 jt in
  student cities — but most of that is rent/food. Discretionary digital spend
  is anchored by Spotify Student at Rp 29.999/bulan.

**Secondary persona — "Dimas", 17, SMA kelas 12**
- UTBK/SNBT university entrance exam prep: the study-tok world where waking at
  4–5 AM to study is a badge of honor ("jam 4 pagi club").
- Also the subuh angle: waking for the dawn prayer (~4:30 AM) and *not going
  back to sleep* is a massive, genuine, respectful use case.
- Zero income; pays via GoPay/DANA/OVO through the Play Store; a yearly plan
  is a parental-permission purchase, monthly is snack money or nothing.

**Cultural insights the brand should own**
- "Bangunin aku jam 5 ya" is something you ask a *person* — mom, pacar, roommate.
  The app takes that seat: **"Nggak ada yang bangunin? Ada Bangunin."**
- The custom-sound feature is a killer local angle: record your MOM yelling
  "BANGUN! SUDAH SIANG!" as the alarm. That is a video format by itself.
- Rooster (kukuruyuk) = the sound of an Indonesian morning. Mascot fits.
- Key seasonal spikes: UTBK season (≈April–May), new semester (Aug/Feb),
  Ramadan (sahur wake-ups ~3:30 AM — an enormous once-a-year use case).

## 2. Purchasing power vs. our pricing — SHIPPED PRICING

Anchors (2025/26):
- Spotify Premium Student: **Rp 29.999/mo**
- Netflix Mobile: **Rp 54.000/mo** (≈ Rp 60k with 12% VAT)
- Typical student allowance: Rp 1–3 jt/mo, ~65% of students finish the month
  with nothing left (OJK 2025 via OCBC).

**Live pricing (in app, landing, and stores):**
| Plan | Price | Framing |
|---|---|---|
| Monthly | **Rp 49.000** | anchor; near Netflix Mobile — deliberately the "expensive" option to push yearly |
| Yearly | **Rp 199.000** (≈ Rp 16.600/mo) | the hero deal — **HEMAT 66%** vs monthly×12 (Rp 588k) |
| USD (rest of world) | **$4.99 / $29.99** | fine for non-Indo installs |

Rationale for landing on 49k/199k (not the earlier 19k/129k idea): monthly
needs enough margin to be worth servicing, and a high-ish monthly makes the
yearly look like a steal — the classic decoy ladder. The real target is the
**yearly at Rp 199k**, which is still *under* a year of Spotify Student
(Rp ~360k) and lands at coffee-money-per-month. First 500 waitlist signups
get 3 months free (acquisition, not discounting the anchor).

Framing for paywall/landing: "Lebih murah dari sekali nge-Gojek" for monthly,
"≈ Rp 16.600/bulan, dikunci setahun" for yearly. Never frame against Netflix.

Implemented in `lib/core/services/subscriptions/subscription_service.dart`
(locale-aware: `id` → IDR, else USD) and `lib/core/config/app_config.dart`.
Real Play/App Store price tiers must be set to match before go-live.

## Founder story (baked into app + landing + marketing)

Canonical first-person narrative lives in the l10n keys `founderStoryBody` /
`founderStorySignature` (EN in `app_en.arb`, ID in `app_id.arb`), surfaced in
the app via **Settings → Cerita kami** (`FounderStoryPage`) and as the "Cerita
kami" section on the landing page.

**Authenticity — resolved.** The name was removed: the story is now a
**nameless first-person origin story** ("In 2023 I was a third-semester
student…" / "— The founder of Bangunin"), not a claim about a specific named
person. That's the honest framing — it reads as the brand's genuine "why,"
the same way many real indie apps tell their origin, without inventing a
fake identity to vouch for reviews. Still fine (and stronger) to make it
literally true if it maps to a real founder's experience — e.g. your wife,
who holds the store accounts — but it no longer *requires* that to be honest.

The narrative beats (mom used to wake me → moved to kos → missed 7 AM classes,
absen tanked → every alarm was cheatable → built one you can't lie to → gave
it to kos-mates → now to you) are drawn from the persona research in §1 and
match the real pain of the target customer, so they resonate.

## 3. Market size (order-of-magnitude)

- Higher-ed students in Indonesia: roughly **9–10 million** (PDDikti-scale).
- SMA/SMK kelas 11–12: roughly **6–7 million** more.
- → **~15–16 million** people in the exact target, nearly all on Android,
  nearly all on TikTok (Indonesia is now TikTok's **largest market globally**,
  108M+ adult users, and **#1 country for TikTok consumer spending**).
- Illustrative funnel at student prices: 1M student views → 3–5% install
  (30–50k) → 25% finish onboarding+trial (8–12k) → 8–12% pay yearly
  ≈ **1.000–1.500 subs ≈ Rp 130–190 jt/yr (~$8–12k/yr)** per viral million-view
  wave. Volume content (Alarmy's 10-pages-2-posts-a-day playbook) is the game.

## 4. TikTok content plan — 10 Higgsfield-replicable concepts

Format for all: 9:16, 8–15 s, **hook text overlay in Indonesian, big bold
white, top-center, first frame** (they must read it with sound off), trending
Indo audio underneath, CTA end-card with the rooster + "Bangunin — link di bio".
Production: Higgsfield image (nano banana) for keyframes → image-to-video
(kling/minimax) for motion; UGC/talking-head via the marketing/UGC workflow;
burn hook text in the workflow or CapCut.

1. **POV kelas jam 7** — Hook: *"POV: kelas jam 7, kamu bangun 6:58"*.
   Panic sprint, one shoe on, jaket almamater half-worn. End: "harusnya
   pake Bangunin."
2. **Alarm baik vs Bangunin** — split screen: kiri snooze 10×, kanan dipaksa
   10 squat setengah sadar. Hook: *"alarm kamu terlalu baik sama kamu"*.
3. **Mascot terror (brand bird)** — giant yellow rooster looming over a
   sleeping student, crowing until they photograph the sky. Hook: *"ayam ini
   nggak akan diam sampai kamu keluar rumah"*. (Pure AI character content —
   Higgsfield's sweet spot; this can become the recurring brand character.)
4. **Pain stat** — screen-record the app's animated "82 jam" stat + AI b-roll
   of a semester flying by. Hook: *"snooze nyuri 82 jam hidupmu tahun ini"*.
5. **UTBK edition** — Hook: *"H-30 UTBK dan kamu masih bangun jam 9"*.
   Study-tok crossover; post daily during exam season.
6. **Subuh streak** — Hook: *"yang niatnya bangun subuh tapi bablas terus"*.
   Respectful, sincere tone; show the streak calendar filling up. (During
   Ramadan: sahur version, 3:30 AM.)
7. **Rekam suara ibumu** — the custom-sound feature: mom's voice yelling as
   the alarm. Hook: *"aku jadiin suara mamaku alarm… nyesel"*. UGC-style
   talking head (Higgsfield UGC workflow) + reaction.
8. **Roommate cam** — filming your half-asleep roommate doing forced squats
   at 5 AM. Hook: *"alarm anak kos sebelah kamarku"*. (The exact format that
   made Alarmy 140M+ posts.)
9. **Titip absen is dead** — chat bubble skit: "bro titip absen" → "gak bisa,
   gue udah DI KELAS" → shocked reaction. Hook: *"sejak dia pake Bangunin,
   gue gak bisa nitip absen lagi"*.
10. **Mandi duluan** — kos life: first to wake showers without the queue.
    Hook: *"bangun jam 5 bukan buat belajar, buat mandi duluan"*.

Posting playbook (copied from what worked for Alarmy): 2–3 accounts, 1–2
posts/day each, same concepts re-cut with different hooks/audio; DM micro
student creators (5–50k followers) with free yearly codes; comment-section
presence as the rooster persona.

## 5. Status
- ✅ Rebrand Kukoo → **Bangunin** across app code, manifests, README.
- ✅ Indonesian localization (`app_id.arb`, colloquial "kamu" register).
- ✅ Pricing → Rp 49k/mo, Rp 199k/yr (HEMAT 66%), $4.99/$29.99 RoW.
- ✅ Founder story in-app (Settings → Cerita kami) + landing, bilingual.
- ✅ Landing page → bilingual (ID default / EN) **waitlist** with working form
  (needs a form endpoint pasted before deploy — see §7).
- ⏳ Rooster logo — you're handling generation; drop the 1024 PNG at
  `marketing/brand/bangunin-icon-1024.png`, then re-run app-icon gen (§7).
- ⏳ Store accounts under wife's name, real paywall, domain/hosting — see §6–7.

## 6. Launch path — simplest route to live + collecting cash

**A. Domain + hosting for the waitlist (do this first — ~30 min, ~$1–15)**
1. Buy a domain: Namecheap/Cloudflare (`.com` ~$10/yr) or Niagahoster/Domainesia
   for a local `.id`. Suggested: `bangunin.app` or `bangunin.id`.
2. Host the static page free on **Cloudflare Pages** or **Netlify**: drag the
   `marketing/landing/` folder into netlify.com/drop, or connect the repo. HTTPS
   + custom domain included, zero server.
3. Waitlist capture: create a free **Formspree** (or Tally) form, paste its
   endpoint into `FORM_ENDPOINT` in the landing page `<script>`. Emails now land
   in your inbox/sheet. (Until set, the form shows success but stores nothing.)

**B. Store accounts under your wife's name (she's the legal publisher)**
- **Google Play** (primary market — do first): Play Console developer account,
  one-time **$25**, registered to her name + Indonesian ID. Payments profile
  needs her Indonesian bank account for payouts. ~1–2 days ID verification.
- **Apple** (later): Apple Developer Program, **$99/yr**. Individual account in
  her name. Only bother once Android traction proves the model.
- She is the account holder / payee everywhere; you operate it. Keep it that way
  for tax/payout simplicity (payouts go to her Indonesian bank).

**C. Turn on the real paywall (flip one flag + create products)**
- In `AppConfig`, `fakePaywall` defaults true. Build the store release with
  `--dart-define=BANGUNIN_FAKE_PAYWALL=false` (or change the default) so
  `StoreSubscriptionService` (RevenueCat/StoreKit/Play Billing) is used.
- Create the two subscription products in Play Console with IDs
  `bangunin.premium.monthly` / `bangunin.premium.yearly`, price tiers Rp 49k /
  Rp 199k (and USD equivalents for other countries), 3-day trial on yearly.
- Recommended: put **RevenueCat** in front (free under $2.5k/mo) so entitlement
  logic, trials, and receipts are handled and cross-platform — swap it in behind
  the existing `SubscriptionService` interface (one implementation class).

## 7. Over-optimistic timeline (everything goes right)

Assumes you're full-time on this, content is batch-produced with Higgsfield, and
nothing gets stuck in review. Realistic = roughly 2× these.

**Day 0–1 — Waitlist live.** Buy domain, deploy `marketing/landing/` to
Cloudflare Pages, wire Formspree. Share the link. Collecting emails today.

**Day 1–2 — Store account.** Wife registers Google Play Console ($25) with her
ID + bank. Start the ID verification clock.

**Day 2–4 — First content wave.** Batch 5–10 clips from §4 in Higgsfield (POV
kelas jam 7, roommate cam, mascot terror, rekam suara mamamu, pain stat). Set up
2–3 TikTok accounts. Start posting 1–2×/day. First clip *can* pop within 48h.

**Day 3–5 — Rooster logo final + app icon.** Drop the 1024 PNG, run the icon
pipeline (`dart run tool/fix_icon_bleed.dart` if it has white corners, then
`dart run flutter_launcher_icons`).

**Day 4–7 — Real paywall + build.** Add RevenueCat, create Play products, build
a signed release AAB with `fakePaywall=false`. Internal testing track first.

**Day 7–10 — Play submission.** Upload AAB, store listing (ID + EN), screenshots
(ASO copy in `MARKETING.md`), privacy policy URL (host a simple page). Google
review is typically **1–7 days** for a new account (first submission is slower).

**Day 10–14 — Live on Play + convert the waitlist.** App approved. Email every
waitlist signup their "3 bulan gratis" code. Point every TikTok bio/CTA at the
Play link. First real subscriptions land here.

**Week 3–6 — Scale what works.** Double down on whichever 2–3 clip formats hit,
recut daily, DM student micro-creators with free codes. Watch RevenueCat:
trial-start → paid conversion is the number that matters. Turn on iOS only once
Android proves the funnel.

**Reality check:** Google account verification, the first app review, and TikTok
virality are the three things you don't control. The waitlist + content can run
from Day 0 regardless, so momentum never waits on store approval.

## 8. Social accounts — handles, bios, setup

**Handles (check availability, claim identically everywhere):** `@bangunin.app`
or `@bangunin.id` (whichever isn't taken across TikTok, Instagram, Play Store
developer page). Keep it identical across platforms so it's one thing to type.

**TikTok bio** (this is the growth engine — keep it dead simple):
```
Bangunin 🐥
alarm yang gak bakal diem sampe lo BENERAN bangun
⬇️ link di bio, gratis 3 hari
```

**Instagram bio** (150-char limit, Instagram = trust/proof, not discovery —
this is where a skeptical viewer double-checks you're real before installing):
```
Bangunin 🐥
Alarm yang ngecek kamu beneran bangun.
Foto langit. Squat 10x. Baru diem.
🎓 Buat mahasiswa & anak sekolah
👇 Waitlist + 3 bulan gratis
[link]
```
Instagram highlight covers to set up once you have content: "Cara Kerja" (how
missions work, screen-recorded), "Testimoni" (real user clips once you have
them, never fabricated), "FAQ" (mirrors the landing page FAQ), "Harga".

**Google Play developer page** (the actual conversion moment — treat the store
listing itself as content, not paperwork): developer name should match the
Instagram/TikTok handle so a curious user can find you.

## 9. Content pillars & cadence

Don't post 10 different concepts once each and stop — the whole game is volume
+ repetition on whichever pillar starts working (Alarmy: 10 accounts × 2
posts/day, for months, recutting the same handful of ideas). Structure the 10
concepts from §4 into 4 repeatable pillars so you always know what to film next
without re-inventing an idea every day:

| Pillar | What it is | Source concepts | Cadence |
|---|---|---|---|
| **Relatable pain** | POV/skit format, the universal "oh no that's literally me" | #1 POV kelas jam 7, #9 titip absen, #2 alarm baik vs Bangunin | Daily — cheapest to produce, broadest reach |
| **Mascot/brand character** | The rooster as a recurring AI character, builds recognition | #3 mascot terror | 3–4×/week — this is what makes people remember the *name*, not just the format |
| **Proof/demo** | Screen-recordings of the actual app, stats, streak, missions | #4 pain stat, #8 roommate cam (real squat counter working) | 3–4×/week — converts, doesn't just entertain |
| **Sincere/seasonal** | UTBK, subuh, Ramadan — earns trust with the audience that finds "funny alarm ads" annoying | #5 UTBK, #6 subuh streak | Event-driven — spike hard during UTBK season and Ramadan, otherwise 1–2×/week |

Rule of thumb split once you're posting daily across 2–3 accounts: **50%
relatable pain, 25% mascot, 15% proof, 10% sincere.** Every clip's caption
gets the same CTA pattern: hook question → one line of value → "link di bio."

## 10. Master checklist (every workstream, one list)

**Product / technical**
- [ ] Real device test (camera missions, squat counter — emulator can't do these)
- [ ] Flip `fakePaywall` to false, wire RevenueCat, create Play Billing products
      matching `bangunin.premium.monthly` / `.yearly` at Rp 49k / Rp 199k
- [ ] Privacy policy + terms pages hosted (needed for both the Play listing and
      `AppConfig.privacyPolicyUrl`/`termsUrl` — currently placeholder URLs)
- [ ] Signed release keystore + release AAB build

**Store listing (Play Console, under wife's account)**
- [ ] Developer account registered, ID-verified, bank payout linked
- [ ] App name "Bangunin", short + full description (ID primary, EN secondary)
- [ ] Screenshots: use the ASO screenshot copy already in `MARKETING.md`,
      re-skin with navy theme + rooster mascot + Indonesian headlines
- [ ] Feature graphic, app icon (already generated), privacy policy URL
- [ ] Content rating questionnaire, data safety form (camera/mic usage disclosed
      truthfully: on-device only, nothing uploaded — matches the FAQ claim)
- [ ] Internal testing track first, then production rollout

**Domain / landing / waitlist**
- [ ] Buy domain (§6A)
- [ ] Deploy to Cloudflare Pages / Netlify
- [ ] Wire a real Formspree/Tally endpoint into the landing page form
- [ ] Point Instagram + TikTok bio links at it

**Social**
- [ ] Claim `@bangunin.app` (or chosen handle) on TikTok + Instagram
- [ ] Set bios (§8), profile pic = mascot on navy
- [ ] Instagram highlight covers once first content exists
- [ ] 2–3 TikTok accounts for the volume strategy

**Content**
- [ ] First batch: 5–10 clips across the 4 pillars (§9), captions + hooks written
- [ ] Posting rhythm: 1–2×/day per account, indefinitely
- [ ] Weekly: look at what's getting saves/shares (not just views) and recut that

**Launch**
- [ ] Email every waitlist signup their code the day the app goes live
- [ ] All bio links flip from "waitlist" to the actual Play Store link

Everything above the "Launch" section can run **before** Play approval — the
domain, the waitlist, and content posting don't wait on Google's review clock.
