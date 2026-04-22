import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../services/user_service.dart';
import 'health_profile_screen.dart';
import 'login_screen.dart';

/// Pantalla hub de configuración del usuario.
/// Agrupa las secciones: perfil de salud, accesibilidad e idioma.
class UserConfigScreen extends StatefulWidget {
  const UserConfigScreen({super.key});

  @override
  State<UserConfigScreen> createState() => _UserConfigScreenState();
}

class _UserConfigScreenState extends State<UserConfigScreen> {
  // Opciones de accesibilidad (sin backend por ahora)
  bool _lowVisionMode = false;

  // Idioma seleccionado (sin backend por ahora)
  String _selectedLanguage = 'es';

  /// Devuelve el nombre del usuario o su email como fallback.
  String get _displayName {
    final userData = UserService.instance.currentUserData;
    final name = userData?['personal_info']?['name'] as String?;
    if (name != null && name.trim().isNotEmpty) return name.trim();
    // Fallback: email del usuario autenticado
    return FirebaseAuth.instance.currentUser?.email ?? '';
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Configuración'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: Colors.black,
      ),
      backgroundColor: Colors.grey[100],
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        children: [
          // Cabecera con avatar y nombre/email del usuario
          _buildUserHeader(colorScheme),
          const SizedBox(height: 28),

          // Card: Perfil de salud
          _buildHealthProfileCard(colorScheme),
          const SizedBox(height: 16),

          // Card: Accesibilidad
          _buildAccessibilityCard(colorScheme),
          const SizedBox(height: 16),

          // Card: Idioma
          _buildLanguageCard(colorScheme),
        ],
      ),
    );
  }

  /// Cabecera con avatar circular y nombre/email del usuario.
  Widget _buildUserHeader(ColorScheme colorScheme) {
    return Row(
      children: [
        CircleAvatar(
          radius: 32,
          backgroundColor: colorScheme.primary,
          child: Text(
            _displayName.isNotEmpty ? _displayName[0].toUpperCase() : '?',
            style: const TextStyle(
              fontSize: 26,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      _displayName,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  // Botón de cerrar sesión alineado a la derecha del nombre
                  TextButton.icon(
                    onPressed: _signOut,
                    icon: const Icon(Icons.logout, size: 18),
                    label: const Text('Salir', style: TextStyle(fontSize: 16)),
                    style: TextButton.styleFrom(
                      foregroundColor: const Color.fromARGB(255, 231, 81, 78),
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                      minimumSize: Size.zero,
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Text(
                'Tu perfil de configuración',
                style: TextStyle(fontSize: 13, color: Colors.grey[600]),
              ),
            ],
          ),
        ),
      ],
    );
  }

  /// Cierra la sesión del usuario y navega a la pantalla de login.
  Future<void> _signOut() async {
    await FirebaseAuth.instance.signOut();
    UserService.instance.clear();
    if (!mounted) return;
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => const LoginScreen()),
      (_) => false,
    );
  }

  /// Card navegable hacia la pantalla de edición del perfil de salud.
  Widget _buildHealthProfileCard(ColorScheme colorScheme) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      color: Colors.white,
      child: ListTile(
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        leading: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: colorScheme.primary.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(Icons.favorite_outline, color: colorScheme.primary),
        ),
        title: const Text(
          'Perfil de Salud',
          style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
        ),
        subtitle: Text(
          'Condiciones médicas y alergias',
          style: TextStyle(color: Colors.grey[600], fontSize: 13),
        ),
        trailing: Icon(Icons.chevron_right, color: Colors.grey[400]),
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const HealthProfileScreen()),
        ),
      ),
    );
  }

  /// Card de accesibilidad con switch para modo baja visión.
  /// Sin backend — solo estado local por ahora.
  Widget _buildAccessibilityCard(ColorScheme colorScheme) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      color: Colors.white,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding:
                const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: colorScheme.primary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(Icons.accessibility_new_outlined,
                      color: colorScheme.primary),
                ),
                const SizedBox(width: 16),
                const Text(
                  'Accesibilidad',
                  style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
                ),
              ],
            ),
          ),
          const Divider(height: 1, indent: 20, endIndent: 20),
          SwitchListTile(
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
            title: const Text(
              'Modo baja visión',
              style: TextStyle(fontSize: 15),
            ),
            subtitle: Text(
              'Aumenta el contraste y el tamaño del texto',
              style: TextStyle(fontSize: 12, color: Colors.grey[600]),
            ),
            value: _lowVisionMode,
            onChanged: (val) => setState(() => _lowVisionMode = val),
            activeColor: colorScheme.primary,
          ),
          const SizedBox(height: 4),
        ],
      ),
    );
  }

  /// Card de selección de idioma (español, inglés, francés).
  /// Sin backend — solo estado local por ahora.
  Widget _buildLanguageCard(ColorScheme colorScheme) {
    final languages = [
      ('es', 'Español'),
      ('en', 'Inglés'),
      ('fr', 'Francés'),
    ];

    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      color: Colors.white,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding:
                const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: colorScheme.primary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(Icons.language_outlined,
                      color: colorScheme.primary),
                ),
                const SizedBox(width: 16),
                const Text(
                  'Idioma',
                  style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
                ),
              ],
            ),
          ),
          const Divider(height: 1, indent: 20, endIndent: 20),
          // Opciones de idioma como radio buttons
          ...languages.map(
            (lang) => RadioListTile<String>(
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 20, vertical: 0),
              title: Text(lang.$2, style: const TextStyle(fontSize: 15)),
              value: lang.$1,
              groupValue: _selectedLanguage,
              onChanged: (val) {
                if (val != null) setState(() => _selectedLanguage = val);
              },
              activeColor: colorScheme.primary,
            ),
          ),
          const SizedBox(height: 4),
        ],
      ),
    );
  }
}
