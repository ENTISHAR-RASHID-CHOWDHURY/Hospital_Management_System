import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../localization/app_localizations.dart';

class LocalizationProvider extends ChangeNotifier {
  Locale _currentLocale = const Locale('en', 'US');

  Locale get currentLocale => _currentLocale;

  List<Locale> get supportedLocales => AppLocalizations.supportedLocales;

  Future<void> setLocale(Locale locale) async {
    if (!supportedLocales.contains(locale)) return;

    _currentLocale = locale;

    // Save to SharedPreferences
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('language_code', locale.languageCode);
    await prefs.setString('country_code', locale.countryCode ?? '');

    notifyListeners();
  }

  Future<void> loadSavedLocale() async {
    final prefs = await SharedPreferences.getInstance();
    final languageCode = prefs.getString('language_code');
    final countryCode = prefs.getString('country_code');

    if (languageCode != null) {
      final locale = Locale(languageCode, countryCode);
      if (supportedLocales.any((l) => l.languageCode == locale.languageCode)) {
        _currentLocale = locale;
        notifyListeners();
      }
    }
  }

  String getLanguageName(String languageCode) {
    final Map<String, String> languageNames = {
      'en': 'English',
      'es': 'Español',
      'fr': 'Français',
      'de': 'Deutsch',
      'zh': '中文',
      'ar': 'العربية',
      'hi': 'हिन्दी',
    };
    return languageNames[languageCode] ?? languageCode.toUpperCase();
  }

  String getLanguageFlag(String languageCode) {
    final Map<String, String> languageFlags = {
      'en': '🇺🇸',
      'es': '🇪🇸',
      'fr': '🇫🇷',
      'de': '🇩🇪',
      'zh': '🇨🇳',
      'ar': '🇸🇦',
      'hi': '🇮🇳',
    };
    return languageFlags[languageCode] ?? '🌐';
  }

  bool isRTL(String languageCode) {
    return ['ar', 'he', 'fa', 'ur'].contains(languageCode);
  }

  TextDirection getTextDirection() {
    return isRTL(_currentLocale.languageCode)
        ? TextDirection.rtl
        : TextDirection.ltr;
  }
}
