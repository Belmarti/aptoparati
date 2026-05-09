// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'AptoParaTi';

  @override
  String get welcomeMessage => 'Welcome to AptoParaTi';

  @override
  String get loginTagline => 'Your nutrition guide';

  @override
  String get emailLabel => 'Email';

  @override
  String get emailHint => 'example@email.com';

  @override
  String get passwordLabel => 'Password';

  @override
  String get passwordHint => '••••••••';

  @override
  String get cancelButton => 'Cancel';

  @override
  String get sendButton => 'Send';

  @override
  String get continueButton => 'Continue';

  @override
  String get noDataAvailable => 'Not available';

  @override
  String get healthProfileTitle => 'Health Profile';

  @override
  String get allergiesAndIntolerances => 'Allergies & Intolerances';

  @override
  String get productNameUnknown => 'Unknown product';

  @override
  String get errorConnection => 'Connection error. Check your network.';

  @override
  String get loginForgotPassword => 'Forgot your password?';

  @override
  String get loginButton => 'Log In';

  @override
  String get loginOrContinueWith => 'or continue with';

  @override
  String get loginWithGoogle => 'Continue with Google';

  @override
  String get loginNoAccount => 'Don\'t have an account? ';

  @override
  String get loginRegisterLink => 'Sign Up';

  @override
  String get loginErrorEmailPasswordEmpty =>
      'Please enter your email and password';

  @override
  String get loginErrorGoogle =>
      'Error signing in with Google. Please try again.';

  @override
  String get loginErrorGeneric => 'Error signing in';

  @override
  String get loginErrorUserNotFound => 'No user found with that email.';

  @override
  String get loginErrorWrongPassword => 'Incorrect password.';

  @override
  String get loginErrorInvalidEmail => 'The email is not valid.';

  @override
  String get resetPasswordTitle => 'Reset password';

  @override
  String get resetPasswordDescription =>
      'We\'ll send you an email to reset your password.';

  @override
  String get resetPasswordEmptyEmail => 'Enter your email address.';

  @override
  String get resetPasswordSuccessMessage =>
      'Reset email sent. Check your inbox.';

  @override
  String get resetPasswordErrorGeneric => 'Error sending email';

  @override
  String get resetPasswordErrorUserNotFound =>
      'No account found with that email.';

  @override
  String get resetPasswordErrorUnexpected =>
      'Unexpected error. Please try again.';

  @override
  String get registerTitle => 'Create your account';

  @override
  String get registerStep => 'Step 1 of 2: Basic information';

  @override
  String get registerNameLabel => 'Full name';

  @override
  String get registerNameHint => 'John Doe';

  @override
  String get registerAlreadyHaveAccount => 'Already have an account? ';

  @override
  String get registerLoginLink => 'Log In';

  @override
  String get registerValidationError => 'Please fill in all fields';

  @override
  String get healthProfileQuestion => 'Do you have any restrictions?';

  @override
  String get healthProfileDescription =>
      'Set up your profile so we can tell you which products are suitable for you.';

  @override
  String get healthProfileFinishButton => 'Finish Registration';

  @override
  String get healthProfileAccountCreated => 'Account created successfully';

  @override
  String get healthProfileEditTitle => 'Edit your data';

  @override
  String get healthProfileEditDescription =>
      'Update your profile to get accurate recommendations.';

  @override
  String get healthProfileSaveButton => 'Save Changes';

  @override
  String get healthProfileSaveSuccess => 'Changes saved successfully';

  @override
  String get healthProfileSaveError => 'Error saving changes';

  @override
  String get homeDefaultUser => 'User';

  @override
  String homeGreeting(String name) {
    return 'Hello, $name';
  }

  @override
  String homeProductNotFound(String code) {
    return 'Product not found (code: $code)';
  }

  @override
  String get homeProductApiError =>
      'Error querying product. Check your connection.';

  @override
  String get homeCameraAlreadyActive => 'Camera is already active for scanning';

  @override
  String get configTitle => 'Settings';

  @override
  String get configSubtitle => 'Your settings profile';

  @override
  String get configHealthProfileSubtitle => 'Medical conditions and allergies';

  @override
  String get configAccessibilityTitle => 'Accessibility';

  @override
  String get configLowVisionTitle => 'Low vision mode';

  @override
  String get configLowVisionSubtitle => 'Increases contrast and text size';

  @override
  String get configLanguageTitle => 'Language';

  @override
  String get configSignOut => 'Sign out';

  @override
  String get configLanguageSpanish => 'Spanish';

  @override
  String get configLanguageEnglish => 'English';

  @override
  String get configLanguageFrench => 'French';

  @override
  String get dashboardSearch => 'Search';

  @override
  String get dashboardRecents => 'Recent';

  @override
  String get cameraUnavailable => 'Camera unavailable';

  @override
  String get cameraScanInstruction => 'Scan the barcode';

  @override
  String get productIngredients => 'Ingredients';

  @override
  String get productIncompatibleLabel => 'Incompatible with you';

  @override
  String get productAllergenNotAffecting => 'Allergen (doesn\'t affect you)';

  @override
  String get productNutritionTitle => 'Nutritional information';

  @override
  String get productNutritionPer100 => 'Per 100 g / 100 ml';

  @override
  String get productNutritionEnergy => 'Energy';

  @override
  String get productNutritionFat => 'Fat';

  @override
  String get productNutritionSaturatedFat => '  of which saturates';

  @override
  String get productNutritionCarbs => 'Carbohydrates';

  @override
  String get productNutritionSugars => '  of which sugars';

  @override
  String get productNutritionFiber => 'Fibre';

  @override
  String get productNutritionProtein => 'Protein';

  @override
  String get productNutritionSalt => 'Salt';

  @override
  String get productApt => 'Suitable for you';

  @override
  String get productNotApt => 'Not suitable for you';

  @override
  String get productIncompatibleProfile => 'Incompatible with your profile:';

  @override
  String get searchTitle => 'Search product';

  @override
  String get searchInstruction => 'Enter the product barcode';

  @override
  String get searchHint => 'e.g. 8480017513753';

  @override
  String get searchEmptyState => 'Enter the code and tap search';

  @override
  String get searchEmptyCodeError => 'Enter a barcode';

  @override
  String get searchProductNotFound => 'Product not found for that code';

  @override
  String get recentScansTitle => 'Recent scans';

  @override
  String get recentScansLoadError => 'Error loading scans';

  @override
  String get recentScansEmpty => 'You haven\'t scanned any product yet';

  @override
  String get timeNow => 'Just now';

  @override
  String timeMinutesAgo(int minutes) {
    return '$minutes min ago';
  }

  @override
  String timeHoursAgo(int hours) {
    return '$hours h ago';
  }

  @override
  String get timeYesterday => 'Yesterday';

  @override
  String timeDaysAgo(int days) {
    return '$days days ago';
  }

  @override
  String get allergenNuts => 'Tree nuts';

  @override
  String get allergenLactose => 'Lactose';

  @override
  String get allergenLactoseMilk => 'Lactose / Milk';

  @override
  String get allergenShellfish => 'Shellfish';

  @override
  String get allergenEgg => 'Egg';

  @override
  String get allergenSoy => 'Soy';

  @override
  String get allergenFish => 'Fish';

  @override
  String get conditionDiabetic => 'I am diabetic';

  @override
  String get conditionCeliac => 'I am coeliac';

  @override
  String get conditionCeliacSubtitle => 'Strictly avoid gluten';

  @override
  String get aptitudGluten => 'Gluten (coeliac disease)';

  @override
  String get aptitudNoNutritionInfo =>
      'No nutritional information — check sugar manually';

  @override
  String aptitudHighSugar(String value) {
    return 'High sugar content ($value g/100 g)';
  }

  @override
  String get reportButton => 'Report error';

  @override
  String get reportDialogTitle => 'Report an error';

  @override
  String get reportDialogDescription =>
      'If you think the result is incorrect, tell us what happened.';

  @override
  String get reportReasonLabel => 'Reason';

  @override
  String get reportReasonHint =>
      'E.g.: the product appears suitable for diabetics but has a lot of sugar';

  @override
  String get reportReasonEmpty => 'The reason cannot be empty';

  @override
  String get reportSuccess => 'Report sent! Thank you for helping us improve.';

  @override
  String get reportError => 'Error sending the report. Please try again.';
}
