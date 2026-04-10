import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_sign_in/google_sign_in.dart';
import '../services/user_service.dart';
import '../widgets/custom_text_field.dart';
import '../widgets/action_button.dart';
import '../widgets/text_action_button.dart';
import 'register_screen.dart';
import 'home_screen.dart';
import 'package:aptoparati/l10n/app_localizations.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

/// Logo "G" de Google construido con texto coloreado — sin assets externos.
class _GoogleLogo extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 20,
      height: 20,
      child: CustomPaint(painter: _GoogleLogoPainter()),
    );
  }
}

class _GoogleLogoPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final rect = Rect.fromLTWH(0, 0, size.width, size.height);
    const startAngle = -0.52; // ~-30 grados en radianes
    const sweepBlue   = 1.48;
    const sweepRed    = 1.57;
    const sweepYellow = 1.57;
    const sweepGreen  = 1.80;

    final strokeWidth = size.width * 0.18;
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    // Azul
    paint.color = const Color(0xFF4285F4);
    canvas.drawArc(rect.deflate(strokeWidth / 2), startAngle, sweepBlue, false, paint);
    // Rojo
    paint.color = const Color(0xFFEA4335);
    canvas.drawArc(rect.deflate(strokeWidth / 2), startAngle + sweepBlue, sweepRed, false, paint);
    // Amarillo
    paint.color = const Color(0xFFFBBC05);
    canvas.drawArc(rect.deflate(strokeWidth / 2), startAngle + sweepBlue + sweepRed, sweepYellow, false, paint);
    // Verde
    paint.color = const Color(0xFF34A853);
    canvas.drawArc(rect.deflate(strokeWidth / 2), startAngle + sweepBlue + sweepRed + sweepYellow, sweepGreen, false, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  /// Muestra un diálogo para solicitar el restablecimiento de contraseña.
  /// Pre-rellena el campo con el email introducido en el formulario principal.
  /// Invoca [FirebaseAuth.sendPasswordResetEmail] y notifica al usuario mediante SnackBar.
  Future<void> _showPasswordResetDialog() async {
    // Pre-rellenar con el email del formulario principal si ya fue introducido
    final emailController = TextEditingController(
      text: _emailController.text.trim(),
    );

    // Capturar el ScaffoldMessenger antes del async gap para evitar usar
    // un contexto inválido tras cerrar el diálogo
    final scaffoldMessenger = ScaffoldMessenger.of(context);

    await showDialog(
      context: context,
      builder: (dialogContext) {
        bool isSending = false;

        return StatefulBuilder(
          builder: (builderContext, setDialogState) {
            return AlertDialog(
              title: const Text('Restablecer contraseña'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                    'Te enviaremos un correo para restablecer tu contraseña.',
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: emailController,
                    keyboardType: TextInputType.emailAddress,
                    decoration: const InputDecoration(
                      labelText: 'Correo electrónico',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ],
              ),
              actions: [
                // Cancelar deshabilitado durante el envío para evitar double-pop
                TextButton(
                  onPressed: isSending
                      ? null
                      : () {
                          // FocusManager no depende del contexto del diálogo
                          FocusManager.instance.primaryFocus?.unfocus();
                          Navigator.of(dialogContext).pop();
                        },
                  child: const Text('Cancelar'),
                ),
                // Mostrar indicador de carga mientras se envía la petición a Firebase
                isSending
                    ? const Padding(
                        padding: EdgeInsets.symmetric(horizontal: 16),
                        child: SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        ),
                      )
                    : TextButton(
                        onPressed: () async {
                          final email = emailController.text.trim();

                          // Validación: campo vacío — informar al usuario
                          if (email.isEmpty) {
                            scaffoldMessenger.showSnackBar(
                              const SnackBar(
                                content: Text('Introduce tu correo electrónico.'),
                              ),
                            );
                            return;
                          }

                          setDialogState(() => isSending = true);

                          try {
                            // Firebase envía el correo de restablecimiento de forma automática
                            await FirebaseAuth.instance
                                .sendPasswordResetEmail(email: email);

                            // Verificar que el diálogo sigue abierto antes de cerrar y notificar.
                            // Si el usuario cerró el diálogo durante el envío, no hacer nada.
                            if (dialogContext.mounted) {
                              FocusManager.instance.primaryFocus?.unfocus();
                              Navigator.of(dialogContext).pop();
                              scaffoldMessenger.showSnackBar(
                                const SnackBar(
                                  content: Text(
                                    'Correo de restablecimiento enviado. Revisa tu bandeja de entrada.',
                                  ),
                                ),
                              );
                            }
                          } on FirebaseAuthException catch (e) {
                            // Mapeo de códigos de error de Firebase Auth a mensajes en español
                            String message = 'Error al enviar el correo';
                            if (e.code == 'user-not-found') {
                              message = 'No existe una cuenta con ese correo.';
                            } else if (e.code == 'invalid-email') {
                              message = 'El correo no es válido.';
                            }
                            // Restaurar botón en error — el diálogo queda abierto para reintentar
                            if (dialogContext.mounted) {
                              setDialogState(() => isSending = false);
                              scaffoldMessenger.showSnackBar(
                                SnackBar(content: Text(message)),
                              );
                            }
                          } catch (_) {
                            // Error inesperado — restaurar botón y mostrar mensaje genérico
                            if (dialogContext.mounted) {
                              setDialogState(() => isSending = false);
                              scaffoldMessenger.showSnackBar(
                                const SnackBar(
                                  content: Text('Error inesperado. Inténtalo de nuevo.'),
                                ),
                              );
                            }
                          }
                        },
                        child: const Text('Enviar'),
                      ),
              ],
            );
          },
        );
      },
    );

    // Liberar el controlador temporal del diálogo
    emailController.dispose();
  }

  /// Inicia sesión con Google mediante el flujo OAuth estándar.
  /// Si el usuario es nuevo, crea su documento en Firestore con perfil vacío.
  /// Si ya existe, actualiza el campo last_login.
  Future<void> _signInWithGoogle() async {
    setState(() => _isLoading = true);

    try {
      final googleUser = await GoogleSignIn().signIn();

      // El usuario canceló el selector de cuentas
      if (googleUser == null) {
        setState(() => _isLoading = false);
        return;
      }

      final googleAuth = await googleUser.authentication;
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      final userCredential =
          await FirebaseAuth.instance.signInWithCredential(credential);
      final user = userCredential.user!;
      final uid = user.uid;

      // Comprobar si ya existe el documento del usuario en Firestore
      final doc = await FirebaseFirestore.instance
          .collection('users')
          .doc(uid)
          .get();

      if (!doc.exists) {
        // Nuevo usuario de Google — crear documento con perfil de salud vacío
        final now = Timestamp.now();
        await FirebaseFirestore.instance.collection('users').doc(uid).set({
          'personal_info': {
            'email': user.email ?? '',
            'name': user.displayName ?? 'Usuario',
            'created_at': now,
            'last_login': now,
          },
          'subscription': {
            'status': 'free',
            'plan_id': 'basic',
            'expiry_date': null,
          },
          'health_profile': {
            'is_diabetic': false,
            'has_celiac_disease': false,
            'allergens': [],
            'custom_restrictions': [],
          },
          'stats': {'scans_today': 0, 'last_scan_date': now},
        });
      } else {
        // Usuario existente — solo actualizar last_login
        await FirebaseFirestore.instance.collection('users').doc(uid).update({
          'personal_info.last_login': Timestamp.now(),
        });
      }

      await UserService.instance.fetchUserData(uid);

      if (mounted) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => const HomeScreen()),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Error al iniciar sesión con Google. Inténtalo de nuevo.'),
          ),
        );
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _login() async {
    if (_emailController.text.isEmpty || _passwordController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Por favor, ingresa tu correo y contraseña'),
        ),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );

      // Fetch User Data for caching
      await UserService.instance.fetchUserData(
        FirebaseAuth.instance.currentUser!.uid,
      );

      if (mounted) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => const HomeScreen()),
        );
      }
    } on FirebaseAuthException catch (e) {
      String message = 'Error al iniciar sesión';
      if (e.code == 'user-not-found') {
        message = 'No se encontró un usuario con ese correo.';
      } else if (e.code == 'wrong-password') {
        message = 'Contraseña incorrecta.';
      } else if (e.code == 'invalid-email') {
        message = 'El correo no es válido.';
      }

      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(message)));
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error: ${e.toString()}')));
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    // Minimalist color palette
    final primaryColor = Theme.of(context).colorScheme.primary;
    final backgroundColor = Theme.of(context).colorScheme.surface;

    return Scaffold(
      backgroundColor: backgroundColor,
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 40.0),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 400),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Logo / Title area
                Text(
                  'AptoParaTi',
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
                  //TEXTO PASADO A l10n
                  AppLocalizations.of(context)!.loginTagline,
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 16, color: Colors.grey[600]),
                ),
                const SizedBox(height: 48),

                // Email Input
                CustomTextField(
                  controller: _emailController,
                  label: 'Correo electrónico',
                  hint: 'ejemplo@correo.com',
                  keyboardType: TextInputType.emailAddress,
                ),
                const SizedBox(height: 20),

                // Password Input
                CustomTextField(
                  controller: _passwordController,
                  label: 'Contraseña',
                  hint: '••••••••',
                  obscureText: true,
                ),

                const SizedBox(height: 12),

                // Forgot Password Link
                Align(
                  alignment: Alignment.centerRight,
                  child: TextActionButton(
                    text: '¿Olvidaste tu contraseña?',
                    onPressed: _showPasswordResetDialog,
                  ),
                ),

                const SizedBox(height: 32),

                // Login Button
                _isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : ActionButton(text: 'Iniciar Sesión', onPressed: _login),

                const SizedBox(height: 20),

                // Separador "o continúa con"
                Row(
                  children: [
                    Expanded(child: Divider(color: Colors.grey.shade300)),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      child: Text(
                        'o continúa con',
                        style: TextStyle(
                          fontSize: 13,
                          color: Colors.grey.shade500,
                        ),
                      ),
                    ),
                    Expanded(child: Divider(color: Colors.grey.shade300)),
                  ],
                ),

                const SizedBox(height: 16),

                // Botón Google
                OutlinedButton(
                  onPressed: _isLoading ? null : _signInWithGoogle,
                  style: OutlinedButton.styleFrom(
                    minimumSize: const Size(double.infinity, 50),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    side: BorderSide(color: Colors.grey.shade300),
                    backgroundColor: Colors.white,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Logo "G" de Google con sus colores corporativos
                      _GoogleLogo(),
                      const SizedBox(width: 10),
                      const Text(
                        'Continuar con Google',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w500,
                          color: Colors.black87,
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 24),

                // Register Link
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      '¿No tienes cuenta? ',
                      style: TextStyle(color: Colors.grey[600]),
                    ),
                    TextActionButton(
                      text: 'Regístrate',
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const RegisterScreen(),
                          ),
                        );
                      },
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
