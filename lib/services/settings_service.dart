import 'package:shared_preferences/shared_preferences.dart';

import '../models/app_color_scheme.dart';

class SettingsService {
  static const _keyNoteFontSize = 'note_font_size';
  static const _keyColorScheme = 'color_scheme';
  static const double defaultNoteFontSize = 14.0;

  late SharedPreferences _prefs;

  Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
  }

  double get noteFontSize =>
      _prefs.getDouble(_keyNoteFontSize) ?? defaultNoteFontSize;

  Future<void> setNoteFontSize(double size) =>
      _prefs.setDouble(_keyNoteFontSize, size);

  AppColorScheme get colorScheme {
    final stored = _prefs.getString(_keyColorScheme);
    return AppColorScheme.values.firstWhere(
      (e) => e.name == stored,
      orElse: () => AppColorScheme.defaultBlue,
    );
  }

  Future<void> setColorScheme(AppColorScheme scheme) =>
      _prefs.setString(_keyColorScheme, scheme.name);
}
