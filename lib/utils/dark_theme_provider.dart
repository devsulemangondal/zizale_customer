import 'dart:developer' as developer;

import 'package:customer/utils/dark_theme_preference.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/scheduler.dart';


class DarkThemeProvider with ChangeNotifier {
  DarkThemePreference darkThemePreference = DarkThemePreference();
  int _darkTheme = 0;

  int get darkTheme => _darkTheme;

  set darkTheme(int value) {
    _darkTheme = value;
    try {
      darkThemePreference.setDarkTheme(value);
    } catch (e) {
      developer.log("Error setting dark theme: ${e.toString()}");
    }
    notifyListeners();
  }

  bool isDarkTheme() {
    try {
      return darkTheme == 0
          ? true
          : darkTheme == 1
          ? false
          : DarkThemeProvider().getSystemThem();
    } catch (e) {
      developer.log("Error determining theme: ${e.toString()}");
      return false; // Fallback to light mode
    }
  }

  bool getSystemThem() {
    try {
      var brightness = SchedulerBinding.instance.platformDispatcher.platformBrightness;
      return brightness == Brightness.dark;
    } catch (e) {
      developer.log("Error getting system theme: ${e.toString()}");
      return false; // Fallback to light mode
    }
  }
}
