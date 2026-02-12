import 'package:flutter/material.dart';

import 'package:firebase_auth/firebase_auth.dart';
import '../services/user_service.dart';

class UserConfigScreen extends StatefulWidget {
  const UserConfigScreen({super.key});

  @override
  State<UserConfigScreen> createState() => _UserConfigScreenState();
}

class _UserConfigScreenState extends State<UserConfigScreen> {
  final User? user = FirebaseAuth.instance.currentUser;
  bool _isLoading = true;
  bool _isSaving = false;

  // Local state for edits
  bool _isDiabetic = false;
  bool _isCeliac = false;
  List<String> _selectedAllergens = [];

  // Available allergens (display name -> key)
  final Map<String, String> _allergenMap = {
    'Frutos secos': 'nuts',
    'Lactosa': 'lactose',
    'Marisco': 'shellfish',
    'Huevo': 'egg',
    'Soja': 'soy',
    'Pescado': 'fish',
  };

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  void _loadUserData() {
    // Load from cache instead of Firestore
    final data = UserService.instance.currentUserData;

    if (data != null && data.containsKey('health_profile')) {
      final health = data['health_profile'] as Map<String, dynamic>;
      setState(() {
        _isDiabetic = health['is_diabetic'] ?? false;
        _isCeliac = health['has_celiac_disease'] ?? false;
        _selectedAllergens = List<String>.from(health['allergens'] ?? []);
      });
    }

    setState(() => _isLoading = false);
  }

  Future<void> _saveChanges() async {
    if (user == null) return;
    setState(() => _isSaving = true);

    try {
      final newHealthProfile = {
        'is_diabetic': _isDiabetic,
        'has_celiac_disease': _isCeliac,
        'allergens': _selectedAllergens,
        'custom_restrictions': [],
      };

      await UserService.instance.updateHealthProfile(
        user!.uid,
        newHealthProfile,
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Cambios guardados correctamente')),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error al guardar: $e')));
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  void _toggleAllergen(String key) {
    setState(() {
      if (_selectedAllergens.contains(key)) {
        _selectedAllergens.remove(key);
      } else {
        _selectedAllergens.add(key);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final primaryColor = Theme.of(context).colorScheme.primary;

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text(
          'Configuración de Salud',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
        ),
        backgroundColor: Colors.transparent, // Modern transparent app bar
        elevation: 0,
        centerTitle: true,
        actions: [
          if (!_isLoading)
            IconButton(
              icon: _isSaving
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(
                      Icons.check_rounded,
                      color: Colors.green,
                      size: 28,
                    ),
              onPressed: _isSaving ? null : _saveChanges,
              tooltip: 'Guardar cambios',
            ),
          const SizedBox(width: 16),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Perfil de Intolerancias',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey[800],
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Personaliza tus restricciones para obtener mejores recomendaciones.',
                    style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                  ),
                  const SizedBox(height: 24),

                  // Bento Grid Layout
                  // Row 1: Diabetes (Large) + Celiac (Large)
                  Row(
                    children: [
                      Expanded(
                        child: _BentoTile(
                          title: 'Diabético',
                          subtitle: 'Monitor de azúcar',
                          isActive: _isDiabetic,
                          onTap: () =>
                              setState(() => _isDiabetic = !_isDiabetic),
                          icon: Icons.bloodtype_outlined,
                          activeColor: Colors.redAccent.shade100,
                          iconColor: Colors.red,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _BentoTile(
                          title: 'Celíaco',
                          subtitle: 'Sin Gluten',
                          isActive: _isCeliac,
                          onTap: () => setState(() => _isCeliac = !_isCeliac),
                          icon: Icons.bakery_dining_outlined,
                          activeColor: Colors.orangeAccent.shade100,
                          iconColor: Colors.orange,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 12),

                  // Section Title for Allergens
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 8.0),
                    child: Text(
                      'Alergias Comunes',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: Colors.black87,
                      ),
                    ),
                  ),

                  // Row 2: Allergens Grid
                  GridView.count(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    crossAxisCount: 2,
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                    childAspectRatio: 1.5, // Wider cards
                    children: _allergenMap.entries.map((entry) {
                      final name = entry.key;
                      final key = entry.value;
                      final isSelected = _selectedAllergens.contains(key);

                      return _BentoTile(
                        title: name,
                        isActive: isSelected,
                        onTap: () => _toggleAllergen(key),
                        icon: Icons.warning_amber_rounded, // Generic icon
                        activeColor: primaryColor.withOpacity(0.2),
                        iconColor: primaryColor,
                        isCompact: true,
                      );
                    }).toList(),
                  ),
                ],
              ),
            ),
    );
  }
}

// Reusable Bento Tile Widget
class _BentoTile extends StatelessWidget {
  final String title;
  final String? subtitle;
  final bool isActive;
  final VoidCallback onTap;
  final IconData icon;
  final Color activeColor;
  final Color iconColor;
  final bool isCompact;

  const _BentoTile({
    required this.title,
    this.subtitle,
    required this.isActive,
    required this.onTap,
    required this.icon,
    required this.activeColor,
    required this.iconColor,
    this.isCompact = false,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeInOut,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isActive ? activeColor : Colors.white,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: isActive ? iconColor : Colors.transparent,
            width: 2,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Icon(
                  icon,
                  color: isActive ? iconColor : Colors.grey[400],
                  size: isCompact ? 24 : 32,
                ),
                if (isActive)
                  Icon(Icons.check_circle, color: iconColor, size: 20),
              ],
            ),
            if (!isCompact) const Spacer(),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: isCompact ? 16 : 18,
                    fontWeight: FontWeight.bold,
                    color: isActive ? Colors.black87 : Colors.grey[700],
                  ),
                ),
                if (subtitle != null) ...[
                  const SizedBox(height: 4),
                  Text(
                    subtitle!,
                    style: TextStyle(
                      fontSize: 12,
                      color: isActive ? Colors.black54 : Colors.grey[500],
                    ),
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }
}
