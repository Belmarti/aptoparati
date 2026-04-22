import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import '../services/user_service.dart';
import '../widgets/camera_viewfinder.dart';
import '../widgets/dashboard_actions.dart';
import '../widgets/product_result_card.dart';
import 'package:openfoodfacts/openfoodfacts.dart';
import 'user_config_screen.dart';
import 'search_screen.dart';
import 'recent_scans_screen.dart';

/// Pantalla principal de la aplicación tras el login.
/// Muestra la cámara de escaneo a pantalla completa con un header flotante
/// y un panel de acciones en la parte inferior.

void setupOFF() {
  // Configuración global (opcional pero recomendada)
  OpenFoodAPIConfiguration.userAgent = UserAgent(
    name: 'NombreDeTuApp',
    version: '1.0.0',
    system: 'Android/iOS',
  );
  // Definimos que queremos resultados en español
  OpenFoodAPIConfiguration.globalLanguages = [OpenFoodFactsLanguage.SPANISH];
  OpenFoodAPIConfiguration.globalCountry = OpenFoodFactsCountry.SPAIN;
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {

  /// Producto recuperado de OFF tras el último escaneo exitoso.
  Product? _lastProduct;

  /// true mientras se consulta la API.
  bool _isFetchingProduct = false;

  /// true mientras la card de resultado está abierta (bloquea nuevos escaneos).
  bool _cardVisible = false;

  /// Controlador de la cámara — se para al abrir la card y se reanuda al cerrarla.
  final MobileScannerController _cameraController = MobileScannerController();

  @override
  void initState() {
    super.initState();
    setupOFF();
  }

  @override
  void dispose() {
    _cameraController.dispose();
    super.dispose();
  }

  /// Callback que recibe el código de barras detectado por [CameraViewfinder].
  /// Consulta la API de Open Food Facts y guarda el [Product] resultante.
  Future<void> _onBarcodeScanned(String code) async {
    // Bloquear si hay petición en curso o card visible
    if (_isFetchingProduct || _cardVisible) return;

    setState(() => _isFetchingProduct = true);

    try {
      final config = ProductQueryConfiguration(
        code,
        version: ProductQueryVersion.v3,
        fields: [ProductField.ALL],
      );

      //llamada a OFF con el get de code,version y fields que queremos
      final result = await OpenFoodAPIClient.getProductV3(config);

      if (!mounted) return;

      if (result.product != null) {
        setState(() {
          _lastProduct = result.product;
          _isFetchingProduct = false;
          _cardVisible = true;
          // La cámara NO se pausa: sigue corriendo pero _cardVisible bloquea
          // el procesamiento de nuevos escaneos. Evita el ciclo pause()/start()
          // que genera conflictos con el gestor de ciclo de vida de MobileScanner.
        });

        // Guardar en historial de recientes (fire & forget, no bloquea la UI)
        final uid = FirebaseAuth.instance.currentUser?.uid;
        if (uid != null) {
          UserService.instance.saveRecentScan(
            uid,
            barcode: code,
            name: result.product!.productName ?? 'Producto sin nombre',
            imgUrl: result.product!.imageFrontSmallUrl ?? '',
          );
        }

        await _mostrarResultadoProducto(result.product!);
        if (mounted) {
          // La cámara sigue corriendo — solo restaurar el flag para aceptar escaneos
          setState(() => _cardVisible = false);
        }
      } else {
        if (result.result?.id == ProductResultV3.resultProductNotFound) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Producto no encontrado (código: $code)')),
          );
        }
        setState(() => _isFetchingProduct = false);
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Error al consultar el producto. Comprueba tu conexión.')),
      );
      setState(() => _isFetchingProduct = false);
    }
  }

  /// Detiene la cámara, navega a [screen] y la reanuda al volver.
  ///
  /// Por qué es necesario:
  /// El widget MobileScanner registra su propio WidgetsBindingObserver y llama
  /// start() al recibir AppLifecycleState.resumed. Si durante la navegación el
  /// usuario minimiza y restaura la app (o cierra un modal en Android, que puede
  /// disparar resumed), MobileScanner inicia la cámara. Al volver nosotros también
  /// intentaríamos iniciarla → doble start → error.
  ///
  /// Solución:
  /// 1. stop() con guard antes de navegar.
  /// 2. Al volver, solo llamar start() si la cámara no fue ya iniciada
  ///    por el gestor de ciclo de vida de MobileScanner (isRunning == false).
  /// 3. try/catch como última línea de defensa ante la race condition donde
  ///    isRunning aún no refleja el inicio en curso del lifecycle handler.
  /// 
  Future<void> _navigateWithCameraStop(Widget screen) async {
    try {
      await _cameraController.stop();
    } catch (_) {}
    if (!mounted) return;

    await Navigator.of(context).push(
      MaterialPageRoute(builder: (context) => screen),
    );

    if (!mounted) return;
    // Solo arrancar si MobileScanner no lo hizo ya durante la navegación
    if (!_cameraController.value.isRunning) {
      try {
        await _cameraController.start();
      } catch (_) {}
    }
  }

  /// Muestra la card de resultado y espera a que el usuario la cierre.
  Future<void> _mostrarResultadoProducto(Product product) async {
    final healthProfile = Map<String, dynamic>.from(
      UserService.instance.currentUserData?['health_profile'] ?? {},
    );

    await showProductResultCard(
      context,
      product: product,
      healthProfile: healthProfile,
    );
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    final userData = UserService.instance.currentUserData;

    // Obtener nombre del usuario desde la caché de UserService
    String displayName = 'Usuario';
    String initials = 'U';

    if (userData != null && userData['personal_info'] != null) {
      displayName = userData['personal_info']['name'] ?? 'Usuario';
    }

    // Calcular inicial para el avatar: primera letra del nombre,
    // o primera letra del email como fallback
    if (displayName != 'Usuario' && displayName.isNotEmpty) {
      initials = displayName[0].toUpperCase();
    } else if (user?.email?.isNotEmpty ?? false) {
      initials = user!.email![0].toUpperCase();
    }

    // Layout: Column — cámara ocupa espacio restante, barra inferior a su altura natural.
    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: [
          // 1. Área de cámara con header flotante encima
          Expanded(
            child: Stack(
              children: [
                Positioned.fill(
                  child: CameraViewfinder(
                    onScan: _onBarcodeScanned,
                    controller: _cameraController,
                  ),
                ),

                // Header flotante con saludo y avatar del usuario
                Positioned(
                  top: 0,
                  left: 0,
                  right: 0,
                  child: SafeArea(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24.0,
                        vertical: 16.0,
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          // Saludo con nombre del usuario
                          Text(
                            'Hola, $displayName',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              shadows: [
                                Shadow(
                                  color: Colors.black45,
                                  blurRadius: 4,
                                  offset: Offset(0, 2),
                                ),
                              ],
                            ),
                          ),

                          // Avatar circular — al pulsar navega a UserConfigScreen
                          GestureDetector(
                            onTap: () => _navigateWithCameraStop(
                              const UserConfigScreen(),
                            ),
                            child: Container(
                              width: 44,
                              height: 44,
                              decoration: BoxDecoration(
                                color: Colors.white,
                                shape: BoxShape.circle,
                                border:
                                    Border.all(color: Colors.white, width: 2),
                                boxShadow: const [
                                  BoxShadow(
                                    color: Colors.black26,
                                    blurRadius: 8,
                                    offset: Offset(0, 2),
                                  ),
                                ],
                              ),
                              child: Center(
                                child: Text(
                                  initials,
                                  style: TextStyle(
                                    color: Theme.of(context).primaryColor,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 18,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),

          // 2. Panel de acciones inferior a su altura natural
          SafeArea(
            top: false,
            child: DashboardActions(
              onSearchTap: () => _navigateWithCameraStop(const SearchScreen()),
              onHistoryTap: () => _navigateWithCameraStop(const RecentScansScreen()),
              onScanTap: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('La cámara ya está activa para escanear'),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
