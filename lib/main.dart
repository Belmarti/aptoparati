import 'package:aptoparati/firebase_options.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';
import 'package:aptoparati/l10n/app_localizations.dart';
import 'package:aptoparati/screens/login_screen.dart';
import 'package:aptoparati/services/theme_service.dart';
import 'package:aptoparati/theme/app_themes.dart';

void main() async {
  // 1. Asegura que los widgets estén listos antes de usar plugins
  WidgetsFlutterBinding.ensureInitialized();

  // 2. Inicializa Firebase usando las opciones generadas para tu plataforma actual
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  // 3. Carga la preferencia de tema antes de arrancar la UI
  final themeService = ThemeService();
  await themeService.loadFromPrefs();

  runApp(
    ChangeNotifierProvider.value(
      value: themeService,
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    // Consumer reconstruye MaterialApp al cambiar el tema → cambio instantáneo
    return Consumer<ThemeService>(
      builder: (context, themeService, _) {
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
          theme: themeService.isLowVision
              ? AppThemes.themeBajaVision
              : AppThemes.themeEstandar,
          debugShowCheckedModeBanner: false,
          home: const LoginScreen(),
        );
      },
    );
  }
}
