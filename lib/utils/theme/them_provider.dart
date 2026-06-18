import 'package:flutter/material.dart';
import 'package:flutter_riverpod/legacy.dart';

class ThemeNotifier extends StateNotifier<ThemeMode> {
  ThemeNotifier() : super(ThemeMode.system);

  void setLight() {
    state = ThemeMode.light;
  }

  void setDark() {
    state = ThemeMode.dark;
  }
}

final themeProvider =
StateNotifierProvider<ThemeNotifier, ThemeMode>(
        (ref) => ThemeNotifier());
