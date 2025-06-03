import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'theme.dart';

class ThemeCubit extends Cubit<ThemeData> {
  bool _isDarkMode = false;

  ThemeCubit(bool isDarkMode) : super(isDarkMode ? darkMode : lightMode) {
    _isDarkMode = isDarkMode;
  }

  // bool get isDarkMode => _isDarkMode;

  void toggleTheme() async {
    _isDarkMode = !_isDarkMode;

    final prefs = await SharedPreferences.getInstance();

    prefs.setBool('isDarkMode', _isDarkMode);

    emit(_isDarkMode ? darkMode : lightMode);
  }
}
