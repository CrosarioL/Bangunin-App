import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'app_colors.dart';
import 'app_spacing.dart';

/// Builds the Material 3 themes. Dark is the primary experience; light is a
/// faithful counterpart so the app respects the system setting.
abstract final class AppTheme {
  static ThemeData get dark => _build(Brightness.dark);
  static ThemeData get light => _build(Brightness.light);

  static ThemeData _build(Brightness brightness) {
    final isDark = brightness == Brightness.dark;

    final colorScheme = ColorScheme(
      brightness: brightness,
      primary: AppColors.primary,
      onPrimary: AppColors.onPrimary,
      secondary: AppColors.info,
      onSecondary: Colors.white,
      error: AppColors.danger,
      onError: Colors.white,
      surface: isDark ? AppColors.surface : AppColors.surfaceLight,
      onSurface: isDark ? AppColors.textPrimary : AppColors.textPrimaryLight,
      surfaceContainerHighest:
          isDark ? AppColors.surfaceRaised : AppColors.surfaceRaisedLight,
      onSurfaceVariant:
          isDark ? AppColors.textSecondary : AppColors.textSecondaryLight,
      outline: isDark ? AppColors.outline : AppColors.outlineLight,
    );

    final textTheme = _textTheme(colorScheme.onSurface);

    return ThemeData(
      useMaterial3: true,
      brightness: brightness,
      colorScheme: colorScheme,
      // Nunito is the rounded default; headings/buttons override to the
      // chunkier Baloo2 in the text theme below.
      fontFamily: 'Nunito',
      // Transparent: the ambient AppBackground installed behind the router
      // (see BanguninApp.builder) paints the real backdrop for every screen.
      scaffoldBackgroundColor: Colors.transparent,
      textTheme: textTheme,
      // The product uses calm fades instead of Android's default zoom, and
      // native cupertino slides on iOS.
      pageTransitionsTheme: const PageTransitionsTheme(
        builders: {
          TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
          TargetPlatform.android: FadeForwardsPageTransitionsBuilder(),
        },
      ),
      splashFactory: NoSplash.splashFactory,
      highlightColor: Colors.transparent,
      appBarTheme: AppBarTheme(
        backgroundColor: Colors.transparent,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        systemOverlayStyle:
            isDark ? SystemUiOverlayStyle.light : SystemUiOverlayStyle.dark,
        titleTextStyle: textTheme.titleMedium,
        iconTheme: IconThemeData(color: colorScheme.onSurface),
      ),
      cardTheme: CardThemeData(
        color: colorScheme.surface,
        elevation: 0,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppSpacing.radiusCard),
        ),
      ),
      // Fallback for any raw FilledButton; the primary CTA uses the custom
      // chunky push-button (PrimaryButton). Flat, bold, fat corners.
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: AppColors.onPrimary,
          minimumSize: const Size.fromHeight(56),
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppSpacing.radiusButton),
          ),
          textStyle: textTheme.titleSmall!.copyWith(
            fontWeight: FontWeight.w800,
            letterSpacing: 0.6,
          ),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: colorScheme.onSurfaceVariant,
          textStyle: textTheme.bodyMedium,
        ),
      ),
      switchTheme: SwitchThemeData(
        thumbColor: const WidgetStatePropertyAll(Colors.white),
        trackColor: WidgetStateProperty.resolveWith(
          (states) => states.contains(WidgetState.selected)
              ? AppColors.primary
              : colorScheme.surfaceContainerHighest,
        ),
        trackOutlineColor: const WidgetStatePropertyAll(Colors.transparent),
      ),
      bottomSheetTheme: BottomSheetThemeData(
        backgroundColor: colorScheme.surface,
        surfaceTintColor: Colors.transparent,
        showDragHandle: true,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(
            top: Radius.circular(AppSpacing.radiusCard),
          ),
        ),
      ),
      dividerTheme: DividerThemeData(
        color: colorScheme.outline,
        thickness: 1,
        space: 1,
      ),
      navigationBarTheme: NavigationBarThemeData(
        // Transparent: AppShell paints the solid chunky bar around it.
        backgroundColor: Colors.transparent,
        surfaceTintColor: Colors.transparent,
        // A soft rounded pill highlights the active tab.
        indicatorColor: AppColors.primary.withValues(alpha: 0.16),
        indicatorShape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppSpacing.radiusCapsule),
        ),
        height: 68,
        labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
        iconTheme: WidgetStateProperty.resolveWith(
          (states) => IconThemeData(
            color: states.contains(WidgetState.selected)
                ? AppColors.primary
                : colorScheme.onSurfaceVariant,
          ),
        ),
        labelTextStyle: WidgetStateProperty.resolveWith(
          (states) => textTheme.labelSmall!.copyWith(
            color: states.contains(WidgetState.selected)
                ? AppColors.primary
                : colorScheme.onSurfaceVariant,
          ),
        ),
      ),
    );
  }

  static TextTheme _textTheme(Color onSurface) {
    // Rounded, chunky hierarchy (Duolingo-style): Baloo2 for the big bold
    // headings and buttons, Nunito for readable body copy.
    TextStyle style(
      double size,
      FontWeight weight, {
      double? spacing,
      String family = 'Nunito',
    }) =>
        TextStyle(
          fontFamily: family,
          fontSize: size,
          fontWeight: weight,
          letterSpacing: spacing,
          color: onSurface,
        );

    return TextTheme(
      displayLarge: style(72, FontWeight.w800, spacing: -1.5, family: 'Baloo2'),
      displayMedium: style(44, FontWeight.w800, spacing: -1, family: 'Baloo2'),
      headlineMedium: style(28, FontWeight.w800, spacing: -0.5, family: 'Baloo2'),
      headlineSmall: style(22, FontWeight.w700, family: 'Baloo2'),
      titleMedium: style(17, FontWeight.w700, family: 'Baloo2'),
      titleSmall: style(16, FontWeight.w700, family: 'Baloo2'),
      bodyLarge: style(17, FontWeight.w600),
      bodyMedium: style(15, FontWeight.w600),
      bodySmall: style(13, FontWeight.w600),
      labelLarge: style(15, FontWeight.w700, family: 'Baloo2'),
      labelSmall: style(11, FontWeight.w700),
    );
  }
}
