import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Gestiona el idioma activo de la aplicación.
/// Persiste la preferencia en SharedPreferences para conservarla entre sesiones.
class LocaleService extends ChangeNotifier {
  static const String _key = 'app_locale';

  Locale _locale = const Locale('es');

  Locale get locale => _locale;
  String get languageCode => _locale.languageCode;

  /// Carga la preferencia guardada. Llamar una vez al inicio antes de runApp.
  Future<void> loadFromPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    final code = prefs.getString(_key) ?? 'es';
    _locale = Locale(code);
    notifyListeners();
  }

  /// Cambia el idioma activo y lo persiste.
  Future<void> setLocale(String languageCode) async {
    if (_locale.languageCode == languageCode) return;
    _locale = Locale(languageCode);
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_key, languageCode);
  }
}
