/// Remote-config / feature-flag abstraction. The default implementation
/// serves compiled-in values; a Firebase Remote Config implementation can be
/// swapped in via DI without touching call sites.
abstract interface class FeatureFlags {
  bool get paywallShowsWeeklyFirst;

  int get paywallDiscountPercent;

  int get maxFreeSnoozePreviewSeconds;

  bool get ratingPromptInOnboarding;
}

class LocalFeatureFlags implements FeatureFlags {
  const LocalFeatureFlags();

  @override
  bool get paywallShowsWeeklyFirst => false;

  @override
  int get paywallDiscountPercent => 80;

  @override
  int get maxFreeSnoozePreviewSeconds => 30;

  @override
  bool get ratingPromptInOnboarding => true;
}
