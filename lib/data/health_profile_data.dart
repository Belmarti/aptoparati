import 'package:aptoparati/l10n/app_localizations.dart';

/// Representa un alérgeno disponible para seleccionar en el perfil de salud.
/// [key] es la clave que se guarda en Firestore.
/// [label] es el texto de respaldo en español (no usar directamente en UI).
class Allergen {
  final String key;
  final String label;

  const Allergen({required this.key, required this.label});
}

/// Representa una condición médica configurable en el perfil de salud.
/// [key] es la clave que se guarda en Firestore.
/// [label] es el texto de respaldo en español (no usar directamente en UI).
/// [subtitle] es una descripción opcional de respaldo.
/// [iconAsset] es la ruta del asset SVG que acompaña al switch.
class HealthCondition {
  final String key;
  final String label;
  final String? subtitle;
  final String iconAsset;

  const HealthCondition({
    required this.key,
    required this.label,
    this.subtitle,
    required this.iconAsset,
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
    iconAsset: 'assets/icons/sugar.svg',
  ),
  HealthCondition(
    key: 'has_celiac_disease',
    label: 'Soy celíaco',
    subtitle: 'Evitar gluten estrictamente',
    iconAsset: 'assets/icons/gluten.svg',
  ),
];

/// Devuelve la etiqueta localizada del alérgeno según su clave de Firestore.
String localizedAllergenLabel(AppLocalizations l10n, String key) {
  switch (key) {
    case 'nuts':      return l10n.allergenNuts;
    case 'lactose':   return l10n.allergenLactose;
    case 'shellfish': return l10n.allergenShellfish;
    case 'egg':       return l10n.allergenEgg;
    case 'soy':       return l10n.allergenSoy;
    case 'fish':      return l10n.allergenFish;
    default:          return key;
  }
}

/// Devuelve la etiqueta localizada de la condición médica según su clave de Firestore.
String localizedConditionLabel(AppLocalizations l10n, String key) {
  switch (key) {
    case 'is_diabetic':       return l10n.conditionDiabetic;
    case 'has_celiac_disease': return l10n.conditionCeliac;
    default:                  return key;
  }
}

/// Devuelve el subtítulo localizado de la condición médica, o null si no tiene.
String? localizedConditionSubtitle(AppLocalizations l10n, String key) {
  switch (key) {
    case 'has_celiac_disease': return l10n.conditionCeliacSubtitle;
    default:                   return null;
  }
}
