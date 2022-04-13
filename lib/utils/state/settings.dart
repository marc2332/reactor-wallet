import 'package:hive_flutter/hive_flutter.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

enum ThemeType {
  light,
  dark,
}

class SettingsManager extends StateNotifier<Map<String, dynamic>> {
  late Box<dynamic> settingsBox;
  final StateNotifierProviderRef ref;

  SettingsManager(this.ref) : super({}) {
    state["theme"] = ThemeType.light.name;
  }

  void setTheme(ThemeType theme) {
    settingsBox.put("theme", theme.name);
    state["theme"] = theme.name;
    state = Map.from(state);
  }

  ThemeType getTheme() {
    return mapType(state["theme"]);
  }

  static ThemeType mapType(String type) {
    switch (type) {
      case "dark":
        return ThemeType.dark;
      default:
        return ThemeType.light;
    }
  }
}
