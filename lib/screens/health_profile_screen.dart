import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../data/health_profile_data.dart';
import '../services/user_service.dart';
import '../widgets/action_button.dart';

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
          const SnackBar(content: Text('Cambios guardados correctamente')),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Error al guardar cambios')),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final primaryColor = Theme.of(context).colorScheme.primary;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Perfil de Salud'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: Colors.black,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: const EdgeInsets.all(24.0),
              children: [
                Text(
                  'Modifica tus datos',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: primaryColor,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Actualiza tu perfil para recibir recomendaciones precisas.',
                  style: TextStyle(fontSize: 16, color: Colors.grey[600]),
                ),
                const SizedBox(height: 32),

                // Switch por cada condición médica definida en kHealthConditions
                ...kHealthConditions.map((condition) => Padding(
                  padding: const EdgeInsets.only(bottom: 16),
                  child: _buildSwitchTile(
                    title: condition.label,
                    subtitle: condition.subtitle,
                    value: _conditions[condition.key] ?? false,
                    onChanged: (val) =>
                        setState(() => _conditions[condition.key] = val),
                    icon: condition.icon,
                  ),
                )),

                const SizedBox(height: 16),

                Text(
                  'Alergias e Intolerancias',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: Colors.grey[800],
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
                      label: Text(allergen.label),
                      selected: selected,
                      onSelected: (val) =>
                          setState(() => _allergenSelected[allergen.key] = val),
                      selectedColor: primaryColor.withValues(alpha: 0.2),
                      checkmarkColor: primaryColor,
                      labelStyle: TextStyle(
                        color: selected ? primaryColor : Colors.black87,
                        fontWeight:
                            selected ? FontWeight.bold : FontWeight.normal,
                      ),
                    );
                  }).toList(),
                ),

                const SizedBox(height: 48),

                ActionButton(text: 'Guardar Cambios', onPressed: _saveChanges),
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
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: value ? colorScheme.primary : Colors.grey.shade300,
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
            color: value ? colorScheme.primary : Colors.black87,
          ),
        ),
        subtitle: subtitle != null ? Text(subtitle) : null,
        value: value,
        onChanged: onChanged,
        secondary: Icon(icon, color: value ? colorScheme.primary : Colors.grey),
        activeThumbColor: colorScheme.primary,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }
}
