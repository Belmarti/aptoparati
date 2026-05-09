import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_es.dart';
import 'app_localizations_fr.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('es'),
    Locale('fr'),
  ];

  /// No description provided for @appTitle.
  ///
  /// In es, this message translates to:
  /// **'AptoParaTi'**
  String get appTitle;

  /// No description provided for @welcomeMessage.
  ///
  /// In es, this message translates to:
  /// **'Bienvenido a AptoParaTi'**
  String get welcomeMessage;

  /// No description provided for @loginTagline.
  ///
  /// In es, this message translates to:
  /// **'Tu guía de alimentación'**
  String get loginTagline;

  /// No description provided for @emailLabel.
  ///
  /// In es, this message translates to:
  /// **'Correo electrónico'**
  String get emailLabel;

  /// No description provided for @emailHint.
  ///
  /// In es, this message translates to:
  /// **'ejemplo@correo.com'**
  String get emailHint;

  /// No description provided for @passwordLabel.
  ///
  /// In es, this message translates to:
  /// **'Contraseña'**
  String get passwordLabel;

  /// No description provided for @passwordHint.
  ///
  /// In es, this message translates to:
  /// **'••••••••'**
  String get passwordHint;

  /// No description provided for @cancelButton.
  ///
  /// In es, this message translates to:
  /// **'Cancelar'**
  String get cancelButton;

  /// No description provided for @sendButton.
  ///
  /// In es, this message translates to:
  /// **'Enviar'**
  String get sendButton;

  /// No description provided for @continueButton.
  ///
  /// In es, this message translates to:
  /// **'Continuar'**
  String get continueButton;

  /// No description provided for @noDataAvailable.
  ///
  /// In es, this message translates to:
  /// **'No disponible'**
  String get noDataAvailable;

  /// No description provided for @healthProfileTitle.
  ///
  /// In es, this message translates to:
  /// **'Perfil de Salud'**
  String get healthProfileTitle;

  /// No description provided for @allergiesAndIntolerances.
  ///
  /// In es, this message translates to:
  /// **'Alergias e Intolerancias'**
  String get allergiesAndIntolerances;

  /// No description provided for @productNameUnknown.
  ///
  /// In es, this message translates to:
  /// **'Producto sin nombre'**
  String get productNameUnknown;

  /// No description provided for @errorConnection.
  ///
  /// In es, this message translates to:
  /// **'Error de conexión. Comprueba tu red.'**
  String get errorConnection;

  /// No description provided for @loginForgotPassword.
  ///
  /// In es, this message translates to:
  /// **'¿Olvidaste tu contraseña?'**
  String get loginForgotPassword;

  /// No description provided for @loginButton.
  ///
  /// In es, this message translates to:
  /// **'Iniciar Sesión'**
  String get loginButton;

  /// No description provided for @loginOrContinueWith.
  ///
  /// In es, this message translates to:
  /// **'o continúa con'**
  String get loginOrContinueWith;

  /// No description provided for @loginWithGoogle.
  ///
  /// In es, this message translates to:
  /// **'Continuar con Google'**
  String get loginWithGoogle;

  /// No description provided for @loginNoAccount.
  ///
  /// In es, this message translates to:
  /// **'¿No tienes cuenta? '**
  String get loginNoAccount;

  /// No description provided for @loginRegisterLink.
  ///
  /// In es, this message translates to:
  /// **'Regístrate'**
  String get loginRegisterLink;

  /// No description provided for @loginErrorEmailPasswordEmpty.
  ///
  /// In es, this message translates to:
  /// **'Por favor, ingresa tu correo y contraseña'**
  String get loginErrorEmailPasswordEmpty;

  /// No description provided for @loginErrorGoogle.
  ///
  /// In es, this message translates to:
  /// **'Error al iniciar sesión con Google. Inténtalo de nuevo.'**
  String get loginErrorGoogle;

  /// No description provided for @loginErrorGeneric.
  ///
  /// In es, this message translates to:
  /// **'Error al iniciar sesión'**
  String get loginErrorGeneric;

  /// No description provided for @loginErrorUserNotFound.
  ///
  /// In es, this message translates to:
  /// **'No se encontró un usuario con ese correo.'**
  String get loginErrorUserNotFound;

  /// No description provided for @loginErrorWrongPassword.
  ///
  /// In es, this message translates to:
  /// **'Contraseña incorrecta.'**
  String get loginErrorWrongPassword;

  /// No description provided for @loginErrorInvalidEmail.
  ///
  /// In es, this message translates to:
  /// **'El correo no es válido.'**
  String get loginErrorInvalidEmail;

  /// No description provided for @resetPasswordTitle.
  ///
  /// In es, this message translates to:
  /// **'Restablecer contraseña'**
  String get resetPasswordTitle;

  /// No description provided for @resetPasswordDescription.
  ///
  /// In es, this message translates to:
  /// **'Te enviaremos un correo para restablecer tu contraseña.'**
  String get resetPasswordDescription;

  /// No description provided for @resetPasswordEmptyEmail.
  ///
  /// In es, this message translates to:
  /// **'Introduce tu correo electrónico.'**
  String get resetPasswordEmptyEmail;

  /// No description provided for @resetPasswordSuccessMessage.
  ///
  /// In es, this message translates to:
  /// **'Correo de restablecimiento enviado. Revisa tu bandeja de entrada.'**
  String get resetPasswordSuccessMessage;

  /// No description provided for @resetPasswordErrorGeneric.
  ///
  /// In es, this message translates to:
  /// **'Error al enviar el correo'**
  String get resetPasswordErrorGeneric;

  /// No description provided for @resetPasswordErrorUserNotFound.
  ///
  /// In es, this message translates to:
  /// **'No existe una cuenta con ese correo.'**
  String get resetPasswordErrorUserNotFound;

  /// No description provided for @resetPasswordErrorUnexpected.
  ///
  /// In es, this message translates to:
  /// **'Error inesperado. Inténtalo de nuevo.'**
  String get resetPasswordErrorUnexpected;

  /// No description provided for @registerTitle.
  ///
  /// In es, this message translates to:
  /// **'Crea tu cuenta'**
  String get registerTitle;

  /// No description provided for @registerStep.
  ///
  /// In es, this message translates to:
  /// **'Paso 1 de 2: Información básica'**
  String get registerStep;

  /// No description provided for @registerNameLabel.
  ///
  /// In es, this message translates to:
  /// **'Nombre completo'**
  String get registerNameLabel;

  /// No description provided for @registerNameHint.
  ///
  /// In es, this message translates to:
  /// **'Juan Pérez'**
  String get registerNameHint;

  /// No description provided for @registerAlreadyHaveAccount.
  ///
  /// In es, this message translates to:
  /// **'¿Ya tienes cuenta? '**
  String get registerAlreadyHaveAccount;

  /// No description provided for @registerLoginLink.
  ///
  /// In es, this message translates to:
  /// **'Inicia Sesión'**
  String get registerLoginLink;

  /// No description provided for @registerValidationError.
  ///
  /// In es, this message translates to:
  /// **'Por favor, completa todos los campos'**
  String get registerValidationError;

  /// No description provided for @healthProfileQuestion.
  ///
  /// In es, this message translates to:
  /// **'¿Tienes alguna restricción?'**
  String get healthProfileQuestion;

  /// No description provided for @healthProfileDescription.
  ///
  /// In es, this message translates to:
  /// **'Configura tu perfil para que podamos decirte qué productos son aptos para ti.'**
  String get healthProfileDescription;

  /// No description provided for @healthProfileFinishButton.
  ///
  /// In es, this message translates to:
  /// **'Finalizar Registro'**
  String get healthProfileFinishButton;

  /// No description provided for @healthProfileAccountCreated.
  ///
  /// In es, this message translates to:
  /// **'Cuenta creada con éxito'**
  String get healthProfileAccountCreated;

  /// No description provided for @healthProfileEditTitle.
  ///
  /// In es, this message translates to:
  /// **'Modifica tus datos'**
  String get healthProfileEditTitle;

  /// No description provided for @healthProfileEditDescription.
  ///
  /// In es, this message translates to:
  /// **'Actualiza tu perfil para recibir recomendaciones precisas.'**
  String get healthProfileEditDescription;

  /// No description provided for @healthProfileSaveButton.
  ///
  /// In es, this message translates to:
  /// **'Guardar Cambios'**
  String get healthProfileSaveButton;

  /// No description provided for @healthProfileSaveSuccess.
  ///
  /// In es, this message translates to:
  /// **'Cambios guardados correctamente'**
  String get healthProfileSaveSuccess;

  /// No description provided for @healthProfileSaveError.
  ///
  /// In es, this message translates to:
  /// **'Error al guardar cambios'**
  String get healthProfileSaveError;

  /// No description provided for @homeDefaultUser.
  ///
  /// In es, this message translates to:
  /// **'Usuario'**
  String get homeDefaultUser;

  /// No description provided for @homeGreeting.
  ///
  /// In es, this message translates to:
  /// **'Hola, {name}'**
  String homeGreeting(String name);

  /// No description provided for @homeProductNotFound.
  ///
  /// In es, this message translates to:
  /// **'Producto no encontrado (código: {code})'**
  String homeProductNotFound(String code);

  /// No description provided for @homeProductApiError.
  ///
  /// In es, this message translates to:
  /// **'Error al consultar el producto. Comprueba tu conexión.'**
  String get homeProductApiError;

  /// No description provided for @homeCameraAlreadyActive.
  ///
  /// In es, this message translates to:
  /// **'La cámara ya está activa para escanear'**
  String get homeCameraAlreadyActive;

  /// No description provided for @configTitle.
  ///
  /// In es, this message translates to:
  /// **'Configuración'**
  String get configTitle;

  /// No description provided for @configSubtitle.
  ///
  /// In es, this message translates to:
  /// **'Tu perfil de configuración'**
  String get configSubtitle;

  /// No description provided for @configHealthProfileSubtitle.
  ///
  /// In es, this message translates to:
  /// **'Condiciones médicas y alergias'**
  String get configHealthProfileSubtitle;

  /// No description provided for @configAccessibilityTitle.
  ///
  /// In es, this message translates to:
  /// **'Accesibilidad'**
  String get configAccessibilityTitle;

  /// No description provided for @configLowVisionTitle.
  ///
  /// In es, this message translates to:
  /// **'Modo baja visión'**
  String get configLowVisionTitle;

  /// No description provided for @configLowVisionSubtitle.
  ///
  /// In es, this message translates to:
  /// **'Aumenta el contraste y el tamaño del texto'**
  String get configLowVisionSubtitle;

  /// No description provided for @configLanguageTitle.
  ///
  /// In es, this message translates to:
  /// **'Idioma'**
  String get configLanguageTitle;

  /// No description provided for @configSignOut.
  ///
  /// In es, this message translates to:
  /// **'Salir'**
  String get configSignOut;

  /// No description provided for @configLanguageSpanish.
  ///
  /// In es, this message translates to:
  /// **'Español'**
  String get configLanguageSpanish;

  /// No description provided for @configLanguageEnglish.
  ///
  /// In es, this message translates to:
  /// **'Inglés'**
  String get configLanguageEnglish;

  /// No description provided for @configLanguageFrench.
  ///
  /// In es, this message translates to:
  /// **'Francés'**
  String get configLanguageFrench;

  /// No description provided for @dashboardSearch.
  ///
  /// In es, this message translates to:
  /// **'Buscar'**
  String get dashboardSearch;

  /// No description provided for @dashboardRecents.
  ///
  /// In es, this message translates to:
  /// **'Recientes'**
  String get dashboardRecents;

  /// No description provided for @cameraUnavailable.
  ///
  /// In es, this message translates to:
  /// **'Cámara no disponible'**
  String get cameraUnavailable;

  /// No description provided for @cameraScanInstruction.
  ///
  /// In es, this message translates to:
  /// **'Escanea el código de barras'**
  String get cameraScanInstruction;

  /// No description provided for @productIngredients.
  ///
  /// In es, this message translates to:
  /// **'Ingredientes'**
  String get productIngredients;

  /// No description provided for @productIncompatibleLabel.
  ///
  /// In es, this message translates to:
  /// **'Incompatible contigo'**
  String get productIncompatibleLabel;

  /// No description provided for @productAllergenNotAffecting.
  ///
  /// In es, this message translates to:
  /// **'Alérgeno (no te afecta)'**
  String get productAllergenNotAffecting;

  /// No description provided for @productNutritionTitle.
  ///
  /// In es, this message translates to:
  /// **'Información nutricional'**
  String get productNutritionTitle;

  /// No description provided for @productNutritionPer100.
  ///
  /// In es, this message translates to:
  /// **'Por 100 g / 100 ml'**
  String get productNutritionPer100;

  /// No description provided for @productNutritionEnergy.
  ///
  /// In es, this message translates to:
  /// **'Energía'**
  String get productNutritionEnergy;

  /// No description provided for @productNutritionFat.
  ///
  /// In es, this message translates to:
  /// **'Grasas'**
  String get productNutritionFat;

  /// No description provided for @productNutritionSaturatedFat.
  ///
  /// In es, this message translates to:
  /// **'  de las cuales saturadas'**
  String get productNutritionSaturatedFat;

  /// No description provided for @productNutritionCarbs.
  ///
  /// In es, this message translates to:
  /// **'Hidratos de carbono'**
  String get productNutritionCarbs;

  /// No description provided for @productNutritionSugars.
  ///
  /// In es, this message translates to:
  /// **'  de los cuales azúcares'**
  String get productNutritionSugars;

  /// No description provided for @productNutritionFiber.
  ///
  /// In es, this message translates to:
  /// **'Fibra'**
  String get productNutritionFiber;

  /// No description provided for @productNutritionProtein.
  ///
  /// In es, this message translates to:
  /// **'Proteínas'**
  String get productNutritionProtein;

  /// No description provided for @productNutritionSalt.
  ///
  /// In es, this message translates to:
  /// **'Sal'**
  String get productNutritionSalt;

  /// No description provided for @productApt.
  ///
  /// In es, this message translates to:
  /// **'Apto para ti'**
  String get productApt;

  /// No description provided for @productNotApt.
  ///
  /// In es, this message translates to:
  /// **'No apto para ti'**
  String get productNotApt;

  /// No description provided for @productIncompatibleProfile.
  ///
  /// In es, this message translates to:
  /// **'Incompatible con tu perfil:'**
  String get productIncompatibleProfile;

  /// No description provided for @searchTitle.
  ///
  /// In es, this message translates to:
  /// **'Buscar producto'**
  String get searchTitle;

  /// No description provided for @searchInstruction.
  ///
  /// In es, this message translates to:
  /// **'Introduce el código de barras del producto'**
  String get searchInstruction;

  /// No description provided for @searchHint.
  ///
  /// In es, this message translates to:
  /// **'Ej: 8480017513753'**
  String get searchHint;

  /// No description provided for @searchEmptyState.
  ///
  /// In es, this message translates to:
  /// **'Introduce el código y pulsa buscar'**
  String get searchEmptyState;

  /// No description provided for @searchEmptyCodeError.
  ///
  /// In es, this message translates to:
  /// **'Introduce un código de barras'**
  String get searchEmptyCodeError;

  /// No description provided for @searchProductNotFound.
  ///
  /// In es, this message translates to:
  /// **'Producto no encontrado para ese código'**
  String get searchProductNotFound;

  /// No description provided for @recentScansTitle.
  ///
  /// In es, this message translates to:
  /// **'Escaneos recientes'**
  String get recentScansTitle;

  /// No description provided for @recentScansLoadError.
  ///
  /// In es, this message translates to:
  /// **'Error al cargar los escaneos'**
  String get recentScansLoadError;

  /// No description provided for @recentScansEmpty.
  ///
  /// In es, this message translates to:
  /// **'Aún no has escaneado ningún producto'**
  String get recentScansEmpty;

  /// No description provided for @timeNow.
  ///
  /// In es, this message translates to:
  /// **'Ahora mismo'**
  String get timeNow;

  /// No description provided for @timeMinutesAgo.
  ///
  /// In es, this message translates to:
  /// **'Hace {minutes} min'**
  String timeMinutesAgo(int minutes);

  /// No description provided for @timeHoursAgo.
  ///
  /// In es, this message translates to:
  /// **'Hace {hours} h'**
  String timeHoursAgo(int hours);

  /// No description provided for @timeYesterday.
  ///
  /// In es, this message translates to:
  /// **'Ayer'**
  String get timeYesterday;

  /// No description provided for @timeDaysAgo.
  ///
  /// In es, this message translates to:
  /// **'Hace {days} días'**
  String timeDaysAgo(int days);

  /// No description provided for @allergenNuts.
  ///
  /// In es, this message translates to:
  /// **'Frutos secos'**
  String get allergenNuts;

  /// No description provided for @allergenLactose.
  ///
  /// In es, this message translates to:
  /// **'Lactosa'**
  String get allergenLactose;

  /// No description provided for @allergenLactoseMilk.
  ///
  /// In es, this message translates to:
  /// **'Lactosa / Leche'**
  String get allergenLactoseMilk;

  /// No description provided for @allergenShellfish.
  ///
  /// In es, this message translates to:
  /// **'Marisco'**
  String get allergenShellfish;

  /// No description provided for @allergenEgg.
  ///
  /// In es, this message translates to:
  /// **'Huevo'**
  String get allergenEgg;

  /// No description provided for @allergenSoy.
  ///
  /// In es, this message translates to:
  /// **'Soja'**
  String get allergenSoy;

  /// No description provided for @allergenFish.
  ///
  /// In es, this message translates to:
  /// **'Pescado'**
  String get allergenFish;

  /// No description provided for @conditionDiabetic.
  ///
  /// In es, this message translates to:
  /// **'Soy diabético'**
  String get conditionDiabetic;

  /// No description provided for @conditionCeliac.
  ///
  /// In es, this message translates to:
  /// **'Soy celíaco'**
  String get conditionCeliac;

  /// No description provided for @conditionCeliacSubtitle.
  ///
  /// In es, this message translates to:
  /// **'Evitar gluten estrictamente'**
  String get conditionCeliacSubtitle;

  /// No description provided for @aptitudGluten.
  ///
  /// In es, this message translates to:
  /// **'Gluten (enfermedad celíaca)'**
  String get aptitudGluten;

  /// No description provided for @aptitudNoNutritionInfo.
  ///
  /// In es, this message translates to:
  /// **'Sin información nutricional — verifica el azúcar manualmente'**
  String get aptitudNoNutritionInfo;

  /// No description provided for @aptitudHighSugar.
  ///
  /// In es, this message translates to:
  /// **'Alto contenido en azúcar ({value} g/100 g)'**
  String aptitudHighSugar(String value);

  /// No description provided for @reportButton.
  ///
  /// In es, this message translates to:
  /// **'Reportar error'**
  String get reportButton;

  /// No description provided for @reportDialogTitle.
  ///
  /// In es, this message translates to:
  /// **'Reportar un error'**
  String get reportDialogTitle;

  /// No description provided for @reportDialogDescription.
  ///
  /// In es, this message translates to:
  /// **'Si crees que el resultado es incorrecto, cuéntanos qué pasó.'**
  String get reportDialogDescription;

  /// No description provided for @reportReasonLabel.
  ///
  /// In es, this message translates to:
  /// **'Motivo'**
  String get reportReasonLabel;

  /// No description provided for @reportReasonHint.
  ///
  /// In es, this message translates to:
  /// **'Ej: el producto aparece como apto para diabéticos pero tiene mucho azúcar'**
  String get reportReasonHint;

  /// No description provided for @reportReasonEmpty.
  ///
  /// In es, this message translates to:
  /// **'El motivo no puede estar vacío'**
  String get reportReasonEmpty;

  /// No description provided for @reportSuccess.
  ///
  /// In es, this message translates to:
  /// **'¡Reporte enviado! Gracias por ayudarnos a mejorar.'**
  String get reportSuccess;

  /// No description provided for @reportError.
  ///
  /// In es, this message translates to:
  /// **'Error al enviar el reporte. Inténtalo de nuevo.'**
  String get reportError;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'es', 'fr'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'es':
      return AppLocalizationsEs();
    case 'fr':
      return AppLocalizationsFr();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
