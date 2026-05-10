import 'package:openfoodfacts/openfoodfacts.dart';
import 'package:aptoparati/l10n/app_localizations.dart';

/// Resultado de comprobar si un producto es apto para el usuario.
class AptitudResult {
  /// true si el producto no supone riesgo directo para el perfil del usuario.
  /// Las trazas NO convierten el producto en no apto (salvo celíacos con gluten).
  final bool isApt;

  /// Lista de motivos concretos por los que NO es apto (vacía si lo es).
  final List<String> motivos;

  /// Tags OFF (en:gluten, en:milk…) que han activado la incompatibilidad directa.
  /// Usados para resaltar ingredientes en rojo en la UI.
  final Set<String> tagsIncompatibles;

  /// Alérgenos del usuario detectados solo como trazas en el producto.
  /// El producto sigue siendo apto, pero se muestra una advertencia.
  final List<String> motivosTraza;

  /// Tags OFF de alérgenos presentes únicamente como trazas.
  /// Usados para resaltar ingredientes en ámbar en la UI.
  final Set<String> tagsTraza;

  const AptitudResult({
    required this.isApt,
    required this.motivos,
    required this.tagsIncompatibles,
    required this.motivosTraza,
    required this.tagsTraza,
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
    final List<String> motivosTraza = [];
    final Set<String> tagsTraza = {};

    // Separar "contiene directamente" de "puede contener trazas"
    final Set<String> tagsContiene = Set.from(product.allergens?.ids ?? []);
    final Set<String> tagsTrazas = Set.from(product.tracesTags ?? []);

    // --- 1. Alérgenos declarados por el usuario ---
    // Un alérgeno que el producto contiene directamente → no apto.
    // Un alérgeno presente solo como traza → apto con advertencia.
    final userAllergens = List<String>.from(healthProfile['allergens'] ?? []);
    for (final allergen in userAllergens) {
      final tags = _allergenTags[allergen] ?? [];

      final coincidentesDirectos = tags.where((t) => tagsContiene.contains(t));
      if (coincidentesDirectos.isNotEmpty) {
        motivos.add(_allergenNombre(l10n, allergen));
        tagsIncompatibles.addAll(coincidentesDirectos);
        continue; // Si ya hay incompatibilidad directa, no evaluar trazas de este alérgeno
      }

      // Solo trazas (sin presencia directa confirmada)
      final coincidentesTrazas = tags.where(
        (t) => tagsTrazas.contains(t) && !tagsContiene.contains(t),
      );
      if (coincidentesTrazas.isNotEmpty) {
        motivosTraza.add(_allergenNombre(l10n, allergen));
        tagsTraza.addAll(coincidentesTrazas);
      }
    }

    // --- 2. Enfermedad celíaca → gluten ---
    // Por seguridad médica, las trazas de gluten también se tratan como incompatibilidad
    // directa para celíacos, ya que cualquier cantidad puede desencadenar reacción.
    if (healthProfile['has_celiac_disease'] == true) {
      final hayGluten = tagsContiene.contains(_glutenTag) || tagsTrazas.contains(_glutenTag);
      if (hayGluten) {
        motivos.add(l10n.aptitudGluten);
        tagsIncompatibles.add(_glutenTag);
        // Eliminar de trazas si ya se movió a incompatibles
        tagsTraza.remove(_glutenTag);
        motivosTraza.removeWhere((m) => m == l10n.aptitudGluten);
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
      motivosTraza: motivosTraza,
      tagsTraza: tagsTraza,
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
