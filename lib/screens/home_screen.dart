import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../services/user_service.dart';
import '../widgets/camera_viewfinder.dart';
import '../widgets/dashboard_actions.dart';

import 'user_config_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
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

    // Get user name or initials
    String displayName = 'Usuario';
    String initials = 'U';

    if (userData != null && userData['personal_info'] != null) {
      displayName = userData['personal_info']['name'] ?? 'Usuario';
    }

    if (displayName != 'Usuario' && displayName.isNotEmpty) {
      initials = displayName[0].toUpperCase();
    } else if (user?.email?.isNotEmpty ?? false) {
      initials = user!.email![0].toUpperCase();
    }

    return Scaffold(
      backgroundColor: Colors.white, // Or a very light grey
      body: Stack(
        children: [
          // 1. Camera / Scanner Area
          // It takes up the space above the bottom sheet
          Positioned.fill(
            bottom: 100, // Leave space for the curved overlap
            child: CameraViewfinder(onScan: _onBarcodeScanned),
          ),

          // 2. Top Header (Floating)
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
                    // Greeting / Logo
                    Text(
                      'Hola, $displayName',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        shadows: [
                          Shadow(
                            color: Colors.black45,
                            blurRadius: 4,
                            offset: Offset(0, 2),
                          ),
                        ],
                      ),
                    ),

                    // User Avatar
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

          // 3. Bottom Actions (Overlapping)
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: DashboardActions(
              onSearchTap: () {
                // Navigate to search
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Buscador: Próximamente')),
                );
              },
              onHistoryTap: () {
                // Navigate to history
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Historial: Próximamente')),
                );
              },
              onScanTap: () {
                // Trigger Scan
                // Since scanner is always active in background for this design,
                // this button might just focus it or be redundant based on UI,
                // but let's keep it as "Feedback" or "Reset Focus".
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
