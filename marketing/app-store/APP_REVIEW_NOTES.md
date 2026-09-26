# App Review notes

Bangunin is a user-scheduled alarm-clock app. To test quickly:

1. Allow notifications during onboarding.
2. Create an alarm for two minutes in the future.
3. Choose a mission. Photo and exercise missions ask for camera permission only when used; custom recording asks for microphone permission.
4. On iOS 26 or later, allow Bangunin's alarm authorization when prompted.
5. Lock the iPhone and wait for the system alarm screen. Tap **Start mission**
   and complete the selected mission.

Important iOS behavior: on iOS 26 or later, with alarm authorization granted,
Bangunin uses Apple's AlarmKit for the user-created alarm. On earlier iOS
versions, or if alarm authorization is denied, Bangunin transparently falls
back to scheduled local notifications and explains that those notifications
cannot override Silent Mode or Focus. Bangunin does not claim otherwise.

Premium review access:

- On the paywall, tap **Have an access code?**
- Enter `iamtheownerfree1`
- Tap **Redeem**

This code unlocks premium locally without a purchase so review is not blocked by subscription-product propagation. It contains no personal or account data.

Data handling:

- No account or login is required.
- No ads or tracking SDK is included. Google ML Kit may send limited,
  non-user-linked SDK diagnostics and usage telemetry as disclosed in App
  Privacy and the privacy policy.
- Camera frames and pose landmarks are processed on device.
- Temporary mission attempt images are deleted after verification.
- Object Hunt reference images and user-selected custom sounds remain only on the device until replaced or the related alarm is deleted.
- Bangunin does not upload mission photos or audio.
- Purchases are processed by Apple.

Contact: `hello@bangunin.app`
