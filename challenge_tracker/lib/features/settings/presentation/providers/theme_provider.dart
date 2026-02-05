import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

const String _themeModeKey = 'app_theme_mode';

// State Notifier for ThemeMode
class ThemeModeNotifier extends StateNotifier<ThemeMode> {
  ThemeModeNotifier(this._prefs) : super(ThemeMode.system) {
    _loadThemeMode();
  }

  final SharedPreferences _prefs;

  void _loadThemeMode() {
    final themeModeString = _prefs.getString(_themeModeKey);
    if (themeModeString != null) {
      state = ThemeMode.values.firstWhere(
        (e) => e.toString() == themeModeString,
        orElse: () => ThemeMode.system,
      );
    }
  }

  Future<void> setThemeMode(ThemeMode themeMode) async {
    if (state != themeMode) {
      state = themeMode;
      await _prefs.setString(_themeModeKey, themeMode.toString());
    }
  }

  /// Reset theme to system default and clear stored preference.
  Future<void> reset() async {
    state = ThemeMode.system;
    await _prefs.remove(_themeModeKey);
  }
}

// Provider for SharedPreferences
final sharedPreferencesProvider =
    FutureProvider<SharedPreferences>((ref) async {
  return await SharedPreferences.getInstance();
});

// Provider for ThemeModeNotifier
final themeProvider = StateNotifierProvider<ThemeModeNotifier, ThemeMode>((ref) {
  final prefs = ref.watch(sharedPreferencesProvider).asData?.value;
  if (prefs == null) {
    // This should ideally show a loading state, but for simplicity,
    // we'll return a notifier with in-memory state until prefs are loaded.
    // When prefs load, the provider will be re-created with the correct instance.
    return ThemeModeNotifier(InMemorySharedPreferences());
  }
  return ThemeModeNotifier(prefs);
});

// In-memory implementation for when SharedPreferences is not available yet.
class InMemorySharedPreferences implements SharedPreferences {
  final Map<String, Object> _data = {};

  @override
  Future<bool> clear() {
    _data.clear();
    return Future.value(true);
  }

  @override
  Future<bool> commit() => Future.value(true);

  @override
  String? getString(String key) => _data[key] as String?;

  @override
  Future<bool> setString(String key, String value) {
    _data[key] = value;
    return Future.value(true);
  }

  // Unimplemented methods that we don't need for this feature.
  @override
  bool containsKey(String key) => throw UnimplementedError();
  @override
  Set<String> getKeys() => throw UnimplementedError();
  @override
  dynamic get(String key) => throw UnimplementedError();
  @override
  bool? getBool(String key) => throw UnimplementedError();
  @override
  double? getDouble(String key) => throw UnimplementedError();
  @override
  int? getInt(String key) => throw UnimplementedError();
  @override
  List<String>? getStringList(String key) => throw UnimplementedError();
  @override
  Future<void> reload() => throw UnimplementedError();
  @override
  Future<bool> remove(String key) {
    _data.remove(key);
    return Future.value(true);
  }
  @override
  Future<bool> setBool(String key, bool value) => throw UnimplementedError();
  @override
  Future<bool> setDouble(String key, double value) => throw UnimplementedError();
  @override
  Future<bool> setInt(String key, int value) => throw UnimplementedError();
  @override
  Future<bool> setStringList(String key, List<String> value) =>
      throw UnimplementedError();
}
