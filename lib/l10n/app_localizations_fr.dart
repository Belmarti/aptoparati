import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

class AppLocalizationsFr extends AppLocalizations {
  AppLocalizationsFr([String locale = 'fr']) : super(locale);

  @override
  String get appTitle => 'AptoParaTi';

  @override
  String get welcomeMessage => 'Bienvenue sur AptoParaTi';

  @override
  String get loginTagline => 'Votre guide nutritionnel';
}
