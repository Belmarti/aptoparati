import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../data/health_profile_data.dart';
import '../widgets/action_button.dart';
import 'login_screen.dart';

/// Pantalla del paso 2 del registro.
/// Recibe los datos personales del paso 1 (nombre, email, contraseña) y
/// permite al usuario configurar su perfil de salud antes de crear la cuenta.
class IntolerancesScreen extends StatefulWidget {
  final String name;
  final String email;
  final String password;

  const IntolerancesScreen({
    super.key,
    required this.name,
    required this.email,
    required this.password,
  });

  @override
  State<IntolerancesScreen> createState() => _IntolerancesScreenState();
}

class _IntolerancesScreenState extends State<IntolerancesScreen> {
  // Controla el indicador de carga durante el registro
  bool _isLoading = false;

  // Estado de cada condición médica: clave Firestore → activado/desactivado
  late final Map<String, bool> _conditions = {
    for (final c in kHealthConditions) c.key: false,
  };

  // Estado de cada alérgeno: clave Firestore → seleccionado/no seleccionado
  late final Map<String, bool> _allergenSelected = {
    for (final a in kAllergens) a.key: false,
  };

  /// Ejecuta el proceso completo de registro en dos pasos:
  /// 1. Crea el usuario en Firebase Auth con email y contraseña.
  /// 2. Guarda el documento del usuario en Firestore con su perfil de salud.
  /// Si todo va bien, redirige al LoginScreen y limpia la pila de navegación.
  Future<void> _register() async {
    setState(() => _isLoading = true);

    try {
      // Paso 1: crear la cuenta en Firebase Auth
      final userCredential = await FirebaseAuth.instance
          .createUserWithEmailAndPassword(
            email: widget.email,
            password: widget.password,
          );

      final uid = userCredential.user!.uid;
      final now = Timestamp.now();

      // Filtrar solo los alérgenos que el usuario marcó como activos
      final selectedAllergens = kAllergens
          .where((a) => _allergenSelected[a.key] == true)
          .map((a) => a.key)
          .toList();

      // Estructura del documento de usuario según el modelo de datos de Firestore
      final userData = {
        "personal_info": {
          "email": widget.email,
          "name": widget.name,
          "created_at": now,
          "last_login": now,
        },
        "subscription": {
          "status": "free",
          "plan_id": "basic",
          "expiry_date": null,
        },
        "health_profile": {
          "is_diabetic": _conditions['is_diabetic'] ?? false,
          "has_celiac_disease": _conditions['has_celiac_disease'] ?? false,
          "allergens": selectedAllergens,
          "custom_restrictions": [],
        },
        "stats": {"scans_today": 0, "last_scan_date": now},
      };

      // Paso 2: guardar el perfil completo en Firestore bajo el UID del usuario
      await FirebaseFirestore.instance
          .collection('users')
          .doc(uid)
          .set(userData);

      if (mounted) {
        // Navegar al LoginScreen eliminando toda la pila de navegación anterior,
        // para que el usuario no pueda volver atrás con el botón de retroceso
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (context) => const LoginScreen()),
          (Route<dynamic> route) => false,
        );

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Cuenta creada con éxito')),
        );
      }
    } on FirebaseAuthException catch (e) {
      // Error específico de Firebase Auth (email ya en uso, contraseña débil, etc.)
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: ${e.message}')),
        );
      }
    } catch (e) {
      // Error genérico, por ejemplo fallo al escribir en Firestore
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al crear perfil: $e')),
        );
      }
    } finally {
      // Siempre ocultar el indicador de carga al terminar, con éxito o error
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
      // Mientras se ejecuta el registro, mostrar spinner en lugar del formulario
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: const EdgeInsets.all(24.0),
              children: [
                Text(
                  '¿Tienes alguna restricción?',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: primaryColor,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Configura tu perfil para que podamos decirte qué productos son aptos para ti.',
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

                // Botón que dispara el proceso de registro completo
                ActionButton(text: 'Finalizar Registro', onPressed: _register),
              ],
            ),
    );
  }

  /// Construye un tile con switch estilizado para condiciones médicas.
  /// Cambia el borde y la sombra según si está activado o no,
  /// para dar feedback visual claro al usuario.
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
        // Borde verde y más grueso cuando está activado, gris y fino cuando no
        border: Border.all(
          color: value ? colorScheme.primary : Colors.grey.shade300,
          width: value ? 2.0 : 1.0,
        ),
        // Sombra verde suave solo cuando está activado
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
