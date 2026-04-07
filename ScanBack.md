# ScanBack — Lógica de Escaneo de Productos

Documentación de toda la lógica implementada para el escaneo de códigos de barras,
consulta a Open Food Facts y evaluación de aptitud del producto.

---

## Flujo completo

```
CameraViewfinder
    │  detecta código de barras (debounce 2 s)
    ▼
HomeScreen._onBarcodeScanned(code)
    │  bloquea escaneos paralelos (_isFetchingProduct)
    │  muestra CircularProgressIndicator sobre la cámara
    ▼
OpenFoodAPIClient.getProductV3(config)   ← API de Open Food Facts
    │  devuelve ProductResultV3
    ▼
AptitudService.evaluar(product, healthProfile)
    │  compara alérgenos del producto con el perfil del usuario
    │  devuelve AptitudResult { isApt, motivos, tagsIncompatibles }
    ▼
showProductResultCard(context, product, healthProfile)
    │  abre DraggableScrollableSheet
    └─ colapsado: imagen + nombre + banner apto/no apto
    └─ expandido: ingredientes resaltados + tabla nutricional
```

---

## Archivos involucrados

| Archivo | Responsabilidad |
|---|---|
| `lib/screens/home_screen.dart` | Orquesta el escaneo y llama a la API |
| `lib/services/aptitud_service.dart` | Lógica de evaluación de aptitud |
| `lib/widgets/product_result_card.dart` | UI de resultado del producto |
| `lib/widgets/camera_viewfinder.dart` | Captura del código de barras |

---

## 1. Configuración de Open Food Facts (`home_screen.dart`)

```dart
void setupOFF() {
  OpenFoodAPIConfiguration.userAgent = UserAgent(
    name: 'AptoParaTi',
    version: '1.0.0',
    system: 'Android/iOS',
  );
  OpenFoodAPIConfiguration.globalLanguages = [OpenFoodFactsLanguage.SPANISH];
  OpenFoodAPIConfiguration.globalCountry = OpenFoodFactsCountry.SPAIN;
}
```

Se llama una vez en `initState()` de `HomeScreen`. Establece:
- **UserAgent**: identifica la app ante la API de OFF (requerido por sus condiciones de uso).
- **globalLanguages**: los datos de producto (nombre, ingredientes) se devuelven en español cuando están disponibles.
- **globalCountry**: prioriza productos del catálogo español.

---

## 2. Captura del código de barras (`camera_viewfinder.dart`)

```dart
void _handleBarcode(BarcodeCapture capture) {
  if (!_isScanning) return;           // debounce: ignora mientras procesa
  final barcode = capture.barcodes.first;
  if (barcode.rawValue != null) {
    _isScanning = false;              // pausa la cámara
    widget.onScan?.call(barcode.rawValue!);
    Future.delayed(Duration(seconds: 2), () {
      if (mounted) setState(() => _isScanning = true);  // reactiva tras 2 s
    });
  }
}
```

- `MobileScanner` emite eventos continuamente mientras detecta un código.
- El flag `_isScanning` actúa como **debounce**: solo procesa un código cada 2 segundos, evitando llamadas duplicadas a la API.
- El callback `onScan` recibe el valor crudo del código (EAN-13, UPC-A, etc.).

---

## 3. Petición a la API (`home_screen.dart`)

```dart
Future<void> _onBarcodeScanned(String code) async {
  if (_isFetchingProduct) return;          // evita peticiones paralelas
  setState(() => _isFetchingProduct = true);

  try {
    final config = ProductQueryConfiguration(
      code,
      version: ProductQueryVersion.v3,
      fields: [ProductField.ALL],          // solicita todos los campos
    );

    final result = await OpenFoodAPIClient.getProductV3(config);

    if (!mounted) return;

    if (result.product != null) {
      setState(() => _lastProduct = result.product);
      _mostrarResultadoProducto(result.product!);
    } else if (result.result?.id == ProductResultV3.resultProductNotFound) {
      // El código existe pero OFF no tiene datos de ese producto
      ScaffoldMessenger.of(context).showSnackBar(...);
    }
  } catch (e) {
    // Error de red u otro error inesperado
    ScaffoldMessenger.of(context).showSnackBar(...);
  } finally {
    if (mounted) setState(() => _isFetchingProduct = false);
  }
}
```

### Puntos clave

| Concepto | Explicación |
|---|---|
| `_isFetchingProduct` | Flag de estado que bloquea nuevos escaneos mientras hay una petición en vuelo. También activa el overlay de carga sobre la cámara. |
| `ProductQueryVersion.v3` | Usa la API v3 de OFF, la versión activa con soporte OpenAPI. |
| `ProductField.ALL` | Descarga todos los campos disponibles del producto (ingredientes, nutrientes, alérgenos, imágenes, etc.). En producción se puede optimizar listando solo los campos necesarios. |
| `result.product != null` | El éxito se comprueba por la presencia del objeto `Product`, no por `result.status`, ya que un status `success_with_warnings` también devuelve producto válido. |
| `result.result?.id == resultProductNotFound` | Distingue "producto no encontrado en OFF" de un error de red. `result.result` es un `LocalizedTag` con campo `id`. |
| `if (!mounted) return` | Guarda obligatoria tras cualquier `await`: si el widget se destruyó mientras esperábamos, no ejecutamos `setState` ni accedemos a `context`. |

---

## 4. Modelo de datos de OFF relevante

### `Product` (campos usados)

| Campo | Tipo | Descripción |
|---|---|---|
| `productName` | `String?` | Nombre del producto |
| `brands` | `String?` | Marcas (separadas por coma) |
| `quantity` | `String?` | Cantidad / peso (ej: "500 g") |
| `imageFrontSmallUrl` | `String?` | URL imagen frontal pequeña |
| `allergens` | `Allergens?` | Objeto con `.ids: List<String>` (ej: `['en:gluten', 'en:milk']`) |
| `tracesTags` | `List<String>?` | Tags de trazas ("puede contener…") |
| `ingredients` | `List<Ingredient>?` | Lista estructurada de ingredientes |
| `ingredientsText` | `String?` | Texto plano de ingredientes (fallback) |
| `nutriments` | `Nutriments?` | Valores nutricionales por 100 g / porción |

### `Allergens` vs `allergensTags`

> ⚠️ El paquete Dart **no** expone `allergensTags` como `List<String>` directamente.
> El campo correcto es `product.allergens?.ids` que devuelve los tags en formato `en:gluten`.

### `Ingredient.bold`

OFF marca con `bold = true` los ingredientes que son alérgenos declarados en la etiqueta del producto (los que van en **negrita** en el packaging físico). Se usa para resaltarlos en la UI aunque no afecten al usuario concreto.

### `ProductResultV3` — estados

| Constante | Valor | Significado |
|---|---|---|
| `statusSuccess` | `'success'` | Operación completada sin avisos |
| `statusWarning` | `'success_with_warnings'` | Completada con advertencias (producto existe) |
| `statusFailure` | `'failure'` | Error en la operación |
| `resultProductFound` | `'product_found'` | El producto existe en OFF |
| `resultProductNotFound` | `'product_not_found'` | Código no encontrado en OFF |

> `statusNotFound` **no existe** en el paquete. El "no encontrado" está en `result.result?.id`.

---

## 5. Evaluación de aptitud (`aptitud_service.dart`)

### Clase `AptitudResult`

```dart
class AptitudResult {
  final bool isApt;                  // true → producto apto para el usuario
  final List<String> motivos;        // razones legibles en español
  final Set<String> tagsIncompatibles; // tags OFF que fallaron (para resaltar ingredientes)
}
```

### Método `AptitudService.evaluar(product, healthProfile)`

Recibe el `Product` de OFF y el subdocumento `health_profile` de Firestore:

```json
{
  "is_diabetic": false,
  "has_celiac_disease": false,
  "allergens": ["nuts", "lactose"],
  "custom_restrictions": []
}
```

#### Paso 1 — Construcción del set de tags del producto

```dart
final Set<String> tagsProducto = {
  ...product.allergens?.ids ?? [],   // "contiene"
  ...product.tracesTags ?? [],       // "puede contener trazas de"
};
```

Por seguridad se unen ambos conjuntos. Si el usuario es alérgico a frutos secos,
tanto `en:nuts` en `allergens` como en `tracesTags` se consideran incompatibles.

#### Paso 2 — Comparación alérgeno por alérgeno

```dart
static final Map<String, List<String>> _allergenTags = {
  'nuts':      [AllergensTag.NUTS.offTag],           // 'en:nuts'
  'lactose':   [AllergensTag.MILK.offTag],           // 'en:milk'
  'shellfish': [AllergensTag.CRUSTACEANS.offTag,
                AllergensTag.MOLLUSCS.offTag],        // marisco = crustáceos + moluscos
  'egg':       [AllergensTag.EGGS.offTag],           // 'en:eggs'
  'soy':       [AllergensTag.SOYBEANS.offTag],       // 'en:soybeans'
  'fish':      [AllergensTag.FISH.offTag],           // 'en:fish'
};
```

Se usa el enum `AllergensTag` del propio paquete OFF en lugar de strings literales,
para que el código se rompa en compilación si OFF cambia el nombre del tag.

#### Paso 3 — Condición celíaca

```dart
static final String _glutenTag = AllergensTag.GLUTEN.offTag; // 'en:gluten'

if (healthProfile['has_celiac_disease'] == true) {
  if (tagsProducto.contains(_glutenTag)) {
    motivos.add('Gluten (enfermedad celíaca)');
    tagsIncompatibles.add(_glutenTag);
  }
}
```

#### Paso 4 — Diabetes (azúcares)

```dart
static const double _umbralAzucarDiabeticos = 10.0; // g por 100 g

final azucares = product.nutriments
    ?.getValue(Nutrient.sugars, PerSize.oneHundredGrams);
if (azucares != null && azucares > _umbralAzucarDiabeticos) { ... }
```

Umbral de 10 g de azúcares por 100 g como criterio simplificado. La diabetes
no tiene un tag de alérgeno en OFF, por lo que se evalúa directamente
desde los nutrientes. No añade a `tagsIncompatibles` (no es un alérgeno etiquetado).

---

## 6. Card de resultado (`product_result_card.dart`)

### `DraggableScrollableSheet`

```dart
DraggableScrollableSheet(
  initialChildSize: 0.48,  // ocupa ~48% de la pantalla al aparecer
  minChildSize: 0.38,      // mínimo al arrastrar hacia abajo
  maxChildSize: 0.93,      // máximo al arrastrar hacia arriba
  builder: (context, scrollController) { ... },
)
```

El `scrollController` se pasa al `SingleChildScrollView` interno para que
el scroll de contenido y el arrastre del sheet estén coordinados:
al llegar al tope del scroll, el gesto continúa expandiendo el sheet.

### Sección de ingredientes — lógica de resaltado

Se aplican dos estrategias según los datos disponibles:

**A) Lista estructurada (`product.ingredients`)** — chips de colores:

| Color | Condición |
|---|---|
| Rojo | El texto del ingrediente contiene una keyword de un tag incompatible |
| Naranja | `ingredient.bold == true` (alérgeno declarado) pero no afecta al usuario |
| Gris | Ingrediente normal |

**B) Texto plano (`product.ingredientsText`)** — `RichText` con `RegExp`:

```dart
final pattern = RegExp(
  keywords.map(RegExp.escape).join('|'),
  caseSensitive: false,
);
// Divide el texto en spans: normal / resaltado en rojo
```

El mapa de keywords (`_keywordsPorTag`) relaciona cada tag OFF con las palabras
más comunes en etiquetas españolas e inglesas:

```dart
const Map<String, List<String>> _keywordsPorTag = {
  'en:gluten': ['gluten', 'trigo', 'wheat', 'cebada', ...],
  'en:milk':   ['leche', 'milk', 'lactosa', 'suero', 'whey', ...],
  // ...
};
```

### Tabla nutricional

Usa `Nutriments.getValue(Nutrient.X, PerSize.oneHundredGrams)` para cada nutriente.

| Nutriente | Enum |
|---|---|
| Energía (kJ) | `Nutrient.energyKJ` |
| Energía (kcal) | `Nutrient.energyKCal` |
| Grasas | `Nutrient.fat` |
| Saturadas | `Nutrient.saturatedFat` |
| Hidratos | `Nutrient.carbohydrates` |
| Azúcares | `Nutrient.sugars` |
| Fibra | `Nutrient.fiber` |
| Proteínas | `Nutrient.proteins` |
| Sal | `Nutrient.salt` |

> ⚠️ `Nutrient.energy` **no existe**. Los enums correctos son `energyKJ` y `energyKCal`.

---

## 7. Decisiones de diseño

| Decisión | Motivo |
|---|---|
| `ProductField.ALL` en la query | Simplicidad en MVP; en producción listar solo los campos necesarios reduce el payload |
| Unir `allergens.ids` + `tracesTags` | Seguridad máxima: una traza puede ser suficiente para una reacción alérgica grave |
| `AllergensTag` enum en vez de strings | Fallo en compilación si el paquete cambia un tag; más seguro que `'en:nuts'` hardcodeado |
| `DraggableScrollableSheet` | Permite vista compacta por defecto sin perder acceso a datos detallados con un gesto natural |
| Keywords en español e inglés | Las etiquetas de productos en España mezclan ambos idiomas frecuentemente |
| Umbral de azúcar fijo (10 g/100 g) | Criterio simplificado para MVP; idealmente configurable o basado en guías clínicas |

---

## 8. Pendientes / mejoras futuras

- [ ] Guardar cada escaneo en Firestore (`stats.scans_today`, historial)
- [ ] Usar `ProductField` específicos en lugar de `ALL` para optimizar la petición
- [ ] Hacer configurable el umbral de azúcar para diabéticos
- [ ] Soporte para `custom_restrictions` del perfil (actualmente ignorado)
- [ ] Caché local de productos ya escaneados para no repetir peticiones a OFF
- [ ] Modo offline con base de datos local de códigos frecuentes
