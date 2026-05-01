import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:provider/provider.dart';
import '../services/user_service.dart';
import '../services/theme_service.dart';
import 'health_profile_screen.dart';
import 'login_screen.dart';
import 'package:aptoparati/l10n/app_localizations.dart';

/// Pantalla hub de configuración del usuario.
/// Agrupa las secciones: perfil de salud, accesibilidad e idioma.
class UserConfigScreen extends StatefulWidget {
  const UserConfigScreen({super.key});

  @override
  State<UserConfigScreen> createState() => _UserConfigScreenState();
}

class _UserConfigScreenState extends State<UserConfigScreen> {
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
    final l10n = AppLocalizations.of(context)!;
    final colorScheme = Theme.of(context).colorScheme;
    final themeService = context.watch<ThemeService>();

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.configTitle),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        children: [
          // Cabecera con avatar y nombre/email del usuario
          _buildUserHeader(colorScheme, l10n),
          const SizedBox(height: 28),

          // Card: Perfil de salud
          _buildHealthProfileCard(colorScheme, l10n),
          const SizedBox(height: 16),

          // Card: Accesibilidad
          _buildAccessibilityCard(colorScheme, l10n, themeService),
          const SizedBox(height: 16),

          // Card: Idioma
          _buildLanguageCard(colorScheme, l10n),
        ],
      ),
    );
  }

  /// Cabecera con avatar circular y nombre/email del usuario.
  Widget _buildUserHeader(ColorScheme colorScheme, AppLocalizations l10n) {
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
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: colorScheme.onSurface,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  // Botón de cerrar sesión alineado a la derecha del nombre
                  TextButton.icon(
                    onPressed: _signOut,
                    icon: const Icon(Icons.logout, size: 18),
                    label: Text(l10n.configSignOut),
                    style: TextButton.styleFrom(
                      foregroundColor: const Color.fromARGB(255, 231, 81, 78),
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                      minimumSize: Size.zero,
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      // Fija el tamaño de fuente para que el tema de baja visión
                      // (fontSize 21, minimumSize 48dp) no infle este botón
                      // y desborde el Row del header.
                      textStyle: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Text(
                l10n.configSubtitle,
                style: TextStyle(fontSize: 13, color: colorScheme.onSurfaceVariant),
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
  Widget _buildHealthProfileCard(ColorScheme colorScheme, AppLocalizations l10n) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
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
        title: Text(
          l10n.healthProfileTitle,
          style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
        ),
        subtitle: Text(
          l10n.configHealthProfileSubtitle,
          style: TextStyle(color: colorScheme.onSurfaceVariant, fontSize: 13),
        ),
        trailing: Icon(Icons.chevron_right, color: colorScheme.onSurfaceVariant),
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const HealthProfileScreen()),
        ),
      ),
    );
  }

  /// Card de accesibilidad con switch para modo baja visión.
  /// El cambio se aplica de forma inmediata vía [ThemeService] + Provider.
  Widget _buildAccessibilityCard(ColorScheme colorScheme, AppLocalizations l10n, ThemeService themeService) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
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
                Text(
                  l10n.configAccessibilityTitle,
                  style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
                ),
              ],
            ),
          ),
          const Divider(height: 1, indent: 20, endIndent: 20),
          SwitchListTile(
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
            title: Text(
              l10n.configLowVisionTitle,
              style: const TextStyle(fontSize: 15),
            ),
            subtitle: Text(
              l10n.configLowVisionSubtitle,
              style: TextStyle(fontSize: 12, color: colorScheme.onSurfaceVariant),
            ),
            value: themeService.isLowVision,
            onChanged: (_) => themeService.toggle(),
            activeColor: colorScheme.primary,
          ),
          const SizedBox(height: 4),
        ],
      ),
    );
  }

  /// Card de selección de idioma (español, inglés, francés).
  /// Sin backend — solo estado local por ahora.
  Widget _buildLanguageCard(ColorScheme colorScheme, AppLocalizations l10n) {
    final languages = [
      ('es', l10n.configLanguageSpanish),
      ('en', l10n.configLanguageEnglish),
      ('fr', l10n.configLanguageFrench),
    ];

    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
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
                Text(
                  l10n.configLanguageTitle,
                  style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
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
