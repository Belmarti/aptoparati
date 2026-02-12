import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../services/user_service.dart';
import '../widgets/action_button.dart'; // Assuming this exists based on intolerances_screen
import 'login_screen.dart'; // For logout navigation if needed

class UserConfigScreen extends StatefulWidget {
  const UserConfigScreen({super.key});

  @override
  State<UserConfigScreen> createState() => _UserConfigScreenState();
}

class _UserConfigScreenState extends State<UserConfigScreen> {
  bool _isLoading = false;

  // Health Profile State
  bool _isDiabetic = false;
  bool _isCeliac = false;

  // Allergens Selection
  final Map<String, bool> _allergens = {
    'Frutos secos': false,
    'Lactosa': false,
    'Marisco': false,
    'Huevo': false,
    'Soja': false,
    'Pescado': false,
  };

  // Mapping display names to backend keys
  final Map<String, String> _allergenKeys = {
    'Frutos secos': 'nuts',
    'Lactosa': 'lactose',
    'Marisco': 'shellfish',
    'Huevo': 'egg',
    'Soja': 'soy',
    'Pescado': 'fish',
  };

  // Inverse mapping for loading data
  final Map<String, String> _backendKeysToDisplay = {
    'nuts': 'Frutos secos',
    'lactose': 'Lactosa',
    'shellfish': 'Marisco',
    'egg': 'Huevo',
    'soy': 'Soja',
    'fish': 'Pescado',
  };

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  void _loadUserData() {
    final userData = UserService.instance.currentUserData;
    if (userData != null && userData['health_profile'] != null) {
      final health = userData['health_profile'];
      setState(() {
        _isDiabetic = health['is_diabetic'] ?? false;
        _isCeliac = health['has_celiac_disease'] ?? false;

        final List<dynamic> savedAllergens = health['allergens'] ?? [];
        for (var backendKey in savedAllergens) {
          final displayKey = _backendKeysToDisplay[backendKey];
          if (displayKey != null && _allergens.containsKey(displayKey)) {
            _allergens[displayKey] = true;
          }
        }
      });
    }
  }

  Future<void> _saveChanges() async {
    setState(() => _isLoading = true);
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) return;

      final selectedAllergens = _allergens.entries
          .where((entry) => entry.value)
          .map((entry) => _allergenKeys[entry.key]!)
          .toList();

      final healthProfileData = {
        'is_diabetic': _isDiabetic,
        'has_celiac_disease': _isCeliac,
        'allergens': selectedAllergens,
        // Preserve other fields if any, but currently we are overwriting the map in UserService
        // Ideally we should merge, but UserService.updateHealthProfile implementation
        // suggests we are passing the full map or it updates the field.
        // Let's check UserService implementation detail again if needed.
        // Based on previous read, it does: .update({'health_profile': healthProfileData})
        // So we need to be careful not to lose 'custom_restrictions' if it exists.
        // Let's try to preserve it from current data.
        'custom_restrictions':
            UserService
                .instance
                .currentUserData?['health_profile']?['custom_restrictions'] ??
            [],
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
        title: const Text('Configuración Médica'),
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

                // Diabetic Switch
                _buildSwitchTile(
                  title: 'Soy diabético',
                  value: _isDiabetic,
                  onChanged: (val) => setState(() => _isDiabetic = val),
                  icon: Icons.monitor_heart_outlined,
                ),

                const SizedBox(height: 16),

                // Celiac Switch
                _buildSwitchTile(
                  title: 'Soy celíaco',
                  subtitle: 'Evitar gluten estrictamente',
                  value: _isCeliac,
                  onChanged: (val) => setState(() => _isCeliac = val),
                  icon: Icons.no_meals_outlined,
                ),

                const SizedBox(height: 32),

                Text(
                  'Alergias e Intolerancias',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: Colors.grey[800],
                  ),
                ),
                const SizedBox(height: 16),

                Wrap(
                  spacing: 12,
                  runSpacing: 12,
                  children: _allergens.keys.map((key) {
                    return FilterChip(
                      label: Text(key),
                      selected: _allergens[key]!,
                      onSelected: (bool selected) {
                        setState(() {
                          _allergens[key] = selected;
                        });
                      },
                      selectedColor: primaryColor.withOpacity(0.2),
                      checkmarkColor: primaryColor,
                      labelStyle: TextStyle(
                        color: _allergens[key]! ? primaryColor : Colors.black87,
                        fontWeight: _allergens[key]!
                            ? FontWeight.bold
                            : FontWeight.normal,
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
                  color: colorScheme.primary.withOpacity(0.1),
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
        activeColor: colorScheme.primary,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }
}
