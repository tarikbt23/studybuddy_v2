import 'package:shared_preferences/shared_preferences.dart';

class SharedPreferencesService {
  static Future<void> loadSwitchValues(Function(bool, bool, bool) setStateCallback) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setStateCallback(
      prefs.getBool('switch1') ?? false,
      prefs.getBool('switch2') ?? false,
      prefs.getBool('switch3') ?? false,
    );
  }

  static Future<void> saveSwitchValues(bool switch1Value, bool switch2Value, bool switch3Value) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setBool('switch1', switch1Value);
    prefs.setBool('switch2', switch2Value);
    prefs.setBool('switch3', switch3Value);
  }
}