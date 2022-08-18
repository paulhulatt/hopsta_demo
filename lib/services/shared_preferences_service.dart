import 'package:shared_preferences/shared_preferences.dart';

class SharedPreferencesService {
  static SharedPreferencesService? _instance;
  static SharedPreferences? sharedPreferences;

  static Future<SharedPreferencesService> getInstance() async {
    if (_instance == null) {
      // Initialise the asynchronous shared preferences
      sharedPreferences = await SharedPreferences.getInstance();
      _instance = SharedPreferencesService();
    }

    return Future.value(_instance);
  }
}
