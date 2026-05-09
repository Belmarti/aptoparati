import 'package:aptoparati/firebase_options.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';
import 'package:aptoparati/l10n/app_localizations.dart';
import 'package:aptoparati/screens/login_screen.dart';
import 'package:aptoparati/services/theme_service.dart';
import 'package:aptoparati/services/locale_service.dart';
import 'package:aptoparati/theme/app_themes.dart';

void main() async {
  // 1. Asegura que los widgets estén listos antes de usar plugins
  WidgetsFlutterBinding.ensureInitialized();

  // 2. Inicializa Firebase usando las opciones generadas para tu plataforma actual
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  // 3. Carga preferencias de tema e idioma antes de arrancar la UI
  final themeService = ThemeService();
  final localeService = LocaleService();
  await Future.wait([
    themeService.loadFromPrefs(),
    localeService.loadFromPrefs(),
  ]);

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider.value(value: themeService),
        ChangeNotifierProvider.value(value: localeService),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    // Escucha ambos servicios para reconstruir MaterialApp al cambiar tema o idioma
    final themeService = context.watch<ThemeService>();
    final localeService = context.watch<LocaleService>();

    return MaterialApp(
      title: 'AptoParaTi',
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [
        Locale('es'),
        Locale('en'),
        Locale('fr'),
      ],
      locale: localeService.locale,
      theme: themeService.isLowVision
          ? AppThemes.themeBajaVision
          : AppThemes.themeEstandar,
      debugShowCheckedModeBanner: false,
      home: const LoginScreen(),
    );
  }
}
