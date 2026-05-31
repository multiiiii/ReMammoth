import 'package:shared_preferences/shared_preferences.dart';

class SettingsService {
  static const _keyNoteFontSize = 'note_font_size';
  static const double defaultNoteFontSize = 14.0;

  late SharedPreferences _prefs;

  Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
  }

  double get noteFontSize =>
      _prefs.getDouble(_keyNoteFontSize) ?? defaultNoteFontSize;

  Future<void> setNoteFontSize(double size) =>
      _prefs.setDouble(_keyNoteFontSize, size);
}
