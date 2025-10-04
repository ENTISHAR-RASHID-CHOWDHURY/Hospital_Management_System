import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/material.dart';

// Theme Mode State
class ThemeModeState {
  final ThemeMode themeMode;
  final bool isLoading;

  const ThemeModeState({
    this.themeMode = ThemeMode.light,
    this.isLoading = false,
  });

  ThemeModeState copyWith({
    ThemeMode? themeMode,
    bool? isLoading,
  }) {
    return ThemeModeState(
      themeMode: themeMode ?? this.themeMode,
      isLoading: isLoading ?? this.isLoading,
    );
  }
}

// Theme Mode Notifier
class ThemeModeNotifier extends StateNotifier<ThemeModeState> {
  static const String _key = 'theme_mode';

  ThemeModeNotifier() : super(const ThemeModeState()) {
    _loadThemeMode();
  }

  Future<void> _loadThemeMode() async {
    state = state.copyWith(isLoading: true);

    try {
      final prefs = await SharedPreferences.getInstance();
      final themeModeString = prefs.getString(_key);

      ThemeMode themeMode;
      switch (themeModeString) {
        case 'dark':
          themeMode = ThemeMode.dark;
          break;
        case 'light':
          themeMode = ThemeMode.light;
          break;
        default:
          themeMode = ThemeMode.system;
      }

      state = state.copyWith(themeMode: themeMode, isLoading: false);
    } catch (e) {
      state = state.copyWith(isLoading: false);
    }
  }

  Future<void> setThemeMode(ThemeMode mode) async {
    state = state.copyWith(themeMode: mode);

    try {
      final prefs = await SharedPreferences.getInstance();
      String modeString;
      switch (mode) {
        case ThemeMode.dark:
          modeString = 'dark';
          break;
        case ThemeMode.light:
          modeString = 'light';
          break;
        case ThemeMode.system:
          modeString = 'system';
          break;
      }
      await prefs.setString(_key, modeString);
    } catch (e) {
      // Handle error silently
    }
  }

  void toggleTheme() {
    final newMode =
        state.themeMode == ThemeMode.light ? ThemeMode.dark : ThemeMode.light;
    setThemeMode(newMode);
  }
}

// Provider
final themeModeProvider =
    StateNotifierProvider<ThemeModeNotifier, ThemeModeState>((ref) {
  return ThemeModeNotifier();
});
