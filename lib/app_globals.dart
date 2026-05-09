import 'package:flutter/material.dart';

/// Clave global del ScaffoldMessenger raíz de la aplicación.
///
/// Se pasa a [MaterialApp.scaffoldMessengerKey] en [main.dart] para poder
/// mostrar SnackBars desde cualquier punto del código sin necesidad de un
/// BuildContext válido, evitando dependencias sobre InheritedWidgets desde
/// callbacks asíncronos.
final GlobalKey<ScaffoldMessengerState> scaffoldMessengerKey =
    GlobalKey<ScaffoldMessengerState>();
