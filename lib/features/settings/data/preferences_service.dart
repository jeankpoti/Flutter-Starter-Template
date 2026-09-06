import 'package:shared_preferences/shared_preferences.dart';

class PreferencesService {
  static const String _isFirstTimeKey = 'is_first_time';
  static const String _localeKey = 'selected_locale';

  static PreferencesService? _instance;
  SharedPreferences? _prefs;

  PreferencesService._();

  static Future<PreferencesService> getInstance() async {
    _instance ??= PreferencesService._();
    _instance!._prefs ??= await SharedPreferences.getInstance();
    return _instance!;
  }

  // First-time user preferences
  bool isFirstTime() {
    return _prefs!.getBool(_isFirstTimeKey) ?? true;
  }

  Future<void> setFirstTimeComplete() async {
    await _prefs!.setBool(_isFirstTimeKey, false);
  }

  // Locale preferences
  Future<void> setLocale(String languageCode) async {
    await _prefs!.setString(_localeKey, languageCode);
  }

  String getLocale() {
    return _prefs!.getString(_localeKey) ?? 'en'; // Default to English
  }

  Future<void> clearAll() async {
    await _prefs!.clear();
  }
}