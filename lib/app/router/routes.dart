/// Route names/paths in one place so navigation calls are typo-safe.
abstract final class Routes {
  static const onboarding = '/onboarding';
  static const paywall = '/paywall';
  static const home = '/home';
  static const stats = '/stats';
  static const settings = '/settings';
  static const alarmNew = '/alarm/new';

  static String alarmEdit(String id) => '/alarm/$id/edit';
  static const alarmEditPattern = '/alarm/:id/edit';

  static String ringing(String alarmId) => '/ringing/$alarmId';
  static const ringingPattern = '/ringing/:id';

  static String photoMission(String alarmId) => '/mission/photo/$alarmId';
  static const photoMissionPattern = '/mission/photo/:id';

  static String movementMission(String alarmId) =>
      '/mission/movement/$alarmId';
  static const movementMissionPattern = '/mission/movement/:id';

  static const objectRegistration = '/object-registration';
  static const wakeSuccess = '/wake-success';
  static const ourStory = '/our-story';
}
