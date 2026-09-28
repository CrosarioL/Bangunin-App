# Apply for production: draft answers

Play Console > Dashboard > **Apply for production**. Google asks three groups
of questions. Answers below are drafts: everything in **[brackets]** needs a
real fact from you, and anything about tester feedback must describe feedback
you actually received. Google reads these against your closed-test data, so
invented detail hurts more than a short honest answer.

## 1. About your closed test

**How did you recruit users for your closed test?**
Pick: *Paid testing service* (plus *Friends and family* if any of the 12 were
people you know).

**How easy was it to recruit testers?**
Pick the honest option. With a paid service, usually *Easy*.

**Describe the engagement you received from testers during your closed test.**
> [N] testers stayed opted in for [14+] continuous days on [devices, e.g.
> Samsung, Xiaomi, Oppo, Pixel] running Android [versions]. Testers set daily
> alarms and completed wake-up missions ([which ones: photo missions,
> squats...]), across locked-screen, silent-mode and battery-saver
> conditions. [Any numbers you have: alarms rung, sessions per tester, crash
> count from Play Console > Android vitals.]

**Provide a summary of the feedback you received from testers, and how you
collected it.**
> Feedback came through [the testing service's reports / Play private
> feedback / hello@bangunin.app]. The main themes were: [1. …] [2. …]
> [3. …].

(Only list themes testers actually raised.)

## 2. About your app

**Who is the intended audience?**
> Adults and older teens (18+ primary, 13+ allowed) who struggle to get out
> of bed on time: students with early classes, workers with fixed start
> times, and people waking for sahur in Ramadan. Launching in Indonesia
> first, in Indonesian and English.

**Describe how your app provides value to users.**
> Bangunin is an alarm clock that won't stop until you prove you're awake.
> Instead of a snooze button, each alarm has a wake-up mission: find a
> random household object with the camera, solve maths problems, shake the
> phone, do squats, or photograph the morning sky. Missions can be chained,
> and an optional Wake Up Check re-rings the alarm if you fall back asleep.
> Everything runs on the device; no photos or data leave the phone. Alarms
> use exact scheduling and a full-screen alarm so they ring reliably with
> the app closed.

**How many installs do you expect in your first year?**
Pick the range that matches your plan (the marketing plan targets Indonesian
TikTok growth; *10,000 - 100,000* is a reasonable, defensible choice).

## 3. Production readiness

**What changes did you make to your app based on what you learned during
closed testing?**
Changes shipped in 1.0.1 (+4), for reference. Only present an item as
"based on testing" if it was:
> - Rebuilt onboarding so new users set up their first alarm (time, sound,
>   mission) in under a minute instead of answering a survey.
> - Added missions that need no setup: Random Object Hunt, Math and Shake.
> - Added an Emergency Escape for genuine emergencies, so a hard mission
>   never traps a user.
> - Added Wake Up Check and chained missions for heavy sleepers.
> - Reliability: [any alarm/notification fixes you made after test reports].
> - Made trial terms clearer on the paywall.

**How did you decide that your app is ready for production?**
> Testers completed [14+] days of daily use on a range of Android devices
> with [no/N] crashes or ANRs in Android vitals. Core alarm reliability
> (locked screen, silent mode, reboot, battery saver) was verified on
> [devices], and every mission was completed end to end. [Anything else.]

## Before submitting

- Upload `app-release.aab` (1.0.1, build 4) to the closed track first so
  the latest build is what reviewers see.
- Paste the updated exact-alarm justification from PLAY_CONSOLE_ANSWERS.md
  into App content > Permissions.
- Screenshots: the store listing should show the current UI (carousels,
  meme alarms) if the old screenshots look different.
