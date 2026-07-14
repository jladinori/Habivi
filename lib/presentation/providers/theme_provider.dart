import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';

class ThemeNotifier extends StateNotifier<ThemeMode> {
  ThemeNotifier() : super(ThemeMode.dark) {
    _load();
  }

  static const _boxName = 'settings';
  static const _key = 'isDark';

  Future<void> _load() async {
    final box = await Hive.openBox<bool>(_boxName);
    final isDark = box.get(_key, defaultValue: true);
    state = isDark! ? ThemeMode.dark : ThemeMode.light;
  }

  Future<void> toggle() async {
    state = state == ThemeMode.dark ? ThemeMode.light : ThemeMode.dark;
    final box = await Hive.openBox<bool>(_boxName);
    await box.put(_key, state == ThemeMode.dark);
    await box.flush();
  }
}

final themeModeProvider =
    StateNotifierProvider<ThemeNotifier, ThemeMode>((ref) {
  return ThemeNotifier();
});
