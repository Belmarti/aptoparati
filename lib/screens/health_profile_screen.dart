import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../data/health_profile_data.dart';
import '../services/user_service.dart';
import '../widgets/action_button.dart';
import 'package:aptoparati/l10n/app_localizations.dart';

/// Pantalla de edición del perfil de salud del usuario.
/// Permite modificar condiciones médicas y alérgenos.
class HealthProfileScreen extends StatefulWidget {
  const HealthProfileScreen({super.key});

  @override
  State<HealthProfileScreen> createState() => _HealthProfileScreenState();
}

class _HealthProfileScreenState extends State<HealthProfileScreen> {
  bool _isLoading = false;

  // Estado de cada condición médica: clave Firestore → activado/desactivado
  late final Map<String, bool> _conditions = {
    for (final c in kHealthConditions) c.key: false,
  };

  // Estado de cada alérgeno: clave Firestore → seleccionado/no seleccionado
  late final Map<String, bool> _allergenSelected = {
    for (final a in kAllergens) a.key: false,
  };

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  /// Carga el perfil de salud desde la caché de UserService y pre-rellena el estado.
  void _loadUserData() {
    final userData = UserService.instance.currentUserData;
    if (userData == null || userData['health_profile'] == null) return;

    final health = userData['health_profile'];
    setState(() {
      // Cargar condiciones médicas
      for (final condition in kHealthConditions) {
        _conditions[condition.key] = health[condition.key] ?? false;
      }

      // Marcar los alérgenos que el usuario tiene guardados en Firestore
      final List<dynamic> savedAllergens = health['allergens'] ?? [];
      for (final key in savedAllergens) {
        if (_allergenSelected.containsKey(key)) {
          _allergenSelected[key] = true;
        }
      }
    });
  }

  /// Guarda los cambios del perfil de salud en Firestore a través de UserService.
  /// Preserva el campo custom_restrictions para no sobreescribirlo.
  Future<void> _saveChanges() async {
    final l10n = AppLocalizations.of(context)!;
    setState(() => _isLoading = true);
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) return;

      // Filtrar solo los alérgenos seleccionados y obtener sus claves Firestore
      final selectedAllergens = kAllergens
          .where((a) => _allergenSelected[a.key] == true)
          .map((a) => a.key)
          .toList();

      final healthProfileData = {
        for (final c in kHealthConditions) c.key: _conditions[c.key] ?? false,
        'allergens': selectedAllergens,
        // Preservar custom_restrictions para no perder datos existentes
        'custom_restrictions':
            UserService.instance.currentUserData?['health_profile']
                ?['custom_restrictions'] ?? [],
      };

      await UserService.instance.updateHealthProfile(
        user.uid,
        healthProfileData,
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(l10n.healthProfileSaveSuccess)),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(l10n.healthProfileSaveError)),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.healthProfileTitle),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: const EdgeInsets.all(24.0),
              children: [
                Text(
                  l10n.healthProfileEditTitle,
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: colorScheme.primary,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  l10n.healthProfileEditDescription,
                  style: TextStyle(fontSize: 16, color: colorScheme.onSurfaceVariant),
                ),
                const SizedBox(height: 32),

                // Switch por cada condición médica definida en kHealthConditions
                ...kHealthConditions.map((condition) => Padding(
                  padding: const EdgeInsets.only(bottom: 16),
                  child: _buildSwitchTile(
                    title: localizedConditionLabel(l10n, condition.key),
                    subtitle: localizedConditionSubtitle(l10n, condition.key),
                    value: _conditions[condition.key] ?? false,
                    onChanged: (val) =>
                        setState(() => _conditions[condition.key] = val),
                    icon: condition.icon,
                  ),
                )),

                const SizedBox(height: 16),

                Text(
                  l10n.allergiesAndIntolerances,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: colorScheme.onSurface,
                  ),
                ),
                const SizedBox(height: 16),

                // Chips seleccionables, uno por cada alérgeno definido en kAllergens
                Wrap(
                  spacing: 12,
                  runSpacing: 12,
                  children: kAllergens.map((allergen) {
                    final selected = _allergenSelected[allergen.key] ?? false;
                    return FilterChip(
                      label: Text(localizedAllergenLabel(l10n, allergen.key)),
                      selected: selected,
                      onSelected: (val) =>
                          setState(() => _allergenSelected[allergen.key] = val),
                      selectedColor: colorScheme.primary.withValues(alpha: 0.2),
                      checkmarkColor: colorScheme.primary,
                      labelStyle: TextStyle(
                        color: selected ? colorScheme.primary : colorScheme.onSurface,
                        fontWeight:
                            selected ? FontWeight.bold : FontWeight.normal,
                      ),
                    );
                  }).toList(),
                ),

                const SizedBox(height: 48),

                ActionButton(text: l10n.healthProfileSaveButton, onPressed: _saveChanges),
              ],
            ),
    );
  }

  /// Construye un tile con switch estilizado para condiciones médicas.
  /// Cambia el borde y la sombra según si está activado o no.
  Widget _buildSwitchTile({
    required String title,
    String? subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
    required IconData icon,
  }) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: value ? colorScheme.primary : colorScheme.outlineVariant,
          width: value ? 2.0 : 1.0,
        ),
        boxShadow: value
            ? [
                BoxShadow(
                  color: colorScheme.primary.withValues(alpha: 0.1),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ]
            : [],
      ),
      child: SwitchListTile(
        title: Text(
          title,
          style: TextStyle(
            fontWeight: value ? FontWeight.bold : FontWeight.normal,
            color: value ? colorScheme.primary : colorScheme.onSurface,
          ),
        ),
        subtitle: subtitle != null ? Text(subtitle) : null,
        value: value,
        onChanged: onChanged,
        secondary: Icon(icon, color: value ? colorScheme.primary : colorScheme.onSurfaceVariant),
        activeThumbColor: colorScheme.primary,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }
}
