import 'package:flutter/material.dart';
import 'package:staccato/main.dart';

class ThemeManager with ChangeNotifier {

  ThemeManager._();
  static final themeManager = ThemeManager._();

  //TODO save users preferred theme
  var _themeMode = ThemeMode.system;

  ThemeMode get themeMode => _themeMode;
  bool get isDarkMode => _themeMode == ThemeMode.dark;
  bool get isLightMode => _themeMode == ThemeMode.light;

  void changeThemeToDarkMode(bool isDark) {
    MyApp.logger.t('Changing theme to ${isDark ? 'dark' : 'light'} mode...');
    _themeMode = isDark ? ThemeMode.dark : ThemeMode.light;
    notifyListeners();
  }

  void systemTheme() {
    MyApp.logger.t('Changing theme to system theme');
    _themeMode = ThemeMode.system;
    notifyListeners();
  }
}