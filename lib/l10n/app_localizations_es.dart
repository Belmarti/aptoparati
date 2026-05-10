// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Spanish Castilian (`es`).
class AppLocalizationsEs extends AppLocalizations {
  AppLocalizationsEs([String locale = 'es']) : super(locale);

  @override
  String get appTitle => 'AptoParaTi';

  @override
  String get welcomeMessage => 'Bienvenido a AptoParaTi';

  @override
  String get loginTagline => 'Tu guía de alimentación';

  @override
  String get emailLabel => 'Correo electrónico';

  @override
  String get emailHint => 'ejemplo@correo.com';

  @override
  String get passwordLabel => 'Contraseña';

  @override
  String get passwordHint => '••••••••';

  @override
  String get cancelButton => 'Cancelar';

  @override
  String get sendButton => 'Enviar';

  @override
  String get continueButton => 'Continuar';

  @override
  String get noDataAvailable => 'No disponible';

  @override
  String get healthProfileTitle => 'Perfil de Salud';

  @override
  String get allergiesAndIntolerances => 'Alergias e Intolerancias';

  @override
  String get productNameUnknown => 'Producto sin nombre';

  @override
  String get errorConnection => 'Error de conexión. Comprueba tu red.';

  @override
  String get loginForgotPassword => '¿Olvidaste tu contraseña?';

  @override
  String get loginButton => 'Iniciar Sesión';

  @override
  String get loginOrContinueWith => 'o continúa con';

  @override
  String get loginWithGoogle => 'Continuar con Google';

  @override
  String get loginNoAccount => '¿No tienes cuenta? ';

  @override
  String get loginRegisterLink => 'Regístrate';

  @override
  String get loginErrorEmailPasswordEmpty =>
      'Por favor, ingresa tu correo y contraseña';

  @override
  String get loginErrorGoogle =>
      'Error al iniciar sesión con Google. Inténtalo de nuevo.';

  @override
  String get loginErrorGeneric => 'Error al iniciar sesión';

  @override
  String get loginErrorUserNotFound =>
      'No se encontró un usuario con ese correo.';

  @override
  String get loginErrorWrongPassword => 'Contraseña incorrecta.';

  @override
  String get loginErrorInvalidEmail => 'El correo no es válido.';

  @override
  String get resetPasswordTitle => 'Restablecer contraseña';

  @override
  String get resetPasswordDescription =>
      'Te enviaremos un correo para restablecer tu contraseña.';

  @override
  String get resetPasswordEmptyEmail => 'Introduce tu correo electrónico.';

  @override
  String get resetPasswordSuccessMessage =>
      'Correo de restablecimiento enviado. Revisa tu bandeja de entrada.';

  @override
  String get resetPasswordErrorGeneric => 'Error al enviar el correo';

  @override
  String get resetPasswordErrorUserNotFound =>
      'No existe una cuenta con ese correo.';

  @override
  String get resetPasswordErrorUnexpected =>
      'Error inesperado. Inténtalo de nuevo.';

  @override
  String get registerTitle => 'Crea tu cuenta';

  @override
  String get registerStep => 'Paso 1 de 2: Información básica';

  @override
  String get registerNameLabel => 'Nombre completo';

  @override
  String get registerNameHint => 'Juan Pérez';

  @override
  String get registerAlreadyHaveAccount => '¿Ya tienes cuenta? ';

  @override
  String get registerLoginLink => 'Inicia Sesión';

  @override
  String get registerValidationError => 'Por favor, completa todos los campos';

  @override
  String get healthProfileQuestion => '¿Tienes alguna restricción?';

  @override
  String get healthProfileDescription =>
      'Configura tu perfil para que podamos decirte qué productos son aptos para ti.';

  @override
  String get healthProfileFinishButton => 'Finalizar Registro';

  @override
  String get healthProfileAccountCreated => 'Cuenta creada con éxito';

  @override
  String get healthProfileEditTitle => 'Modifica tus datos';

  @override
  String get healthProfileEditDescription =>
      'Actualiza tu perfil para recibir recomendaciones precisas.';

  @override
  String get healthProfileSaveButton => 'Guardar Cambios';

  @override
  String get healthProfileSaveSuccess => 'Cambios guardados correctamente';

  @override
  String get healthProfileSaveError => 'Error al guardar cambios';

  @override
  String get homeDefaultUser => 'Usuario';

  @override
  String homeGreeting(String name) {
    return 'Hola, $name';
  }

  @override
  String homeProductNotFound(String code) {
    return 'Producto no encontrado (código: $code)';
  }

  @override
  String get homeProductApiError =>
      'Error al consultar el producto. Comprueba tu conexión.';

  @override
  String get homeCameraAlreadyActive =>
      'La cámara ya está activa para escanear';

  @override
  String get configTitle => 'Configuración';

  @override
  String get configSubtitle => 'Tu perfil de configuración';

  @override
  String get configHealthProfileSubtitle => 'Condiciones médicas y alergias';

  @override
  String get configAccessibilityTitle => 'Accesibilidad';

  @override
  String get configLowVisionTitle => 'Modo baja visión';

  @override
  String get configLowVisionSubtitle =>
      'Aumenta el contraste y el tamaño del texto';

  @override
  String get configLanguageTitle => 'Idioma';

  @override
  String get configSignOut => 'Salir';

  @override
  String get configLanguageSpanish => 'Español';

  @override
  String get configLanguageEnglish => 'Inglés';

  @override
  String get configLanguageFrench => 'Francés';

  @override
  String get dashboardSearch => 'Buscar';

  @override
  String get dashboardRecents => 'Recientes';

  @override
  String get cameraUnavailable => 'Cámara no disponible';

  @override
  String get cameraScanInstruction => 'Escanea el código de barras';

  @override
  String get productIngredients => 'Ingredientes';

  @override
  String get productIncompatibleLabel => 'Incompatible contigo';

  @override
  String get productAllergenNotAffecting => 'Alérgeno (no te afecta)';

  @override
  String get productNutritionTitle => 'Información nutricional';

  @override
  String get productNutritionPer100 => 'Por 100 g / 100 ml';

  @override
  String get productNutritionEnergy => 'Energía';

  @override
  String get productNutritionFat => 'Grasas';

  @override
  String get productNutritionSaturatedFat => '  de las cuales saturadas';

  @override
  String get productNutritionCarbs => 'Hidratos de carbono';

  @override
  String get productNutritionSugars => '  de los cuales azúcares';

  @override
  String get productNutritionFiber => 'Fibra';

  @override
  String get productNutritionProtein => 'Proteínas';

  @override
  String get productNutritionSalt => 'Sal';

  @override
  String get productApt => 'Apto para ti';

  @override
  String get productNotApt => 'No apto para ti';

  @override
  String get productIncompatibleProfile => 'Incompatible con tu perfil:';

  @override
  String get productTracesTitle => 'Puede contener trazas de:';

  @override
  String get productTracesExplanation =>
      'Presencia involuntaria por contacto durante la producción. Evalúa si aplica a tu caso.';

  @override
  String get productTracesIngredientLabel => 'Traza (puede afectarte)';

  @override
  String get searchTitle => 'Buscar producto';

  @override
  String get searchInstruction => 'Introduce el código de barras del producto';

  @override
  String get searchHint => 'Ej: 8480017513753';

  @override
  String get searchEmptyState => 'Introduce el código y pulsa buscar';

  @override
  String get searchEmptyCodeError => 'Introduce un código de barras';

  @override
  String get searchProductNotFound => 'Producto no encontrado para ese código';

  @override
  String get recentScansTitle => 'Escaneos recientes';

  @override
  String get recentScansLoadError => 'Error al cargar los escaneos';

  @override
  String get recentScansEmpty => 'Aún no has escaneado ningún producto';

  @override
  String get timeNow => 'Ahora mismo';

  @override
  String timeMinutesAgo(int minutes) {
    return 'Hace $minutes min';
  }

  @override
  String timeHoursAgo(int hours) {
    return 'Hace $hours h';
  }

  @override
  String get timeYesterday => 'Ayer';

  @override
  String timeDaysAgo(int days) {
    return 'Hace $days días';
  }

  @override
  String get allergenNuts => 'Frutos secos';

  @override
  String get allergenLactose => 'Lactosa';

  @override
  String get allergenLactoseMilk => 'Lactosa / Leche';

  @override
  String get allergenShellfish => 'Marisco';

  @override
  String get allergenEgg => 'Huevo';

  @override
  String get allergenSoy => 'Soja';

  @override
  String get allergenFish => 'Pescado';

  @override
  String get conditionDiabetic => 'Soy diabético';

  @override
  String get conditionCeliac => 'Soy celíaco';

  @override
  String get conditionCeliacSubtitle => 'Evitar gluten estrictamente';

  @override
  String get aptitudGluten => 'Gluten (enfermedad celíaca)';

  @override
  String get aptitudNoNutritionInfo =>
      'Sin información nutricional — verifica el azúcar manualmente';

  @override
  String aptitudHighSugar(String value) {
    return 'Alto contenido en azúcar ($value g/100 g)';
  }

  @override
  String get reportButton => 'Reportar error';

  @override
  String get reportDialogTitle => 'Reportar un error';

  @override
  String get reportDialogDescription =>
      'Si crees que el resultado es incorrecto, cuéntanos qué pasó.';

  @override
  String get reportReasonLabel => 'Motivo';

  @override
  String get reportReasonHint =>
      'Ej: el producto aparece como apto para diabéticos pero tiene mucho azúcar';

  @override
  String get reportReasonEmpty => 'El motivo no puede estar vacío';

  @override
  String get reportSuccess =>
      '¡Reporte enviado! Gracias por ayudarnos a mejorar.';

  @override
  String get reportError => 'Error al enviar el reporte. Inténtalo de nuevo.';
}
