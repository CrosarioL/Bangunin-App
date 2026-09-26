# App Store Connect checklist

## App record

- Platform: iOS
- Name: Bangunin
- Primary language: Indonesian
- Bundle ID: `app.bangunin`
- SKU: `bangunin-ios-001`
- Version: 1.0.0
- Build: 3

## App Privacy

Select **Yes, we collect data from this app**. Bangunin does not run its own
analytics service, but its Google ML Kit pose dependency declares limited SDK
diagnostics and usage analytics. Disclose the following as **not linked to the
user** and **not used for tracking**:

- Identifiers: Device ID (per-installation identifier)
- User Content: Other User Content (SDK configuration/feature metadata; not
  mission photos or camera frames)
- Usage Data: Product Interaction
- Diagnostics: Performance Data and Other Diagnostic Data
- Other Data: the ML Kit SDK's API/application configuration metadata

Use **Analytics** and, where App Store Connect offers it for the declared item,
**App Functionality** as the purposes. Do not declare photos, camera frames,
pose landmarks, audio, alarms, or payment-card details as collected by
Bangunin: those remain on device or are handled by Apple. Recheck the final
archive's privacy report before publishing because third-party SDK behavior can
change.

Tracking: **No**. Data linked to the user: **No**. IDFA/advertising identifier:
**not used**.

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
