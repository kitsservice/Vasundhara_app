import 'package:flutter/material.dart';

class SettingsProvider extends ChangeNotifier {
  bool _isMarathi = false;

  bool get isMarathi => _isMarathi;

  void toggleLanguage() {
    _isMarathi = !_isMarathi;
    notifyListeners();
  }

  void setLanguage(bool isMarathi) {
    if (_isMarathi != isMarathi) {
      _isMarathi = isMarathi;
      notifyListeners();
    }
  }
}
