import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../data/health_profile_data.dart';
import '../widgets/action_button.dart';
import 'login_screen.dart';
import 'package:aptoparati/l10n/app_localizations.dart';

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
    final l10n = AppLocalizations.of(context)!;
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
          SnackBar(content: Text(l10n.healthProfileAccountCreated)),
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
    final l10n = AppLocalizations.of(context)!;
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.healthProfileTitle),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      // Mientras se ejecuta el registro, mostrar spinner en lugar del formulario
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: const EdgeInsets.all(24.0),
              children: [
                Text(
                  l10n.healthProfileQuestion,
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: colorScheme.primary,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  l10n.healthProfileDescription,
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
                    iconAsset: condition.iconAsset,
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

                // Botón que dispara el proceso de registro completo
                ActionButton(text: l10n.healthProfileFinishButton, onPressed: _register),
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
    required String iconAsset,
  }) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        // Borde primario y más grueso cuando está activado, outline cuando no
        border: Border.all(
          color: value ? colorScheme.primary : colorScheme.outlineVariant,
          width: value ? 2.0 : 1.0,
        ),
        // Sombra suave solo cuando está activado
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
        secondary: SvgPicture.asset(
          iconAsset,
          width: 24,
          height: 24,
          colorFilter: ColorFilter.mode(
            value ? colorScheme.primary : colorScheme.onSurfaceVariant,
            BlendMode.srcIn,
          ),
        ),
        activeThumbColor: colorScheme.primary,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }
}
