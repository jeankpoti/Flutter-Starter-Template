import 'dart:ui';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../settings/data/preferences_service.dart';

class LocaleCubit extends Cubit<Locale> {
  static const String _localeKey = 'selected_locale';
  static const Locale _defaultLocale = Locale('en');
  static const List<String> _supportedLanguages = ['en', 'fr', 'es'];

  LocaleCubit() : super(_defaultLocale) {
    _loadSavedLocale();
  }

  /// Load the saved locale from SharedPreferences
  Future<void> _loadSavedLocale() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final savedLanguageCode = prefs.getString(_localeKey);
      
      if (savedLanguageCode != null) {
        emit(Locale(savedLanguageCode));
      } else {
        // No saved preference, use device language if supported
        final deviceLocale = PlatformDispatcher.instance.locale;
        final deviceLanguageCode = deviceLocale.languageCode;
        
        if (_supportedLanguages.contains(deviceLanguageCode)) {
          // Device language is supported, use it
          emit(Locale(deviceLanguageCode));
          // Save it for future use
          await prefs.setString(_localeKey, deviceLanguageCode);
          
          // Also update the preferences service for AI prompts
          final preferencesService = await PreferencesService.getInstance();
          await preferencesService.setLocale(deviceLanguageCode);
        } else {
          // Device language not supported, use English
          emit(_defaultLocale);
        }
      }
    } catch (e) {
      // If loading fails, keep the default locale
      emit(_defaultLocale);
    }
  }

  /// Change the current locale and save it to SharedPreferences
  Future<void> changeLocale(String languageCode) async {
    final newLocale = Locale(languageCode);
    
    // Emit the new locale immediately for instant UI update
    emit(newLocale);
    
    // Save to SharedPreferences asynchronously
    _saveLocalePreference(languageCode);
  }

  /// Save locale preference asynchronously without blocking UI updates
  Future<void> _saveLocalePreference(String languageCode) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_localeKey, languageCode);
      
      // Also update the preferences service for AI prompts
      final preferencesService = await PreferencesService.getInstance();
      await preferencesService.setLocale(languageCode);
    } catch (e) {
      // Even if saving fails, the locale change is already applied
      // Logging error silently
    }
  }

  /// Toggle between English and French
  Future<void> toggleLanguage() async {
    final currentLanguage = state.languageCode;
    final newLanguage = currentLanguage == 'en' ? 'fr' : 'en';
    await changeLocale(newLanguage);
  }

  /// Check if current locale is English
  bool get isEnglish => state.languageCode == 'en';

  /// Check if current locale is French
  bool get isFrench => state.languageCode == 'fr';

  /// Check if current locale is Spanish
  bool get isSpanish => state.languageCode == 'es';

  /// Get the current language name for display
  String get currentLanguageName {
    switch (state.languageCode) {
      case 'fr':
        return 'Français';
      case 'es':
        return 'Español';
      case 'en':
      default:
        return 'English';
    }
  }
}