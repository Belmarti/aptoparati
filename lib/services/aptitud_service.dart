import 'package:openfoodfacts/openfoodfacts.dart';
import 'package:aptoparati/l10n/app_localizations.dart';

/// Resultado de comprobar si un producto es apto para el usuario.
class AptitudResult {
  /// true si el producto no supone riesgo para el perfil del usuario.
  final bool isApt;

  /// Lista de motivos concretos por los que NO es apto (vacía si lo es).
  final List<String> motivos;

  /// Tags OFF (en:gluten, en:milk…) que han activado la incompatibilidad.
  /// Usados para resaltar ingredientes en la UI.
  final Set<String> tagsIncompatibles;

  const AptitudResult({
    required this.isApt,
    required this.motivos,
    required this.tagsIncompatibles,
  });
}

/// Servicio sin estado que evalúa la aptitud de un [Product] de OFF
/// comparándolo con el health_profile del usuario almacenado en Firestore.
class AptitudService {
  AptitudService._();

  // Mapeo de las claves de alérgenos del backend → offTags del enum AllergensTag
  static final Map<String, List<String>> _allergenTags = {
    'nuts':      [AllergensTag.NUTS.offTag],
    'lactose':   [AllergensTag.MILK.offTag],
    'shellfish': [AllergensTag.CRUSTACEANS.offTag, AllergensTag.MOLLUSCS.offTag],
    'egg':       [AllergensTag.EGGS.offTag],
    'soy':       [AllergensTag.SOYBEANS.offTag],
    'fish':      [AllergensTag.FISH.offTag],
  };

  // Tag de OFF para gluten (enfermedad celíaca)
  static final String _glutenTag = AllergensTag.GLUTEN.offTag;

  // Umbral de azúcares por 100 g (g) a partir del cual se avisa a diabéticos
  static const double _umbralAzucarDiabeticos = 10.0;

  /// Evalúa si [product] es apto según el [healthProfile] del usuario.
  /// Recibe [l10n] para generar los mensajes de motivos en el idioma del usuario.
  ///
  /// [healthProfile] corresponde al subdocumento `health_profile` de Firestore:
  /// ```json
  /// {
  ///   "is_diabetic": false,
  ///   "has_celiac_disease": false,
  ///   "allergens": ["nuts", "lactose"],
  ///   "custom_restrictions": []
  /// }
  /// ```
  static AptitudResult evaluar(
    Product product,
    Map<String, dynamic> healthProfile,
    AppLocalizations l10n,
  ) {
    final List<String> motivos = [];
    final Set<String> tagsIncompatibles = {};

    // Unión de ids de "contiene" (allergens.ids) y "puede contener trazas" (tracesTags)
    final Set<String> tagsProducto = {
      ...product.allergens?.ids ?? [],
      ...product.tracesTags ?? [],
    };

    // --- 1. Alérgenos declarados por el usuario ---
    final userAllergens = List<String>.from(healthProfile['allergens'] ?? []);
    for (final allergen in userAllergens) {
      final tags = _allergenTags[allergen] ?? [];
      final coincidentes = tags.where((t) => tagsProducto.contains(t));
      if (coincidentes.isNotEmpty) {
        motivos.add(_allergenNombre(l10n, allergen));
        tagsIncompatibles.addAll(coincidentes);
      }
    }

    // --- 2. Enfermedad celíaca → gluten ---
    if (healthProfile['has_celiac_disease'] == true) {
      if (tagsProducto.contains(_glutenTag)) {
        motivos.add(l10n.aptitudGluten);
        tagsIncompatibles.add(_glutenTag);
      }
    }

    // --- 3. Diabetes → alto contenido en azúcares ---
    if (healthProfile['is_diabetic'] == true) {
      final n = product.nutriments;
      final azucares = n?.getValue(Nutrient.sugars, PerSize.oneHundredGrams);

      // Consideramos que hay datos reales solo si al menos uno de los campos
      // principales tiene valor (evita el caso de un objeto Nutriments vacío)
      final tieneDatos = n != null && (
        azucares != null ||
        n.getValue(Nutrient.energyKCal, PerSize.oneHundredGrams) != null ||
        n.getValue(Nutrient.carbohydrates, PerSize.oneHundredGrams) != null ||
        n.getValue(Nutrient.fat, PerSize.oneHundredGrams) != null
      );

      if (!tieneDatos) {
        motivos.add(l10n.aptitudNoNutritionInfo);
      } else if (azucares != null && azucares > _umbralAzucarDiabeticos) {
        motivos.add(l10n.aptitudHighSugar(azucares.toStringAsFixed(1)));
      }
      // azucares == null con datos reales presentes → campo no registrado, se asume 0
    }

    return AptitudResult(
      isApt: motivos.isEmpty,
      motivos: motivos,
      tagsIncompatibles: tagsIncompatibles,
    );
  }

  /// Devuelve el nombre localizado del alérgeno según su clave de backend.
  static String _allergenNombre(AppLocalizations l10n, String key) {
    switch (key) {
      case 'nuts':      return l10n.allergenNuts;
      case 'lactose':   return l10n.allergenLactoseMilk;
      case 'shellfish': return l10n.allergenShellfish;
      case 'egg':       return l10n.allergenEgg;
      case 'soy':       return l10n.allergenSoy;
      case 'fish':      return l10n.allergenFish;
      default:          return key;
    }
  }
}
