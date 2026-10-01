# App Review notes

Paste into App Store Connect → version → App Review Information → Notes.

---

Bangunin is a user-scheduled alarm clock: an alarm stops only after the user completes a short wake-up mission (photo, object hunt, math, shake, squats or push-ups).

Quick test (about 3 minutes):
1. Complete onboarding. On the permissions step, allow notifications and Alarms (iOS 26 AlarmKit prompt).
2. On the paywall, start the 3-day free trial with your sandbox account (Premium is sold only through In-App Purchase; there is no code or other unlock).
3. Create an alarm two minutes ahead with the Math or Shake mission (no camera needed), then lock the iPhone.
4. The system alarm appears. Tap "Mulai misi" / "Start mission" (or slide to stop; both open the mission) and complete it.

Alarm behaviour: on iOS 26+, with Alarms allowed, Bangunin uses Apple's AlarmKit. If Alarms is switched off, the app shows a full-screen explanation with a button to the iOS prompt or Settings, because a notification alone cannot wake the user. For mission alarms, stopping the alert without finishing the mission schedules the same alarm again one minute later until the mission is completed (users are told this during onboarding). An Emergency Escape is always available, and snoozing is limited by the user's own setting.

Subscriptions: Bangunin Premium Yearly and Monthly, each with a 3-day free trial, sold through the App Store via RevenueCat. Restore Purchases and links to the Privacy Policy and Terms of Use are on the paywall.

Privacy: no account, no ads, no tracking. Camera frames, photos, pose data and custom sounds stay on the device. RevenueCat receives an anonymous app user ID and purchase history to check subscription status.

Contact: hello@bangunin.app
