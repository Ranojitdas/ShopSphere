import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ThemeCubit extends Cubit<ThemeMode> {
  static const String _themeKey = 'app_theme_mode';
  final SharedPreferences _prefs;

  ThemeCubit({required SharedPreferences sharedPreferences})
      : _prefs = sharedPreferences,
        super(_loadInitialTheme(sharedPreferences));

  static ThemeMode _loadInitialTheme(SharedPreferences prefs) {
    final savedMode = prefs.getString(_themeKey);
    switch (savedMode) {
      case 'light':
        return ThemeMode.light;
      case 'dark':
        return ThemeMode.dark;
      case 'system':
      default:
        return ThemeMode.system;
    }
  }

  Future<void> setThemeMode(ThemeMode mode) async {
    if (state == mode) return;
    emit(mode);
    switch (mode) {
      case ThemeMode.light:
        await _prefs.setString(_themeKey, 'light');
        break;
      case ThemeMode.dark:
        await _prefs.setString(_themeKey, 'dark');
        break;
      case ThemeMode.system:
        await _prefs.setString(_themeKey, 'system');
        break;
    }
  }

  Future<void> toggleTheme() async {
    if (state == ThemeMode.dark) {
      await setThemeMode(ThemeMode.light);
    } else {
      await setThemeMode(ThemeMode.dark);
    }
  }
}
