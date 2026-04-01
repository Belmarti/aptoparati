import 'package:flutter/material.dart';

/// Representa un alérgeno disponible para seleccionar en el perfil de salud.
/// [key] es la clave que se guarda en Firestore.
/// [label] es el texto que se muestra en la UI (español).
class Allergen {
  final String key;
  final String label;

  const Allergen({required this.key, required this.label});
}

/// Representa una condición médica configurable en el perfil de salud.
/// [key] es la clave que se guarda en Firestore.
/// [label] es el texto principal que se muestra en la UI (español).
/// [subtitle] es una descripción opcional que aparece bajo el título.
/// [icon] es el icono que acompaña al switch.
class HealthCondition {
  final String key;
  final String label;
  final String? subtitle;
  final IconData icon;

  const HealthCondition({
    required this.key,
    required this.label,
    this.subtitle,
    required this.icon,
  });
}

/// Lista de alérgenos disponibles en la aplicación.
const List<Allergen> kAllergens = [
  Allergen(key: 'nuts',      label: 'Frutos secos'),
  Allergen(key: 'lactose',   label: 'Lactosa'),
  Allergen(key: 'shellfish', label: 'Marisco'),
  Allergen(key: 'egg',       label: 'Huevo'),
  Allergen(key: 'soy',       label: 'Soja'),
  Allergen(key: 'fish',      label: 'Pescado'),
];

/// Lista de condiciones médicas disponibles en la aplicación.
const List<HealthCondition> kHealthConditions = [
  HealthCondition(
    key: 'is_diabetic',
    label: 'Soy diabético',
    icon: Icons.monitor_heart_outlined,
  ),
  HealthCondition(
    key: 'has_celiac_disease',
    label: 'Soy celíaco',
    subtitle: 'Evitar gluten estrictamente',
    icon: Icons.no_meals_outlined,
  ),
];
