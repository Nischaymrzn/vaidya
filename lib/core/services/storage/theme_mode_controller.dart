import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:vaidya/core/services/storage/user_session_service.dart';

enum AppThemeMode { light, dark, system, autoLux }

final themeModeControllerProvider =
    NotifierProvider<ThemeModeController, AppThemeMode>(
      ThemeModeController.new,
    );

class ThemeModeController extends Notifier<AppThemeMode> {
  static const String _key = 'app_theme_mode';

  @override
  AppThemeMode build() {
    try {
      final prefs = ref.read(sharedPreferencesProvider);
      final saved = prefs.getString(_key);
      return _fromValue(saved);
    } catch (_) {
      // Keep app boot-safe even if prefs override is unavailable.
      return AppThemeMode.system;
    }
  }

  Future<void> setAppThemeMode(AppThemeMode mode) async {
    state = mode;
    try {
      final prefs = ref.read(sharedPreferencesProvider);
      await prefs.setString(_key, _toValue(mode));
    } catch (_) {}
  }

  Future<void> setThemeMode(ThemeMode mode) async {
    await setAppThemeMode(_fromMaterialMode(mode));
  }

  AppThemeMode _fromValue(String? value) {
    switch (value) {
      case 'light':
        return AppThemeMode.light;
      case 'dark':
        return AppThemeMode.dark;
      case 'auto_lux':
        return AppThemeMode.autoLux;
      default:
        return AppThemeMode.system;
    }
  }

  String _toValue(AppThemeMode mode) {
    switch (mode) {
      case AppThemeMode.light:
        return 'light';
      case AppThemeMode.dark:
        return 'dark';
      case AppThemeMode.system:
        return 'system';
      case AppThemeMode.autoLux:
        return 'auto_lux';
    }
  }

  AppThemeMode _fromMaterialMode(ThemeMode mode) {
    switch (mode) {
      case ThemeMode.light:
        return AppThemeMode.light;
      case ThemeMode.dark:
        return AppThemeMode.dark;
      case ThemeMode.system:
        return AppThemeMode.system;
    }
  }
}
