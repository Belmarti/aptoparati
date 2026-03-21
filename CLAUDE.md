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
| firebase_auth | ^6.1.4 | Autenticación email/password |
| cloud_firestore | ^6.1.2 | Base de datos usuarios |
| mobile_scanner | ^7.1.4 | Escáner de códigos de barras/QR |
| cupertino_icons | ^1.0.8 | Iconos |

**Tema:** Material Design 3, color semilla verde (`#4CAF50`), modo claro.

**Localización:** Todo el texto de la UI está en **español**, sin paquete i18n (strings hardcodeados).

---

## Estructura de Directorios

```
aptoparati/
├── lib/
│   ├── main.dart                     # Entry point, inicialización Firebase
│   ├── firebase_options.dart         # Config Firebase (auto-generado por FlutterFire CLI)
│   ├── screens/
│   │   ├── login_screen.dart
│   │   ├── register_screen.dart
│   │   ├── intolerances_screen.dart
│   │   ├── home_screen.dart
│   │   └── user_config_screen.dart
│   ├── services/
│   │   └── user_service.dart         # Singleton caché de datos de usuario
│   └── widgets/
│       ├── action_button.dart        # Botón principal con animaciones
│       ├── custom_text_field.dart    # TextField con animación de foco
│       ├── text_action_button.dart   # Botón de texto con hover
│       ├── camera_viewfinder.dart    # Vista de cámara con mobile_scanner
│       └── dashboard_actions.dart   # Panel inferior con 3 acciones
├── android/app/google-services.json  # Credenciales Firebase Android
├── firebase.json                     # Config FlutterFire CLI
└── pubspec.yaml
```

---

## Pantallas y Flujo de Navegación

```
LoginScreen
├── → RegisterScreen            (nuevo usuario)
│     └── → IntolerancesScreen  (paso 2 de 2 del registro)
│           └── → LoginScreen   (tras registro exitoso)
└── → HomeScreen                (login exitoso)
      └── → UserConfigScreen    (clic en avatar de usuario)
            └── → HomeScreen    (volver)
```

**Métodos de navegación usados:** `Navigator.push()`, `Navigator.pushReplacement()`, `Navigator.pushAndRemoveUntil()`. Sin named routes.

### Detalle de cada pantalla

| Pantalla | Propósito | Estado actual |
|---|---|---|
| `login_screen.dart` | Autenticación email/password | Completo |
| `register_screen.dart` | Paso 1: nombre, email, contraseña | Completo |
| `intolerances_screen.dart` | Paso 2: condiciones de salud y alérgenos | Completo |
| `home_screen.dart` | Dashboard principal con cámara | Completo (funciones futuras pendientes) |
| `user_config_screen.dart` | Edición del perfil de salud | Completo |

---

## Modelo de Datos (Firestore)

**Colección:** `users/` — documento identificado por el UID de Firebase Auth.

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

### Mapeo de alérgenos (UI → backend)

| Display (ES) | Backend key |
|---|---|
| Frutos secos | nuts |
| Lactosa | lactose |
| Marisco | shellfish |
| Huevo | egg |
| Soja | soy |
| Pescado | fish |

---

## Gestión de Estado

- **Sin librería de estado** (no Provider, Riverpod, GetX, BLoC).
- `StatefulWidget` + `setState()` para estado local de pantallas.
- `UserService` (singleton) como caché de datos del usuario en memoria tras login.
  - `fetchUserData(uid)` — carga de Firestore al hacer login.
  - `updateHealthProfile(uid, data)` — actualiza Firestore y caché local.
  - `clear()` — limpia caché (actualmente **no se llama en ningún lado**, logout pendiente).

---

## Funcionalidades Pendientes / En Progreso

| Funcionalidad | Estado | Notas |
|---|---|---|
| Botón de Logout | **Pendiente** | `UserService.clear()` existe pero no hay UI |
| Recuperar contraseña | **Pendiente** | Link en LoginScreen sin lógica |
| Pantalla de resultados del escaneo | **Pendiente** | HomeScreen muestra AlertDialog básico |
| Integración con base de datos de productos | **Pendiente** | Core de la app |
| Pantalla de búsqueda | **Pendiente** | Snackbar "Próximamente" |
| Pantalla de historial de escaneos | **Pendiente** | Snackbar "Próximamente" |
| Modelos de datos tipados (clases Dart) | **Pendiente** | Actualmente usa `Map<String, dynamic>` |
| Separación lógica de negocio de la UI | **Pendiente** | Llamadas directas a Firestore desde pantallas |

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
Panel inferior con 3 botones: Buscar, Escanear (central/destacado), Historial. Radio superior 32px.

---

## Convenciones y Patrones de Código

- `async/await` para todas las operaciones asíncronas.
- Verificación de `mounted` antes de `setState()` tras awaits.
- `dispose()` para controladores y focus nodes.
- Manejo de errores específicos de Firebase Auth (códigos de error en español).
- No hay modelos de datos tipados — todo usa `Map<String, dynamic>`.
- No hay separación repository/datasource — acceso directo a Firestore desde pantallas.

---

## Lo que NO está implementado aún (gaps de arquitectura)

- No hay patrón Repository.
- No hay inyección de dependencias.
- No hay logging de errores.
- No hay tests (unitarios, widget, integración).
- No hay CI/CD.
- No hay tipado fuerte de modelos (clases Dart con fromMap/toMap).
