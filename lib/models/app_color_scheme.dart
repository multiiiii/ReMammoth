import 'package:flutter/material.dart';

enum AppColorScheme {
  defaultBlue,
  fireIce,
  darkMode,
  jungle;

  Color get primaryColor => switch (this) {
        AppColorScheme.defaultBlue => const Color(0xFF023B67),
        AppColorScheme.fireIce => const Color(0xFF6EE9EF),
        AppColorScheme.darkMode => const Color(0xFF180A0A),
        AppColorScheme.jungle => const Color(0xFF9CB080),
      };

  Color get accentColor => switch (this) {
        AppColorScheme.defaultBlue => const Color(0xFFDE781C),
        AppColorScheme.fireIce => const Color(0xFF890303),
        AppColorScheme.darkMode => const Color(0xFF711A75),
        AppColorScheme.jungle => const Color(0xFF2B5748),
      };

  /// Slightly lighter variant of [primaryColor] used for modal sheet backgrounds.
  Color get midPrimaryColor {
    final hsl = HSLColor.fromColor(primaryColor);
    return hsl.withLightness((hsl.lightness + 0.08).clamp(0.0, 1.0)).toColor();
  }

  String get logoAsset => switch (this) {
        AppColorScheme.defaultBlue => 'assets/images/logo.png',
        AppColorScheme.fireIce => 'assets/images/logo_fireice.webp',
        AppColorScheme.darkMode => 'assets/images/logo_darkmode.webp',
        AppColorScheme.jungle => 'assets/images/logo_jungle.webp',
      };

  String get displayName => switch (this) {
        AppColorScheme.defaultBlue => 'Classic Blue',
        AppColorScheme.fireIce => 'Fire & Ice',
        AppColorScheme.darkMode => 'Dark Mode',
        AppColorScheme.jungle => 'Jungle',
      };

  /// Returns white or near-black text color for readable contrast on [bg].
  static Color onColor(Color bg) =>
      bg.computeLuminance() > 0.3
          ? const Color(0xFF1A1A1A)
          : Colors.white;
}
