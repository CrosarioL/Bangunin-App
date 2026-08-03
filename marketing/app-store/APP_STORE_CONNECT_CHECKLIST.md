# App Store Connect checklist

## App record

- Platform: iOS
- Name: Bangunin
- Primary language: Indonesian
- Bundle ID: `app.bangunin`
- SKU: `bangunin-ios-001`
- Version: 1.0.0
- Build: 2

## App Privacy

Based on the current binary and local-first implementation, select **No, we do not collect data from this app**. Camera/photo/pose/audio mission data stays on device; Apple handles payment details; no ads, analytics upload, crash-reporting, or tracking SDK is bundled. Recheck this answer before submission if any SDK or backend is added.

Tracking: **No**. IDFA/advertising identifier: **not used**.

## Age rating

Answer the questionnaire truthfully. Expected result is a low rating: no violence, sexual content, gambling, drugs, web access, or user-generated content. Exercise missions are ordinary fitness movements and include safety wording.

## Export compliance

The app does not implement proprietary encryption. For the standard Apple/system HTTPS and store frameworks, answer the export-compliance questions according to App Store Connect’s exemption flow. Do not claim an exemption if later adding custom cryptography beyond normal OS networking.

## Review

- Sign-in required: No
- Contact: app owner’s reachable name, phone, and email
- Notes: paste `APP_REVIEW_NOTES.md`
- Attachment: a short video of an alarm notification and mission completion is optional but recommended.

## Assets still required

- iPhone screenshots captured from the iOS build in every device-size group App Store Connect requires.
- Optional app preview video.
- Subscription review screenshot showing the final paywall.

Android Pixel screenshots should not be uploaded as iPhone screenshots.
