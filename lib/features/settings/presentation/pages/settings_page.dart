import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:in_app_review/in_app_review.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../../app/router/routes.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../app/theme/app_spacing.dart';
import '../../../../app/widgets/app_card.dart';
import '../../../../app/widgets/max_width_box.dart';
import '../../../../core/config/app_config.dart';
import '../../../../core/services/locale/locale_override_provider.dart';
import '../../../../core/utils/haptics.dart';
import '../../../../core/utils/l10n_ext.dart';
import '../../../../l10n/gen/app_localizations.dart';
import '../../../paywall/presentation/providers/premium_provider.dart';

/// Native (untranslated) names for each shipped locale — a language picker
/// shows every option in its own language, not the current UI language.
///
/// Indonesia-first: ar/de/es/fr were dropped before the iOS launch. They were
/// unreviewed, already drifting out of sync with the template (four keys had
/// gone missing, so those users hit English mid-screen), and none of them is a
/// target market. They remain in git history if we ever want them back.
const _languageNames = {'en': 'English', 'id': 'Bahasa Indonesia'};

class SettingsPage extends ConsumerWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final theme = Theme.of(context);
    final isPremium = ref.watch(isPremiumProvider);
    final localeOverride = ref.watch(localeOverrideProvider);

    return Scaffold(
      body: SafeArea(
        bottom: false,
        child: MaxWidthBox(
          child: ListView(
            physics: const BouncingScrollPhysics(
              parent: AlwaysScrollableScrollPhysics(),
            ),
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.lg,
              AppSpacing.xl,
              AppSpacing.lg,
              AppSpacing.xxl,
            ),
            children: [
              Text(l10n.tabSettings, style: theme.textTheme.headlineMedium),
              const SizedBox(height: AppSpacing.xl),
              if (isPremium)
                AppCard(
                  color: AppColors.primary.withValues(alpha: 0.12),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.workspace_premium_rounded,
                        color: AppColors.primary,
                        size: 32,
                      ),
                      const SizedBox(width: AppSpacing.md),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              l10n.premiumActive,
                              style: theme.textTheme.titleSmall,
                            ),
                            Text(
                              l10n.premiumActiveSubtitle,
                              style: theme.textTheme.bodySmall!.copyWith(
                                color: theme.colorScheme.onSurfaceVariant,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              const SizedBox(height: AppSpacing.lg),
              _Section(
                title: l10n.settingsSectionGeneral,
                children: [
                  _SettingsTile(
                    icon: Icons.notifications_rounded,
                    title: l10n.settingsNotifications,
                    onTap: () => unawaited(_openSystemSettings()),
                  ),
                  _SettingsTile(
                    icon: Icons.restore_rounded,
                    title: l10n.restorePurchases,
                    onTap: () => unawaited(
                      ref.read(purchaseInProgressProvider.notifier).restore(),
                    ),
                  ),
                  // Shown on both stores. This was previously gated to
                  // Android, which left iOS with no way to reach subscription
                  // management at all — and the iOS branch of the URL ternary
                  // inside it was therefore dead code.
                  _SettingsTile(
                    icon: Icons.manage_accounts_outlined,
                    title: l10n.manageSubscription,
                    onTap: () => unawaited(
                      _launch(
                        defaultTargetPlatform == TargetPlatform.iOS
                            ? AppConfig.manageAppStoreSubscriptionUrl
                            : AppConfig.manageGooglePlaySubscriptionUrl,
                      ),
                    ),
                  ),
                  _SettingsTile(
                    icon: Icons.language_rounded,
                    title: l10n.settingsLanguage,
                    trailingLabel:
                        _languageNames[localeOverride?.languageCode] ??
                        l10n.languageSystemDefault,
                    onTap: () => _showLanguagePicker(context, ref),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.lg),
              _Section(
                title: l10n.settingsSectionSupport,
                children: [
                  _SettingsTile(
                    icon: Icons.auto_stories_rounded,
                    title: l10n.settingsOurStory,
                    onTap: () => context.push(Routes.ourStory),
                  ),
                  _SettingsTile(
                    icon: Icons.mail_outline_rounded,
                    title: l10n.contactSupport,
                    onTap: () =>
                        unawaited(_launch('mailto:${AppConfig.supportEmail}')),
                  ),
                  _SettingsTile(
                    icon: Icons.star_border_rounded,
                    title: l10n.rateApp,
                    onTap: () =>
                        unawaited(InAppReview.instance.requestReview()),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.lg),
              _Section(
                title: l10n.settingsSectionLegal,
                children: [
                  _SettingsTile(
                    icon: Icons.privacy_tip_outlined,
                    title: l10n.privacyPolicy,
                    onTap: () => unawaited(_launch(AppConfig.privacyPolicyUrl)),
                  ),
                  _SettingsTile(
                    icon: Icons.description_outlined,
                    title: l10n.termsOfUse,
                    onTap: () => unawaited(_launch(AppConfig.termsUrl)),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.xl),
              Center(
                child: Text(
                  l10n.appVersion('1.0.0'),
                  style: theme.textTheme.bodySmall!.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  static Future<void> _launch(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  static Future<void> _openSystemSettings() async {
    // App notification settings live in the OS settings app.
    const url = 'app-settings:';
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) await launchUrl(uri);
  }

  static Future<void> _showLanguagePicker(
    BuildContext context,
    WidgetRef ref,
  ) async {
    final l10n = context.l10n;
    final current = ref.read(localeOverrideProvider);

    await showModalBottomSheet<void>(
      context: context,
      builder: (sheetContext) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.lg,
                AppSpacing.lg,
                AppSpacing.lg,
                AppSpacing.sm,
              ),
              child: Text(
                l10n.settingsLanguage,
                style: Theme.of(sheetContext).textTheme.titleMedium,
              ),
            ),
            _LanguageOption(
              label: l10n.languageSystemDefault,
              selected: current == null,
              onTap: () => _pickLanguage(ref, sheetContext, null),
            ),
            for (final locale in AppLocalizations.supportedLocales)
              _LanguageOption(
                label:
                    _languageNames[locale.languageCode] ?? locale.languageCode,
                selected: current == locale,
                onTap: () => _pickLanguage(ref, sheetContext, locale),
              ),
            const SizedBox(height: AppSpacing.sm),
          ],
        ),
      ),
    );
  }

  static Future<void> _pickLanguage(
    WidgetRef ref,
    BuildContext sheetContext,
    Locale? locale,
  ) async {
    Haptics.tap();
    await ref.read(localeOverrideProvider.notifier).set(locale);
    if (sheetContext.mounted) Navigator.of(sheetContext).pop();
  }
}

class _LanguageOption extends StatelessWidget {
  const _LanguageOption({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(label),
      trailing: selected
          ? const Icon(Icons.check_rounded, color: AppColors.primary)
          : null,
      onTap: onTap,
    );
  }
}

class _Section extends StatelessWidget {
  const _Section({required this.title, required this.children});

  final String title;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(
            left: AppSpacing.sm,
            bottom: AppSpacing.sm,
          ),
          child: Text(
            title,
            style: theme.textTheme.labelSmall!.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
              letterSpacing: 0.6,
            ),
          ),
        ),
        AppCard(
          padding: EdgeInsets.zero,
          child: Column(children: children),
        ),
      ],
    );
  }
}

class _SettingsTile extends StatelessWidget {
  const _SettingsTile({
    required this.icon,
    required this.title,
    required this.onTap,
    this.trailingLabel,
  });

  final IconData icon;
  final String title;
  final VoidCallback onTap;

  /// Optional current-value hint shown before the chevron (e.g. the active
  /// language).
  final String? trailingLabel;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return ListTile(
      leading: Icon(icon, color: AppColors.primary),
      title: Text(title),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (trailingLabel != null) ...[
            Text(
              trailingLabel!,
              style: theme.textTheme.bodyMedium!.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(width: AppSpacing.xs),
          ],
          Icon(
            Icons.chevron_right_rounded,
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ],
      ),
      onTap: () {
        Haptics.tap();
        onTap();
      },
    );
  }
}
