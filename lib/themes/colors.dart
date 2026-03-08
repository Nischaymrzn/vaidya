import 'package:flutter/material.dart';

class AppColors {
  static Brightness _brightness = Brightness.light;

  static void sync(Brightness brightness) {
    _brightness = brightness;
  }

  static bool get isDark => _brightness == Brightness.dark;

  static const Color _primary = Color(0xFF1F7AE0);
  static const Color _success = Color(0xFF22C55E);
  static const Color _warning = Color(0xFFF59E0B);
  static const Color _error = Color(0xFFEF4444);

  static Color get primary => _primary;
  static Color get primarySoft =>
      isDark ? const Color(0x331F7AE0) : const Color(0xFFE8F1FF);
  static Color get primaryMuted =>
      isDark ? const Color(0xFF93C5FD) : const Color(0xFF5598EA);

  static Color get background =>
      isDark ? const Color(0xFF09090B) : const Color(0xFFF8FAFC);
  static Color get card =>
      isDark ? const Color(0xFF18181B) : const Color(0xFFFFFFFF);
  static Color get surfaceSoft =>
      isDark ? const Color(0xFF111317) : const Color(0xFFF8FAFC);
  static Color get surfaceMuted =>
      isDark ? const Color(0xFF1F2937) : const Color(0xFFF1F5F9);

  static Color get textPrimary =>
      isDark ? const Color(0xFFF8FAFC) : const Color(0xFF0F172A);
  static Color get textSecondary =>
      isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B);

  static Color get border =>
      isDark ? const Color(0xFF27272A) : const Color(0xFFE2E8F0);
  static Color get borderStrong =>
      isDark ? const Color(0xFF3F3F46) : const Color(0xFFCBD5E1);

  static Color get success => _success;
  static Color get warning => _warning;
  static Color get error => _error;

  static Color get dangerSurface =>
      isDark ? const Color(0xFF3F1D1D) : const Color(0xFFFEF2F2);
  static Color get warningSurface =>
      isDark ? const Color(0xFF3F331A) : const Color(0xFFFFFBEB);
  static Color get successSurface =>
      isDark ? const Color(0xFF123125) : const Color(0xFFECFDF5);

  static Color get activeNav => primary;
  static Color get isNotActiveNav =>
      isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B);
}
