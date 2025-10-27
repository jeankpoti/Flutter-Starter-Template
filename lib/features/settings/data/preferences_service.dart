import 'package:shared_preferences/shared_preferences.dart';
import '../domain/models/math_level.dart';
import '../domain/models/response_length.dart';

class PreferencesService {
  static const String _mathLevelKey = 'math_level';
  static const String _responseLengthKey = 'response_length';
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

  // Math Level preferences
  Future<void> setMathLevel(MathLevel level) async {
    await _prefs!.setString(_mathLevelKey, level.name);
  }

  MathLevel getMathLevel() {
    final levelString = _prefs!.getString(_mathLevelKey);
    if (levelString == null) {
      return MathLevel.highSchool; // Default level
    }
    return MathLevel.fromString(levelString);
  }

  // First-time user preferences
  bool isFirstTime() {
    return _prefs!.getBool(_isFirstTimeKey) ?? true;
  }

  Future<void> setFirstTimeComplete() async {
    await _prefs!.setBool(_isFirstTimeKey, false);
  }

  // Response Length preferences
  Future<void> setResponseLength(ResponseLength length) async {
    await _prefs!.setString(_responseLengthKey, length.name);
  }

  ResponseLength getResponseLength() {
    final lengthString = _prefs!.getString(_responseLengthKey);
    if (lengthString == null) {
      return ResponseLength.short; // Default to short
    }
    return ResponseLength.fromString(lengthString);
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