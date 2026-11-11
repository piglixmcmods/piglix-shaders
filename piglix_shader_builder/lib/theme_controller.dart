import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Global application theme mode controller providing instant reactivity across screens.
class AppThemeController {
  static final ValueNotifier<bool> isDarkMode = ValueNotifier<bool>(true);

  static bool get isDark => isDarkMode.value;

  static Future<void> init() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final savedDark = prefs.getBool('app_theme_dark');
      if (savedDark != null) {
        isDarkMode.value = savedDark;
      }
    } catch (_) {}
  }

  static void toggleTheme() {
    isDarkMode.value = !isDarkMode.value;
    _persist();
  }

  static void setDark() {
    isDarkMode.value = true;
    _persist();
  }

  static void setLight() {
    isDarkMode.value = false;
    _persist();
  }

  static void _persist() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('app_theme_dark', isDarkMode.value);
    } catch (_) {}
  }
}

/// Dynamic theme palette for dark obsidian and clean modern light mode.
class AppPalette {
  final bool isDark;
  const AppPalette(this.isDark);

  Color get bg => isDark ? const Color(0xFF080D14) : const Color(0xFFF1F5F9);
  Color get surface => isDark ? const Color(0xFF0E1722) : Colors.white;
  Color get card => isDark ? const Color(0xFF0E1722) : Colors.white;
  Color get cardElevated => isDark ? const Color(0xFF141F2D) : const Color(0xFFF8FAFC);
  Color get border => isDark ? const Color(0xFF1E293B) : const Color(0xFFCBD5E1);
  Color get borderMuted => isDark ? const Color(0xFF141F2D) : const Color(0xFFE2E8F0);
  Color get primary => const Color(0xFF22C55E);
  Color get primaryDim => isDark ? const Color(0xFF16A34A) : const Color(0xFF15803D);
  Color get primaryGlow => const Color(0xFF22C55E).withValues(alpha: 0.35);
  Color get textPrimary => isDark ? Colors.white : const Color(0xFF0F172A);
  Color get textSecondary => isDark ? const Color(0xFF94A3B8) : const Color(0xFF475569);
  Color get textMuted => isDark ? Colors.white38 : const Color(0xFF94A3B8);
  Color get divider => isDark ? const Color(0xFF1E293B) : const Color(0xFFE2E8F0);
  Color get inputBg => isDark ? const Color(0xFF0E1722) : const Color(0xFFF8FAFC);
  Color get drawerBg => isDark ? const Color(0xFF080D14) : Colors.white;
  Color get bannerOverlayTop => isDark ? Colors.black.withValues(alpha: 0.35) : Colors.black.withValues(alpha: 0.20);
  Color get bannerOverlayBottom => isDark ? const Color(0xFF080D14) : const Color(0xFFF1F5F9);
}
