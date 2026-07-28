import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LocaleProvider extends ChangeNotifier {
  static const _key = 'locale';
  String _locale = 'en';

  String get locale => _locale;
  bool get isBangla => _locale == 'bn';

  LocaleProvider() {
    _load();
  }

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    _locale = prefs.getString(_key) ?? 'en';
    notifyListeners();
  }

  Future<void> toggle() async {
    _locale = isBangla ? 'en' : 'bn';
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_key, _locale);
  }

  Future<void> setLocale(String locale) async {
    _locale = locale;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_key, locale);
  }
}
