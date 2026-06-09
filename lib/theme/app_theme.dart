import 'package:flutter/material.dart';

import '../models/app_color_scheme.dart';

const appBlue = Color(0xFF023B67);
const appBlueMid = Color(0xFF034F8C);
const appOrange = Color(0xFFDE781C);

const _navy = appBlue;
const _navyLight = Color(0xFF5B9BD5);
const _navyContainer = appOrange;
const _navyContainerDark = Color(0xFF7A3D00);
const _onNavyContainer = Color(0xFF1A0900);
const _onNavyContainerDark = Color(0xFFFFE0BB);

const _orange = Color(0xFFE67E22);
const _orangeContainer = Color(0xFFFFE0BB);
const _orangeContainerDark = Color(0xFF7A3D00);
const _onOrangeContainer = Color(0xFF4D2700);
const _onOrangeContainerDark = Color(0xFFFFE0BB);

final ThemeData appTheme = ThemeData(
  useMaterial3: true,
  scaffoldBackgroundColor: appBlue,
  cardTheme: const CardThemeData(surfaceTintColor: Colors.transparent),
  popupMenuTheme: const PopupMenuThemeData(color: appBlueMid),
  appBarTheme: const AppBarTheme(
    backgroundColor: appBlue,
    foregroundColor: Colors.white,
    iconTheme: IconThemeData(color: Colors.white),
    actionsIconTheme: IconThemeData(color: Colors.white),
    surfaceTintColor: Colors.transparent,
    elevation: 0,
  ),
  colorScheme: const ColorScheme(
    brightness: Brightness.light,
    primary: _navy,
    onPrimary: Colors.white,
    primaryContainer: _navyContainer,
    onPrimaryContainer: _onNavyContainer,
    secondary: _orange,
    onSecondary: Colors.white,
    secondaryContainer: _orangeContainer,
    onSecondaryContainer: _onOrangeContainer,
    tertiary: Color(0xFF555555),
    onTertiary: Colors.white,
    tertiaryContainer: Color(0xFFE0E0E0),
    onTertiaryContainer: Color(0xFF1A1A1A),
    error: Color(0xFFD32F2F),
    onError: Colors.white,
    errorContainer: Color(0xFFFFDAD6),
    onErrorContainer: Color(0xFF410002),
    surface: Color(0xFFF5F5F5),
    onSurface: Color(0xFF1A1A1A),
    surfaceContainerHighest: Color(0xFFE0E0E0),
    onSurfaceVariant: Color(0xFF555555),
    outline: Color(0xFF9E9E9E),
    outlineVariant: Color(0xFFBDBDBD),
    shadow: Colors.black,
    scrim: Colors.black,
    inverseSurface: Color(0xFF1A1A1A),
    onInverseSurface: Color(0xFFF5F5F5),
    inversePrimary: _navyLight,
  ),
);

ThemeData buildThemeForScheme(AppColorScheme scheme) {
  final primary = scheme.primaryColor;
  final accent = scheme.accentColor;
  final mid = scheme.midPrimaryColor;
  final onPrimary = AppColorScheme.onColor(primary);
  final onAccent = AppColorScheme.onColor(accent);
  final onMid = AppColorScheme.onColor(mid);

  return ThemeData(
    useMaterial3: true,
    canvasColor: primary,
    scaffoldBackgroundColor: primary,
    pageTransitionsTheme: const PageTransitionsTheme(
      builders: {
        TargetPlatform.android: CupertinoPageTransitionsBuilder(),
        TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
      },
    ),
    cardTheme: const CardThemeData(surfaceTintColor: Colors.transparent),
    popupMenuTheme: PopupMenuThemeData(
      color: mid,
      textStyle: TextStyle(color: onMid),
      iconColor: onMid,
    ),
    appBarTheme: AppBarTheme(
      backgroundColor: primary,
      foregroundColor: onPrimary,
      iconTheme: IconThemeData(color: onPrimary),
      actionsIconTheme: IconThemeData(color: onPrimary),
      surfaceTintColor: Colors.transparent,
      elevation: 0,
    ),
    colorScheme: ColorScheme(
      brightness: Brightness.light,
      primary: primary,
      onPrimary: onPrimary,
      primaryContainer: accent,
      onPrimaryContainer: onAccent,
      secondary: accent,
      onSecondary: onAccent,
      secondaryContainer: accent,
      onSecondaryContainer: onAccent,
      tertiary: const Color(0xFF555555),
      onTertiary: Colors.white,
      tertiaryContainer: const Color(0xFFE0E0E0),
      onTertiaryContainer: const Color(0xFF1A1A1A),
      error: const Color(0xFFD32F2F),
      onError: Colors.white,
      errorContainer: const Color(0xFFFFDAD6),
      onErrorContainer: const Color(0xFF410002),
      surface: const Color(0xFFF5F5F5),
      onSurface: const Color(0xFF1A1A1A),
      surfaceContainerHighest: const Color(0xFFE0E0E0),
      onSurfaceVariant: const Color(0xFF555555),
      outline: const Color(0xFF9E9E9E),
      outlineVariant: const Color(0xFFBDBDBD),
      shadow: Colors.black,
      scrim: Colors.black,
      inverseSurface: const Color(0xFF1A1A1A),
      onInverseSurface: const Color(0xFFF5F5F5),
      inversePrimary: accent,
    ),
  );
}

final ThemeData appDarkTheme = ThemeData(
  useMaterial3: true,
  scaffoldBackgroundColor: const Color(0xFF011C32),
  popupMenuTheme: const PopupMenuThemeData(color: appBlueMid),
  appBarTheme: const AppBarTheme(
    backgroundColor: Color(0xFF011C32),
    foregroundColor: Colors.white,
    iconTheme: IconThemeData(color: Colors.white),
    actionsIconTheme: IconThemeData(color: Colors.white),
    surfaceTintColor: Colors.transparent,
    elevation: 0,
  ),
  colorScheme: const ColorScheme(
    brightness: Brightness.dark,
    primary: _navyLight,
    onPrimary: _onNavyContainer,
    primaryContainer: _navyContainerDark,
    onPrimaryContainer: _onNavyContainerDark,
    secondary: _orange,
    onSecondary: Color(0xFF1A1A1A),
    secondaryContainer: _orangeContainerDark,
    onSecondaryContainer: _onOrangeContainerDark,
    tertiary: Color(0xFFAAAAAA),
    onTertiary: Color(0xFF1A1A1A),
    tertiaryContainer: Color(0xFF2C2C2C),
    onTertiaryContainer: Color(0xFFE0E0E0),
    error: Color(0xFFEF5350),
    onError: Color(0xFF1A1A1A),
    errorContainer: Color(0xFF93000A),
    onErrorContainer: Color(0xFFFFDAD6),
    surface: Color(0xFF121212),
    onSurface: Color(0xFFE0E0E0),
    surfaceContainerHighest: Color(0xFF2C2C2C),
    onSurfaceVariant: Color(0xFFAAAAAA),
    outline: Color(0xFF666666),
    outlineVariant: Color(0xFF444444),
    shadow: Colors.black,
    scrim: Colors.black,
    inverseSurface: Color(0xFFE0E0E0),
    onInverseSurface: Color(0xFF121212),
    inversePrimary: _navy,
  ),
);
