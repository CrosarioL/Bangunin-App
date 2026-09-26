# Play Console declarations

These are drafts. Confirm the final questions shown in the account before submitting.

## Core declarations

- Ads: No.
- App access: Some functionality is restricted by the subscription paywall. No account or username is required. On the Bangunin paywall, tap **Have an access code?**, enter `iamtheownerfree1`, then tap **Redeem**. This grants device-local Premium access so the reviewer can test every alarm and mission without a purchase. The code is reusable during early review and does not transmit data.
- Target audience: 13+; not designed for children.
- News, government, financial features, COVID/health: No.
- Advertising ID: No; the merged manifest does not request AD_ID.
- IARC category: Utility/productivity. Answer content questions truthfully; the app has no violence, sexual content, gambling, user-generated content, or social communication. Exercise missions are general activity, not medical advice.

## Exact alarm permission

Bangunin is a dedicated alarm-clock app. Users explicitly create alarms for a chosen time. Exact timing is necessary for this core, user-facing alarm function. `USE_EXACT_ALARM` is used only to schedule alarms created by the user and their configured snoozes; it is not used for advertising, background engagement, analytics, or unrelated notifications.

## Full-screen intent

Bangunin is a dedicated alarm-clock app. Full-screen intent is used only while a user-created alarm is actively ringing, to wake the screen and present the alarm and its dismissal mission over the lock screen. It is never used for advertising, promotional messages, engagement prompts, or unrelated notifications. If Android does not allow full-screen intent, Bangunin degrades to a high-priority alarm notification.

## Data Safety draft

The release contains no advertising, analytics, crash-reporting, or remote-config SDK that transmits app usage. Camera frames, temporary mission images, derived pose landmarks, Object Hunt references, custom recordings, alarms, and statistics remain on-device. Temporary attempt photos are deleted after verification. Purchases use Google Play Billing; transaction data handled solely by Play for payment processing is covered by Google's payment-service exception.

Provisional answers:

- Does the app collect or share required user-data types off-device? No, based on the current build and dependencies.
- Is data encrypted in transit? Not applicable to Bangunin data; Play Billing traffic is handled by Google.
- Can users request deletion? Local app data can be deleted by deleting alarms or uninstalling/clearing app storage. Website waitlist email deletion: `hello@bangunin.app`.
- Privacy-policy link: Yes.

Re-check this form if any analytics, crash reporting, cloud backup, accounts, or server feature is added.

## Account checks requiring the owner

In Play Console, open **Home** and **Developer account > Account details**. Confirm identity shows Verified, contact email/phone are verified, a Google Payments merchant profile is active for Indonesia, tax/payment details are accepted, and Android developer verification/package registration has no warning. Do not assume the 12-tester rule: the Dashboard will show **Apply for production** if this personal account is subject to it.
