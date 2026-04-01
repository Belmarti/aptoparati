import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../services/user_service.dart';
import '../widgets/camera_viewfinder.dart';
import '../widgets/dashboard_actions.dart';

import 'user_config_screen.dart';

/// Pantalla principal de la aplicación tras el login.
/// Muestra la cámara de escaneo a pantalla completa con un header flotante
/// y un panel de acciones en la parte inferior.
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {

  /// Callback que recibe el código de barras detectado por [CameraViewfinder].
  /// Por ahora muestra un AlertDialog básico — pendiente de integrar
  /// con la base de datos de productos.
  void _onBarcodeScanned(String code) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Código Detectado'),
        content: Text('Código: "$code" leído'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    final userData = UserService.instance.currentUserData;

    // Obtener nombre del usuario desde la caché de UserService
    String displayName = 'Usuario';
    String initials = 'U';

    if (userData != null && userData['personal_info'] != null) {
      displayName = userData['personal_info']['name'] ?? 'Usuario';
    }

    // Calcular inicial para el avatar: primera letra del nombre,
    // o primera letra del email como fallback
    if (displayName != 'Usuario' && displayName.isNotEmpty) {
      initials = displayName[0].toUpperCase();
    } else if (user?.email?.isNotEmpty ?? false) {
      initials = user!.email![0].toUpperCase();
    }

    // Layout en Stack: cámara de fondo, header flotante encima, panel inferior
    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          // 1. Área de cámara — ocupa todo el espacio excepto el hueco del panel inferior
          Positioned.fill(
            bottom: 100,
            child: CameraViewfinder(onScan: _onBarcodeScanned),
          ),

          // 2. Header flotante sobre la cámara con saludo y avatar del usuario
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: SafeArea(
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 24.0,
                  vertical: 16.0,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Saludo con nombre del usuario
                    Text(
                      'Hola, $displayName',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        // Sombra para legibilidad sobre la imagen de cámara
                        shadows: [
                          Shadow(
                            color: Colors.black45,
                            blurRadius: 4,
                            offset: Offset(0, 2),
                          ),
                        ],
                      ),
                    ),

                    // Avatar circular con la inicial del usuario.
                    // Al pulsar navega a UserConfigScreen.
                    GestureDetector(
                      onTap: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (context) => const UserConfigScreen(),
                          ),
                        );
                      },
                      child: Container(
                        width: 44,
                        height: 44,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white, width: 2),
                          boxShadow: const [
                            BoxShadow(
                              color: Colors.black26,
                              blurRadius: 8,
                              offset: Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Center(
                          child: Text(
                            initials,
                            style: TextStyle(
                              color: Theme.of(context).primaryColor,
                              fontWeight: FontWeight.bold,
                              fontSize: 18,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // 3. Panel de acciones inferior con Buscar, Escanear e Historial
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: DashboardActions(
              onSearchTap: () {
                // Pendiente: navegar a pantalla de búsqueda
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Buscador: Próximamente')),
                );
              },
              onHistoryTap: () {
                // Pendiente: navegar a pantalla de historial de escaneos
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Historial: Próximamente')),
                );
              },
              onScanTap: () {
                // La cámara ya está activa continuamente — este botón
                // sirve de recordatorio visual al usuario
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('La cámara ya está activa para escanear'),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
