import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'AptoParaTi';

  @override
  String get welcomeMessage => 'Welcome to AptoParaTi';

  @override
  String get loginTagline => 'Your nutrition guide';
}
