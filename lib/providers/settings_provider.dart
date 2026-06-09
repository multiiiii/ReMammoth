import 'package:flutter/foundation.dart';

import '../models/app_color_scheme.dart';
import '../services/settings_service.dart';

class SettingsProvider extends ChangeNotifier {
  final SettingsService _service;

  SettingsProvider(this._service);

  double get noteFontSize => _service.noteFontSize;

  double get expandedNoteFontSize => noteFontSize + 2.0;

  Future<void> setNoteFontSize(double size) async {
    await _service.setNoteFontSize(size);
    notifyListeners();
  }

  AppColorScheme get colorScheme => _service.colorScheme;

  Future<void> setColorScheme(AppColorScheme scheme) async {
    await _service.setColorScheme(scheme);
    notifyListeners();
  }
}
