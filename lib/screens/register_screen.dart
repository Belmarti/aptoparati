import 'package:flutter/material.dart';
import '../widgets/custom_text_field.dart';
import '../widgets/action_button.dart';
import '../widgets/text_action_button.dart';
import 'intolerances_screen.dart';
import 'package:aptoparati/l10n/app_localizations.dart';

/// Pantalla del paso 1 de 2 del registro.
/// Recoge nombre, email y contraseña del usuario y, si son válidos,
/// navega al paso 2 (IntolerancesScreen) pasando los datos como parámetros.
class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  void dispose() {
    // Liberar controladores al destruir el widget para evitar memory leaks
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  /// Valida que todos los campos estén rellenos y navega al paso 2.
  /// Los datos se pasan a [IntolerancesScreen] que ejecutará el registro real
  /// en Firebase al finalizar el segundo paso.
  void _goToStep2() {
    final l10n = AppLocalizations.of(context)!;

    if (_nameController.text.isEmpty ||
        _emailController.text.isEmpty ||
        _passwordController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.registerValidationError)),
      );
      return;
    }

    // Navegar al paso 2 pasando los datos recogidos en este paso
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => IntolerancesScreen(
          name: _nameController.text.trim(),
          email: _emailController.text.trim(),
          password: _passwordController.text.trim(),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final primaryColor = Theme.of(context).colorScheme.primary;
    final backgroundColor = Theme.of(context).colorScheme.surface;

    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        // Botón de retroceso para volver al LoginScreen
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.grey[800]),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 20.0),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 400),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  l10n.registerTitle,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    letterSpacing: -0.5,
                    color: primaryColor,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  l10n.registerStep,
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 16, color: Colors.grey[600]),
                ),
                const SizedBox(height: 48),

                // Campo de nombre completo
                CustomTextField(
                  controller: _nameController,
                  label: l10n.registerNameLabel,
                  hint: l10n.registerNameHint,
                ),
                const SizedBox(height: 20),

                // Campo de correo electrónico
                CustomTextField(
                  controller: _emailController,
                  label: l10n.emailLabel,
                  hint: l10n.emailHint,
                  keyboardType: TextInputType.emailAddress,
                ),
                const SizedBox(height: 20),

                // Campo de contraseña con texto oculto
                CustomTextField(
                  controller: _passwordController,
                  label: l10n.passwordLabel,
                  hint: l10n.passwordHint,
                  obscureText: true,
                ),

                const SizedBox(height: 32),

                // Botón que valida y avanza al paso 2
                ActionButton(text: l10n.continueButton, onPressed: _goToStep2),

                const SizedBox(height: 24),

                // Enlace para volver al login si el usuario ya tiene cuenta
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      l10n.registerAlreadyHaveAccount,
                      style: TextStyle(color: Colors.grey[600]),
                    ),
                    TextActionButton(
                      text: l10n.registerLoginLink,
                      onPressed: () => Navigator.pop(context),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
