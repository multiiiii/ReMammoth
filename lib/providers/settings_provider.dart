import 'package:flutter/foundation.dart';

import '../services/settings_service.dart';

class SettingsProvider extends ChangeNotifier {
  final SettingsService _service;

  SettingsProvider(this._service);

  double get noteFontSize => _service.noteFontSize;

  Future<void> setNoteFontSize(double size) async {
    await _service.setNoteFontSize(size);
    notifyListeners();
  }
}
