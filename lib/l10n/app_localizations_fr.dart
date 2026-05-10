// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for French (`fr`).
class AppLocalizationsFr extends AppLocalizations {
  AppLocalizationsFr([String locale = 'fr']) : super(locale);

  @override
  String get appTitle => 'AptoParaTi';

  @override
  String get welcomeMessage => 'Bienvenue sur AptoParaTi';

  @override
  String get loginTagline => 'Votre guide nutritionnel';

  @override
  String get emailLabel => 'E-mail';

  @override
  String get emailHint => 'exemple@email.com';

  @override
  String get passwordLabel => 'Mot de passe';

  @override
  String get passwordHint => '••••••••';

  @override
  String get cancelButton => 'Annuler';

  @override
  String get sendButton => 'Envoyer';

  @override
  String get continueButton => 'Continuer';

  @override
  String get noDataAvailable => 'Non disponible';

  @override
  String get healthProfileTitle => 'Profil de santé';

  @override
  String get allergiesAndIntolerances => 'Allergies et intolérances';

  @override
  String get productNameUnknown => 'Produit inconnu';

  @override
  String get errorConnection => 'Erreur de connexion. Vérifiez votre réseau.';

  @override
  String get loginForgotPassword => 'Mot de passe oublié ?';

  @override
  String get loginButton => 'Se connecter';

  @override
  String get loginOrContinueWith => 'ou continuer avec';

  @override
  String get loginWithGoogle => 'Continuer avec Google';

  @override
  String get loginNoAccount => 'Pas encore de compte ? ';

  @override
  String get loginRegisterLink => 'S\'inscrire';

  @override
  String get loginErrorEmailPasswordEmpty =>
      'Veuillez saisir votre e-mail et mot de passe';

  @override
  String get loginErrorGoogle => 'Erreur de connexion avec Google. Réessayez.';

  @override
  String get loginErrorGeneric => 'Erreur de connexion';

  @override
  String get loginErrorUserNotFound =>
      'Aucun utilisateur trouvé avec cet e-mail.';

  @override
  String get loginErrorWrongPassword => 'Mot de passe incorrect.';

  @override
  String get loginErrorInvalidEmail => 'L\'e-mail n\'est pas valide.';

  @override
  String get resetPasswordTitle => 'Réinitialiser le mot de passe';

  @override
  String get resetPasswordDescription =>
      'Nous vous enverrons un e-mail pour réinitialiser votre mot de passe.';

  @override
  String get resetPasswordEmptyEmail => 'Saisissez votre adresse e-mail.';

  @override
  String get resetPasswordSuccessMessage =>
      'E-mail de réinitialisation envoyé. Vérifiez votre boîte de réception.';

  @override
  String get resetPasswordErrorGeneric =>
      'Erreur lors de l\'envoi de l\'e-mail';

  @override
  String get resetPasswordErrorUserNotFound =>
      'Aucun compte trouvé avec cet e-mail.';

  @override
  String get resetPasswordErrorUnexpected => 'Erreur inattendue. Réessayez.';

  @override
  String get registerTitle => 'Créer votre compte';

  @override
  String get registerStep => 'Étape 1 sur 2 : Informations de base';

  @override
  String get registerNameLabel => 'Nom complet';

  @override
  String get registerNameHint => 'Jean Dupont';

  @override
  String get registerAlreadyHaveAccount => 'Déjà un compte ? ';

  @override
  String get registerLoginLink => 'Se connecter';

  @override
  String get registerValidationError => 'Veuillez remplir tous les champs';

  @override
  String get healthProfileQuestion =>
      'Avez-vous des restrictions alimentaires ?';

  @override
  String get healthProfileDescription =>
      'Configurez votre profil pour que nous puissions vous dire quels produits vous conviennent.';

  @override
  String get healthProfileFinishButton => 'Terminer l\'inscription';

  @override
  String get healthProfileAccountCreated => 'Compte créé avec succès';

  @override
  String get healthProfileEditTitle => 'Modifier vos données';

  @override
  String get healthProfileEditDescription =>
      'Mettez à jour votre profil pour obtenir des recommandations précises.';

  @override
  String get healthProfileSaveButton => 'Enregistrer les modifications';

  @override
  String get healthProfileSaveSuccess =>
      'Modifications enregistrées avec succès';

  @override
  String get healthProfileSaveError => 'Erreur lors de l\'enregistrement';

  @override
  String get homeDefaultUser => 'Utilisateur';

  @override
  String homeGreeting(String name) {
    return 'Bonjour, $name';
  }

  @override
  String homeProductNotFound(String code) {
    return 'Produit introuvable (code : $code)';
  }

  @override
  String get homeProductApiError =>
      'Erreur lors de la consultation du produit. Vérifiez votre connexion.';

  @override
  String get homeCameraAlreadyActive =>
      'La caméra est déjà active pour scanner';

  @override
  String get configTitle => 'Paramètres';

  @override
  String get configSubtitle => 'Votre profil de configuration';

  @override
  String get configHealthProfileSubtitle => 'Conditions médicales et allergies';

  @override
  String get configAccessibilityTitle => 'Accessibilité';

  @override
  String get configLowVisionTitle => 'Mode basse vision';

  @override
  String get configLowVisionSubtitle =>
      'Augmente le contraste et la taille du texte';

  @override
  String get configLanguageTitle => 'Langue';

  @override
  String get configSignOut => 'Déconnexion';

  @override
  String get configLanguageSpanish => 'Espagnol';

  @override
  String get configLanguageEnglish => 'Anglais';

  @override
  String get configLanguageFrench => 'Français';

  @override
  String get dashboardSearch => 'Rechercher';

  @override
  String get dashboardRecents => 'Récents';

  @override
  String get cameraUnavailable => 'Caméra indisponible';

  @override
  String get cameraScanInstruction => 'Scannez le code-barres';

  @override
  String get productIngredients => 'Ingrédients';

  @override
  String get productIncompatibleLabel => 'Incompatible avec vous';

  @override
  String get productAllergenNotAffecting => 'Allergène (ne vous affecte pas)';

  @override
  String get productNutritionTitle => 'Informations nutritionnelles';

  @override
  String get productNutritionPer100 => 'Pour 100 g / 100 ml';

  @override
  String get productNutritionEnergy => 'Énergie';

  @override
  String get productNutritionFat => 'Matières grasses';

  @override
  String get productNutritionSaturatedFat => '  dont acides gras saturés';

  @override
  String get productNutritionCarbs => 'Glucides';

  @override
  String get productNutritionSugars => '  dont sucres';

  @override
  String get productNutritionFiber => 'Fibres';

  @override
  String get productNutritionProtein => 'Protéines';

  @override
  String get productNutritionSalt => 'Sel';

  @override
  String get productApt => 'Convient pour vous';

  @override
  String get productNotApt => 'Ne convient pas pour vous';

  @override
  String get productIncompatibleProfile => 'Incompatible avec votre profil :';

  @override
  String get productTracesTitle => 'Peut contenir des traces de :';

  @override
  String get productTracesExplanation =>
      'Présence involontaire par contact lors de la production. Évaluez si cela vous concerne.';

  @override
  String get productTracesIngredientLabel => 'Trace (peut vous affecter)';

  @override
  String get searchTitle => 'Rechercher un produit';

  @override
  String get searchInstruction => 'Entrez le code-barres du produit';

  @override
  String get searchHint => 'Ex : 8480017513753';

  @override
  String get searchEmptyState => 'Entrez le code et appuyez sur rechercher';

  @override
  String get searchEmptyCodeError => 'Entrez un code-barres';

  @override
  String get searchProductNotFound => 'Produit introuvable pour ce code';

  @override
  String get recentScansTitle => 'Scans récents';

  @override
  String get recentScansLoadError => 'Erreur lors du chargement des scans';

  @override
  String get recentScansEmpty => 'Vous n\'avez encore scanné aucun produit';

  @override
  String get timeNow => 'À l\'instant';

  @override
  String timeMinutesAgo(int minutes) {
    return 'Il y a $minutes min';
  }

  @override
  String timeHoursAgo(int hours) {
    return 'Il y a $hours h';
  }

  @override
  String get timeYesterday => 'Hier';

  @override
  String timeDaysAgo(int days) {
    return 'Il y a $days jours';
  }

  @override
  String get allergenNuts => 'Fruits à coque';

  @override
  String get allergenLactose => 'Lactose';

  @override
  String get allergenLactoseMilk => 'Lactose / Lait';

  @override
  String get allergenShellfish => 'Crustacés';

  @override
  String get allergenEgg => 'Œuf';

  @override
  String get allergenSoy => 'Soja';

  @override
  String get allergenFish => 'Poisson';

  @override
  String get conditionDiabetic => 'Je suis diabétique';

  @override
  String get conditionCeliac => 'Je suis cœliaque';

  @override
  String get conditionCeliacSubtitle => 'Éviter strictement le gluten';

  @override
  String get aptitudGluten => 'Gluten (maladie cœliaque)';

  @override
  String get aptitudNoNutritionInfo =>
      'Aucune information nutritionnelle — vérifiez le sucre manuellement';

  @override
  String aptitudHighSugar(String value) {
    return 'Teneur élevée en sucre ($value g/100 g)';
  }

  @override
  String get reportButton => 'Signaler une erreur';

  @override
  String get reportDialogTitle => 'Signaler une erreur';

  @override
  String get reportDialogDescription =>
      'Si vous pensez que le résultat est incorrect, décrivez ce qui s\'est passé.';

  @override
  String get reportReasonLabel => 'Motif';

  @override
  String get reportReasonHint =>
      'Ex : le produit est indiqué comme adapté aux diabétiques mais contient beaucoup de sucre';

  @override
  String get reportReasonEmpty => 'Le motif ne peut pas être vide';

  @override
  String get reportSuccess =>
      'Signalement envoyé ! Merci de nous aider à nous améliorer.';

  @override
  String get reportError =>
      'Erreur lors de l\'envoi du signalement. Veuillez réessayer.';
}
