import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../widgets/action_button.dart';
import 'login_screen.dart';

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
  bool _isLoading = false;

  // Health Profile State
  bool _isDiabetic = false;
  bool _isCeliac = false; // "has_celiac_disease"

  // Allergens Selection
  final Map<String, bool> _allergens = {
    'Frutos secos': false, // nuts
    'Lactosa': false, // lactose
    'Marisco': false, // shellfish
    'Huevo': false, // egg
    'Soja': false, // soy
    'Pescado': false, // fish
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

  Future<void> _register() async {
    setState(() => _isLoading = true);

    try {
      // 1. Create Auth User
      final userCredential = await FirebaseAuth.instance
          .createUserWithEmailAndPassword(
            email: widget.email,
            password: widget.password,
          );

      final uid = userCredential.user!.uid;
      final now = Timestamp.now();

      // 2. Prepare Data for Firestore
      final selectedAllergens = _allergens.entries
          .where((entry) => entry.value)
          .map((entry) => _allergenKeys[entry.key]!)
          .toList();

      final userData = {
        "personal_info": {
          "email": widget.email,
          "name": widget.name,
          "created_at": now,
          "last_login": now,
        },
        "subscription": {
          "status": "free",
          "plan_id": "basic", // Default to basic
          "expiry_date": null,
        },
        "health_profile": {
          "is_diabetic": _isDiabetic,
          "has_celiac_disease": _isCeliac,
          "allergens": selectedAllergens,
          "custom_restrictions": [],
        },
        "stats": {"scans_today": 0, "last_scan_date": now},
      };

      // 3. Save to Firestore
      await FirebaseFirestore.instance
          .collection('users')
          .doc(uid)
          .set(userData);

      if (mounted) {
        // Navigation to Home or Login (Currently Login, usually Home)
        // For now, let's pop to root (Login) and show success, or navigate to Home if we had one ready.
        // Since main.dart points to LoginScreen, and we are logged in, we might want to navigate to a Home screen.
        // But for this task, I will navigate to LoginScreen (clear stack) to simulate "Log in now" or just go to Home?
        // Let's assume we go back to LoginScreen for now as flow confirmation,
        // OR effectively since we are authenticated, we could just stay logged in.
        // Let's go to LoginScreen for simplicity of the flow request "Acceda desde el login".

        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (context) => const LoginScreen()),
          (Route<dynamic> route) => false,
        );

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Cuenta creada con éxito')),
        );
      }
    } on FirebaseAuthException catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error: ${e.message}')));
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error al crear perfil: $e')));
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

                ActionButton(text: 'Finalizar Registro', onPressed: _register),
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
