import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Gestiona el tema activo de la aplicación (estándar vs. baja visión).
/// Persiste la preferencia en SharedPreferences para conservarla entre sesiones.
class ThemeService extends ChangeNotifier {
  static const String _key = 'low_vision_mode';

  bool _isLowVision = false;

  bool get isLowVision => _isLowVision;

  /// Carga la preferencia guardada. Llamar una vez al inicio antes de runApp.
  Future<void> loadFromPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    _isLowVision = prefs.getBool(_key) ?? false;
    notifyListeners();
  }

  /// Alterna entre modo estándar y baja visión, y persiste la elección.
  /// La UI reacciona de forma inmediata gracias a [notifyListeners].
  Future<void> toggle() async {
    _isLowVision = !_isLowVision;
    // Notificar primero → el cambio visual es instantáneo
    notifyListeners();
    // Persistir en segundo plano (fire & forget)
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_key, _isLowVision);
  }
}
