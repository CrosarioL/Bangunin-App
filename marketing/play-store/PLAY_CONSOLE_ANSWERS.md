# Play Console declarations

These answers describe version 1.0.0 (`app.bangunin`). Re-check them whenever SDKs or features change.

## App setup

- App or game: App
- Free or paid: Free, with subscriptions
- Category: Productivity
- Ads: No
- App access: No account or login required. Reviewers can create and test alarms without credentials. Subscription products require a Play license tester in internal/closed testing.
- Target audience: 16–17 and 18+
- Designed for children: No
- News app: No
- Government app: No
- Financial features: No
- Health features declaration: No health data or health claims. Squats and push-ups are optional alarm-dismissal missions, not fitness tracking or medical functionality.

## Data safety

- Does the app collect or share required user-data types off device? No.
- Data shared with third parties: No app data is shared.
- Data collected: No app data is collected by the developer.
- Camera photos/frames: On-device processing only. Attempt photos are deleted immediately. Object Hunt reference photos remain only in private app storage until the alarm/reference/app data is deleted.
- Microphone/audio: Optional custom alarm recordings stay in private app storage and are not transmitted.
- Alarm schedule, wake records, preferences: Stored locally only.
- Analytics/crash SDKs: None in the release app. Debug logging is local and disabled in release.
- Advertising ID: Not accessed.
- Account creation: None.
- Account deletion URL: Not applicable because accounts cannot be created. The privacy policy explains local deletion through alarm deletion, Clear storage, or uninstall.
- Privacy policy URL: `https://bangunin.app/privacy.html` — must be publicly reachable before closed testing.
- Data encrypted in transit: The app does not transmit its own user data. Google Play Billing traffic is handled by Google Play.

## Permissions declarations

### USE_EXACT_ALARM

Bangunin is a dedicated alarm-clock app. Its primary user-facing function is firing user-created wake alarms at the exact selected time. Delayed/inexact delivery would break the core function.

### USE_FULL_SCREEN_INTENT

Bangunin's core function is a wake alarm. Full-screen intent is used only when a user-created alarm fires, so the user can see and complete the selected dismissal mission from the lock screen. It is never used for promotions, messages, or background engagement.

### Camera

Used only for user-selected photo missions and on-device squat/push-up pose verification. Permission is requested in context when a camera mission starts. Frames and attempt photos are not uploaded.

### Microphone

Used only when the user explicitly records a custom alarm sound. Recordings stay on the device.

### Notifications

Used to deliver alarms selected and scheduled by the user.

## Content rating questionnaire

- Violence: No
- Sexuality/nudity: No
- Profanity: No
- Controlled substances: No
- Gambling: No
- User interaction or user-generated sharing: No
- Location sharing: No
- Digital purchases: Yes, subscriptions
- Expected result: General-audience/low maturity rating, subject to IARC's final calculation.

## Reviewer notes

Bangunin is an alarm-clock app whose full-screen intent and exact-alarm permissions are essential to its primary function. Camera access is optional until the user chooses a photo or exercise mission. All mission verification is on-device. No login is required. For the quickest review, create an alarm one or two minutes ahead, choose a mission, save it, and allow notification/exact-alarm/full-screen permissions when Android requests them.

