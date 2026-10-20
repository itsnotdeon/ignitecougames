import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AppProvider extends ChangeNotifier {
  bool _isAfterDark = false;
  int _currentTabIndex = 0;

  bool get isAfterDark => _isAfterDark;
  int get currentTabIndex => _currentTabIndex;

  AppProvider() {
    _loadPreferences();
  }

  Future<void> _loadPreferences() async {
    final prefs = await SharedPreferences.getInstance();
    _isAfterDark = prefs.getBool('is_after_dark') ?? false;
    notifyListeners();
  }

  Future<void> toggleTheme() async {
    _isAfterDark = !_isAfterDark;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('is_after_dark', _isAfterDark);
  }

  Future<void> setAfterDark(bool value) async {
    if (_isAfterDark != value) {
      _isAfterDark = value;
      notifyListeners();
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('is_after_dark', _isAfterDark);
    }
  }

  void setTabIndex(int index) {
    _currentTabIndex = index;
    notifyListeners();
  }
}