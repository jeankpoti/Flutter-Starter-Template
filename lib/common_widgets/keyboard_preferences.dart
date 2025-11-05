import 'package:shared_preferences/shared_preferences.dart';

class KeyboardPreferences {
  static const String _lastCategoryKey = 'math_keyboard_last_category';
  static const String _keyboardSizeKey = 'math_keyboard_size';
  static const String _autoShowKey = 'math_keyboard_auto_show';

  static final KeyboardPreferences _instance = KeyboardPreferences._internal();
  factory KeyboardPreferences() => _instance;
  KeyboardPreferences._internal();

  SharedPreferences? _prefs;

  Future<void> _ensureInitialized() async {
    _prefs ??= await SharedPreferences.getInstance();
  }

  Future<String> getLastCategory() async {
    await _ensureInitialized();
    return _prefs!.getString(_lastCategoryKey) ?? 'numbers';
  }

  Future<void> setLastCategory(String category) async {
    await _ensureInitialized();
    await _prefs!.setString(_lastCategoryKey, category);
  }

  Future<double> getKeyboardSize() async {
    await _ensureInitialized();
    return _prefs!.getDouble(_keyboardSizeKey) ?? 280.0;
  }

  Future<void> setKeyboardSize(double size) async {
    await _ensureInitialized();
    await _prefs!.setDouble(_keyboardSizeKey, size);
  }

  Future<bool> getAutoShow() async {
    await _ensureInitialized();
    return _prefs!.getBool(_autoShowKey) ?? false;
  }

  Future<void> setAutoShow(bool autoShow) async {
    await _ensureInitialized();
    await _prefs!.setBool(_autoShowKey, autoShow);
  }
}