import 'package:flutter/material.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:shared_preferences/shared_preferences.dart';

part 'app_preferences_provider.g.dart';

enum AiPreference { local, cloud }

// ─── State ────────────────────────────────────────────────────────────────────

class AppPreferences {
  const AppPreferences({
    this.themeMode = ThemeMode.system,
    this.aiPreference = AiPreference.cloud,
  });

  final ThemeMode themeMode;
  final AiPreference aiPreference;

  AppPreferences copyWith({ThemeMode? themeMode, AiPreference? aiPreference}) {
    return AppPreferences(
      themeMode: themeMode ?? this.themeMode,
      aiPreference: aiPreference ?? this.aiPreference,
    );
  }
}

// ─── Persistence keys ─────────────────────────────────────────────────────────

const String _kThemeKey = 'pref_theme';
const String _kAiKey = 'pref_ai';

ThemeMode _themeFromString(String? value) {
  switch (value) {
    case 'light':
      return ThemeMode.light;
    case 'dark':
      return ThemeMode.dark;
    default:
      return ThemeMode.system;
  }
}

String _themeToString(ThemeMode mode) {
  switch (mode) {
    case ThemeMode.light:
      return 'light';
    case ThemeMode.dark:
      return 'dark';
    case ThemeMode.system:
      return 'system';
  }
}

AiPreference _aiFromString(String? value) {
  return value == 'local' ? AiPreference.local : AiPreference.cloud;
}

// ─── Notifier ────────────────────────────────────────────────────────────────

@Riverpod(keepAlive: true)
class AppPreferencesNotifier extends _$AppPreferencesNotifier {
  late final SharedPreferences _prefs;

  @override
  Future<AppPreferences> build() async {
    _prefs = await SharedPreferences.getInstance();
    return AppPreferences(
      themeMode: _themeFromString(_prefs.getString(_kThemeKey)),
      aiPreference: _aiFromString(_prefs.getString(_kAiKey)),
    );
  }

  Future<void> setThemeMode(ThemeMode mode) async {
    state = AsyncData(state.requireValue.copyWith(themeMode: mode));
    await _prefs.setString(_kThemeKey, _themeToString(mode));
  }

  Future<void> setAiPreference(AiPreference pref) async {
    state = AsyncData(state.requireValue.copyWith(aiPreference: pref));
    await _prefs.setString(_kAiKey, pref.name);
  }
}
