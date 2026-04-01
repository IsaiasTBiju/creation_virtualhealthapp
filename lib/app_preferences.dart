import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AppPreferences extends ChangeNotifier {
  static const _kTextScale = 'pref_text_scale';
  static const _kHighContrast = 'pref_high_contrast';
  static const _kColorBlind = 'pref_color_blind';

  double textScale = 1.0;
  bool highContrast = false;
  bool colorBlindMode = false;

  Future<void> load() async {
    final p = await SharedPreferences.getInstance();
    textScale = p.getDouble(_kTextScale) ?? 1.0;
    highContrast = p.getBool(_kHighContrast) ?? false;
    colorBlindMode = p.getBool(_kColorBlind) ?? false;
    notifyListeners();
  }

  Future<void> setTextScale(double value) async {
    textScale = value.clamp(0.85, 1.35);
    final p = await SharedPreferences.getInstance();
    await p.setDouble(_kTextScale, textScale);
    notifyListeners();
  }

  Future<void> setHighContrast(bool value) async {
    highContrast = value;
    final p = await SharedPreferences.getInstance();
    await p.setBool(_kHighContrast, value);
    notifyListeners();
  }

  Future<void> setColorBlindMode(bool value) async {
    colorBlindMode = value;
    final p = await SharedPreferences.getInstance();
    await p.setBool(_kColorBlind, value);
    notifyListeners();
  }

  ThemeData buildTheme() {
    final seed = colorBlindMode ? const Color(0xFF005A9C) : const Color(0xFF6C2CF3);
    final scheme = ColorScheme.fromSeed(seedColor: seed);
    return ThemeData(
      useMaterial3: true,
      colorScheme: scheme,
      scaffoldBackgroundColor: const Color(0xFFF8F9FB),
      textTheme: Typography.blackMountainView.apply(
        bodyColor: highContrast ? Colors.black : null,
        displayColor: highContrast ? Colors.black : null,
      ),
      dividerTheme: DividerThemeData(
        color: highContrast ? Colors.black87 : const Color(0xFFE5E7EB),
        thickness: highContrast ? 1.4 : 1.0,
      ),
    );
  }
}
