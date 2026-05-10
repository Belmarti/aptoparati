# AptoParaTi — Contexto del Proyecto

## Descripción General

**AptoParaTi** ("Suitable for You") es una app móvil Flutter orientada a la salud alimentaria. Permite a los usuarios escanear códigos de barras de productos para determinar si son aptos según su perfil de salud (intolerancias, alergias, condiciones médicas). Actualmente está en fase MVP.

**Firebase Project:** `aptoparati-782b9`

---

## Stack Tecnológico

| Tecnología | Versión | Uso |
|---|---|---|
| Flutter SDK | ^3.10.7 | Framework principal |
| firebase_core | ^4.4.0 | Inicialización Firebase |
| firebase_auth | ^6.1.4 | Autenticación email/password + Google Sign-In |
| cloud_firestore | ^6.1.2 | Base de datos usuarios, escaneos recientes y reportes |
| mobile_scanner | ^7.1.4 | Escáner de códigos de barras/QR |
| openfoodfacts | ^3.30.2 | API de productos alimenticios (OFF) |
| google_sign_in | ^6.2.1 | Login con Google |
| provider | ^6.1.2 | Gestión de estado reactiva (ThemeService, LocaleService) |
| shared_preferences | ^2.3.4 | Persistencia de preferencias de tema e idioma |
| flutter_svg | ^2.0.10 | Iconos SVG (ej. botón de escaneo) |
| flutter_localizations | sdk | Soporte i18n (ES, EN, FR) |
| intl | any | Internacionalización y formato de fechas |
| cupertino_icons | ^1.0.8 | Iconos iOS |

**Temas:** Material Design 3. Dos temas definidos en `lib/theme/app_themes.dart`:
- `themeEstandar`: color semilla verde (`#4CAF50`), fondo blanco, modo claro.
- `themeBajaVision`: alto contraste negro/cian-menta (`#00FFBB`), fuentes ×1.5, botones ≥56dp, WCAG AA.

**Localización:** Sistema i18n completo con `AppLocalizations`. Idiomas soportados: **español** (es), **inglés** (en), **francés** (fr). Archivos ARB en `lib/l10n/`. Los archivos `.dart` se generan automáticamente con `flutter gen-l10n`; **nunca editar los `.dart` generados, solo los `.arb`**.

---

## Estructura de Directorios

```
aptoparati/
├── lib/
│   ├── main.dart                        # Entry point: Firebase + Provider + scaffoldMessengerKey
│   ├── app_globals.dart                 # GlobalKey<ScaffoldMessengerState> scaffoldMessengerKey
│   ├── firebase_options.dart            # Config Firebase (auto-generado por FlutterFire CLI)
│   ├── l10n/
│   │   ├── app_es.arb                   # Strings fuente en español  ← editar aquí
│   │   ├── app_en.arb                   # Strings fuente en inglés   ← editar aquí
│   │   ├── app_fr.arb                   # Strings fuente en francés  ← editar aquí
│   │   ├── app_localizations.dart       # Clase base (auto-generada)
│   │   ├── app_localizations_es.dart    # Implementación ES (auto-generada)
│   │   ├── app_localizations_en.dart    # Implementación EN (auto-generada)
│   │   └── app_localizations_fr.dart    # Implementación FR (auto-generada)
│   ├── theme/
│   │   └── app_themes.dart              # Definición de themeEstandar y themeBajaVision
│   ├── data/
│   │   └── health_profile_data.dart     # Constantes kHealthConditions y kAllergens
│   ├── screens/
│   │   ├── login_screen.dart
│   │   ├── register_screen.dart
│   │   ├── intolerances_screen.dart
│   │   ├── home_screen.dart
│   │   ├── user_config_screen.dart      # Hub de config: accesibilidad, idioma, perfil de salud
│   │   ├── health_profile_screen.dart   # Edición de condiciones médicas y alérgenos
│   │   ├── search_screen.dart           # Búsqueda manual por código de barras
│   │   └── recent_scans_screen.dart     # Historial de los 5 últimos escaneos
│   ├── services/
│   │   ├── user_service.dart            # Singleton caché de datos de usuario + saveRecentScan
│   │   ├── theme_service.dart           # ChangeNotifier: modo baja visión (persistido en prefs)
│   │   ├── locale_service.dart          # ChangeNotifier: idioma activo (persistido en prefs)
│   │   ├── aptitud_service.dart         # Lógica de evaluación producto vs. perfil de salud
│   │   └── report_service.dart          # Envío de reportes de error a Firestore (colección reports/)
│   └── widgets/
│       ├── action_button.dart           # Botón principal con animaciones
│       ├── custom_text_field.dart       # TextField con animación de foco
│       ├── text_action_button.dart      # Botón de texto con hover
│       ├── camera_viewfinder.dart       # Vista de cámara con mobile_scanner
│       ├── dashboard_actions.dart       # Barra inferior: Buscar | Escanear | Historial
│       └── product_result_card.dart     # Bottom sheet resultado + formulario de reporte inline
├── assets/
│   ├── icons/                           # SVGs (ej. ScanIcon.svg)
│   └── images/
├── android/app/google-services.json     # Credenciales Firebase Android
├── firebase.json                        # Config FlutterFire CLI
└── pubspec.yaml
```

---

## Pantallas y Flujo de Navegación

```
LoginScreen
├── → RegisterScreen              (nuevo usuario)
│     └── → IntolerancesScreen    (paso 2 de 2 del registro)
│           └── → LoginScreen     (tras registro exitoso)
└── → HomeScreen                  (login exitoso)
      ├── → UserConfigScreen       (clic en avatar de usuario)
      │     ├── → HealthProfileScreen  (editar perfil de salud)
      │     │     └── → UserConfigScreen (pop)
      │     └── → LoginScreen     (cerrar sesión)
      ├── → SearchScreen           (DashboardActions: Buscar)
      └── → RecentScansScreen      (DashboardActions: Historial)
```

**Métodos de navegación usados:** `Navigator.push()`, `Navigator.pushReplacement()`, `Navigator.pushAndRemoveUntil()`, `Navigator.pop()`. Sin named routes.

### Detalle de cada pantalla

| Pantalla | Propósito | Estado actual |
|---|---|---|
| `login_screen.dart` | Autenticación email/password + Google Sign-In | Completo |
| `register_screen.dart` | Paso 1 registro: nombre, email, contraseña | Completo |
| `intolerances_screen.dart` | Paso 2 registro: condiciones de salud y alérgenos | Completo |
| `home_screen.dart` | Dashboard principal con cámara | Completo |
| `user_config_screen.dart` | Hub: accesibilidad (baja visión), idioma, acceso a perfil de salud, logout | Completo |
| `health_profile_screen.dart` | Edición de condiciones médicas (switches) y alérgenos (chips) | Completo |
| `search_screen.dart` | Búsqueda manual de producto por código de barras numérico | Completo |
| `recent_scans_screen.dart` | Lista de los 5 últimos escaneos del usuario con acceso a su resultado | Completo |

---

## Modelo de Datos (Firestore)

### Colección `users/`
Documento identificado por el UID de Firebase Auth.

```json
{
  "personal_info": {
    "email": "string",
    "name": "string",
    "created_at": "Timestamp",
    "last_login": "Timestamp"
  },
  "subscription": {
    "status": "free",
    "plan_id": "basic",
    "expiry_date": null
  },
  "health_profile": {
    "is_diabetic": false,
    "has_celiac_disease": false,
    "allergens": ["nuts", "lactose", "shellfish", "egg", "soy", "fish"],
    "custom_restrictions": []
  },
  "stats": {
    "scans_today": 0,
    "last_scan_date": "Timestamp"
  }
}
```

**Subcolección:** `users/{uid}/recent_scans/` — hasta 5 documentos, ordenados por `scanned_at` desc.

```json
{
  "barcode": "string",
  "name": "string",
  "img_url": "string",
  "scanned_at": "Timestamp (serverTimestamp)"
}
```

`UserService.saveRecentScan()` mantiene el límite de 5: si el código ya existe actualiza la fecha; si no, añade y elimina los que superen 5 (batch delete).

### Colección `reports/`
Documentos creados por `ReportService.sendReport()` cuando el usuario reporta un resultado incorrecto.

```json
{
  "user_id": "string (UID Firebase Auth)",
  "email": "string",
  "barcode": "string",
  "product_name": "string (nombre del producto en OFF)",
  "reason": "string (motivo introducido por el usuario, máx 300 chars)",
  "created_at": "Timestamp (serverTimestamp)"
}
```

**Regla de Firestore requerida:**
```
match /reports/{reportId} {
  allow create: if request.auth != null
                && request.auth.uid == request.resource.data.user_id;
}
```

### Mapeo de alérgenos (UI → backend)

| Display (ES) | Backend key |
|---|---|
| Frutos secos | nuts |
| Lactosa / Leche | lactose |
| Marisco | shellfish |
| Huevo | egg |
| Soja | soy |
| Pescado | fish |

---

## Gestión de Estado

- **`provider`** para estado global reactivo. Dos `ChangeNotifier` registrados en `MultiProvider` en `main.dart`:
  - `ThemeService` — toggle modo baja visión, persiste en `SharedPreferences`.
  - `LocaleService` — idioma activo (es/en/fr), persiste en `SharedPreferences`.
- `StatefulWidget` + `setState()` para estado local de pantallas y widgets complejos.
- `UserService` (singleton) como caché de datos del usuario en memoria tras login:
  - `fetchUserData(uid)` — carga de Firestore al hacer login.
  - `updateHealthProfile(uid, data)` — actualiza Firestore y caché local.
  - `saveRecentScan(uid, barcode, name, imgUrl)` — guarda escaneo en subcolección, límite 5.
  - `clear()` — limpia caché; **se llama en `_signOut()` de `UserConfigScreen`**.

---

## Evaluación de Aptitud (`AptitudService`)

`AptitudService.evaluar(product, healthProfile, l10n)` retorna `AptitudResult`:
- Compara `allergens.ids` + `tracesTags` del producto OFF contra los alérgenos del usuario.
- Detecta gluten si `has_celiac_disease == true`.
- Avisa de alto contenido en azúcares (>10g/100g) si `is_diabetic == true`; informa si no hay datos nutricionales.
- Devuelve `isApt`, lista de `motivos` localizados y `tagsIncompatibles` para resaltar ingredientes.

---

## Widgets Reutilizables

### `ActionButton`
Botón principal animado con escala y sombra al interactuar. Color verde, altura 50px, radio 12px.

### `CustomTextField`
TextField con animación de borde (gris → verde al enfocar). Soporta texto oculto para passwords.

### `TextActionButton`
Botón de texto con cambio de color y subrayado en hover.

### `CameraViewfinder`
Vista de cámara fullscreen usando `mobile_scanner`. Marco de enfoque blanco 280×280px. Debounce de 2s para detección de código de barras.

### `DashboardActions`
Barra inferior con 3 acciones: Buscar (izquierda), Escanear/central (SVG, botón circular), Historial (derecha). Responde al tema activo (colores de `colorScheme`). Usa strings de `AppLocalizations`.

### `ProductResultCard` (`showProductResultCard`)
Bottom sheet expandible (`DraggableScrollableSheet`, snaps a 36% / 93%) que muestra:
- Imagen + nombre + marca + cantidad del producto.
- Banner verde/rojo de aptitud.
- Lista de motivos de incompatibilidad (si no es apto).
- Ingredientes con chips coloreados: rojo = incompatible con perfil, naranja = alérgeno genérico OFF, gris = normal. Fallback a texto plano con keywords resaltadas.
- Tabla nutricional por 100g (energía, grasas, carbohidratos, azúcares, fibra, proteínas, sal).
- **Formulario de reporte inline** (ver sección siguiente).

Implementado como `StatefulWidget` (`_ProductResultSheet`) para gestionar el estado del formulario de reporte sin usar `showDialog`.

### Formulario de reporte inline (`_FormularioReporte`)
Componente dentro de `product_result_card.dart` que permite al usuario reportar un resultado incorrecto. Estados del ciclo:
1. Botón "Reportar error" visible.
2. Al pulsar → formulario de texto inline (TextField, máx 300 chars, botones Cancelar/Enviar).
3. Al enviar → llama a `ReportService.sendReport()` → muestra confirmación verde inline (✓ + texto de éxito).

**Decisión de diseño:** El formulario es inline (no `showDialog`) para evitar conflictos de lifecycle entre `InheritedWidget`s capturados por rutas modales superpuestas (`showModalBottomSheet` + `showDialog`), que causaban `_dependents.isEmpty` en `InheritedElement.deactivate()`.

---

## Infraestructura Global (`app_globals.dart`)

```dart
final GlobalKey<ScaffoldMessengerState> scaffoldMessengerKey =
    GlobalKey<ScaffoldMessengerState>();
```

Pasado a `MaterialApp.scaffoldMessengerKey` en `main.dart`. Permite mostrar SnackBars desde código asíncrono sin hacer `ScaffoldMessenger.of(context)` fuera de `build()`, evitando registrar dependencias sobre `InheritedWidget`s desde callbacks async.

---

## Localización (i18n)

- Generado con `flutter gen-l10n` (`generate: true` en pubspec).
- **Archivos fuente a editar:** `lib/l10n/app_es.arb`, `app_en.arb`, `app_fr.arb`.
- Los archivos `app_localizations*.dart` son auto-generados en cada build. **Nunca editarlos directamente.**
- Acceso: `AppLocalizations.of(context)!` en cualquier widget dentro de `MaterialApp`.
- `MaterialApp` recibe `locale` desde `LocaleService` vía `context.watch<LocaleService>()`.

---

## Convenciones y Patrones de Código

- `async/await` para todas las operaciones asíncronas.
- Verificación de `mounted` antes de `setState()` tras awaits.
- `dispose()` para controladores y focus nodes.
- Manejo de errores específicos de Firebase Auth (mensajes localizados).
- No hay modelos de datos tipados — todo usa `Map<String, dynamic>`.
- No hay separación repository/datasource — acceso directo a Firestore desde pantallas y servicios.
- Textos de UI siempre a través de `AppLocalizations`, nunca strings hardcodeados.
- Tamaños de fuente en widgets sensibles al tema de baja visión: usar `textTheme.xxx` del contexto en lugar de `fontSize` fijo (excepto elementos decorativos o dentro de `Row` con `Expanded` donde el tamaño fijo evita overflow).
- **`InheritedWidget` en código async:** nunca llamar a `Theme.of()`, `AppLocalizations.of()` o `ScaffoldMessenger.of()` fuera de `build()`. Capturar los valores necesarios en `build()` y pasarlos como parámetros, o usar `scaffoldMessengerKey.currentState` para SnackBars.

---

## Funcionalidades Pendientes

| Funcionalidad | Estado | Notas |
|---|---|---|
| Recuperar contraseña | **Pendiente** | Link en LoginScreen sin lógica |
| Distinción contiene vs. trazas en alérgenos | **Pendiente** | `AptitudService` combina `allergens.ids` y `tracesTags`; diferenciación aplazada |
| Modelos de datos tipados (clases Dart) | **Pendiente** | Actualmente usa `Map<String, dynamic>` |
| Separación lógica de negocio de la UI | **Pendiente** | Sin patrón Repository |
| Tests (unitarios, widget, integración) | **Pendiente** | No hay ninguno |
| CI/CD | **Pendiente** | No configurado |
| Logging de errores | **Pendiente** | `debugPrint()` puntual; sin servicio de logging centralizado |

---

## Lo que NO está implementado aún (gaps de arquitectura)

- No hay patrón Repository.
- No hay inyección de dependencias formal.
- No hay logging de errores centralizado.
- No hay tests.
- No hay CI/CD.
- No hay tipado fuerte de modelos (clases Dart con fromMap/toMap).
