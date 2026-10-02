import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'app_colors.dart';
import 'app_text_styles.dart';

class AppTheme {
  AppTheme._();

  static ThemeData darkTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,

    scaffoldBackgroundColor: AppColors.background,
    canvasColor: AppColors.background,
    cardColor: AppColors.card,

    colorScheme: const ColorScheme.dark(
      primary: AppColors.primary,
      secondary: AppColors.secondary,
      surface: AppColors.surface,
      surfaceTint: Colors.transparent,
      error: AppColors.error,
    ),

    appBarTheme: const AppBarTheme(
      backgroundColor: AppColors.background,
      surfaceTintColor: Colors.transparent,
      elevation: 0,
      scrolledUnderElevation: 0,
      centerTitle: true,
      iconTheme: IconThemeData(color: AppColors.textPrimary),
      titleTextStyle: AppTextStyles.title,
    ),

    bottomSheetTheme: const BottomSheetThemeData(
      backgroundColor: AppColors.card,
      modalBackgroundColor: AppColors.card,
      surfaceTintColor: Colors.transparent,
      modalBarrierColor: Colors.black54,
    ),

    dialogTheme: const DialogThemeData(
      backgroundColor: AppColors.card,
      surfaceTintColor: Colors.transparent,
      barrierColor: Colors.black54,
    ),

    pageTransitionsTheme: const PageTransitionsTheme(
      builders: {
        TargetPlatform.android: SmoothFadeSlidePageTransitionsBuilder(),
        TargetPlatform.iOS: SmoothFadeSlidePageTransitionsBuilder(),
        TargetPlatform.windows: SmoothFadeSlidePageTransitionsBuilder(),
        TargetPlatform.macOS: SmoothFadeSlidePageTransitionsBuilder(),
        TargetPlatform.linux: SmoothFadeSlidePageTransitionsBuilder(),
        TargetPlatform.fuchsia: SmoothFadeSlidePageTransitionsBuilder(),
      },
    ),

    textTheme: const TextTheme(
      displayLarge: AppTextStyles.heading,
      titleLarge: AppTextStyles.title,
      bodyLarge: AppTextStyles.body,
      bodyMedium: AppTextStyles.bodySecondary,
    ),

    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: AppColors.surface,

      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(30),
      ),

      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(30),
        borderSide: const BorderSide(
          color: AppColors.border,
          width: 2,
        ),
      ),

      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(30),
        borderSide: const BorderSide(
          color: AppColors.primary,
          width: 2,
        ),
      ),

      hintStyle: const TextStyle(
        color: AppColors.textSecondary,
      ),
    ),

    cardTheme: CardThemeData(
      color: AppColors.card,
      surfaceTintColor: Colors.transparent,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
    ),

    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,

        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15),
        ),

        padding: const EdgeInsets.symmetric(
          horizontal: 20,
          vertical: 15,
        ),
      ),
    ),
  );
}

/// Zero-flicker, butter-smooth page transition builder.
/// Combines a subtle 4% slide with a smooth cubic fade, ensuring the canvas never
/// blinks or exposes unpainted background pixels during transitions.
class SmoothFadeSlidePageTransitionsBuilder extends PageTransitionsBuilder {
  const SmoothFadeSlidePageTransitionsBuilder();

  @override
  Widget buildTransitions<T>(
    PageRoute<T> route,
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
    Widget child,
  ) {
    final curvedAnimation = CurvedAnimation(
      parent: animation,
      curve: Curves.easeOutCubic,
      reverseCurve: Curves.easeInCubic,
    );

    final fadeAnimation = CurvedAnimation(
      parent: animation,
      curve: const Interval(0.0, 0.75, curve: Curves.easeOut),
    );

    final secondaryFade = CurvedAnimation(
      parent: secondaryAnimation,
      curve: const Interval(0.0, 0.75, curve: Curves.easeIn),
    );

    return FadeTransition(
      opacity: fadeAnimation,
      child: SlideTransition(
        position: Tween<Offset>(
          begin: const Offset(0.04, 0.0),
          end: Offset.zero,
        ).animate(curvedAnimation),
        child: FadeTransition(
          opacity: Tween<double>(begin: 1.0, end: 0.85).animate(secondaryFade),
          child: child,
        ),
      ),
    );
  }
}