import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:openfoodfacts/openfoodfacts.dart';
import '../services/user_service.dart';
import '../widgets/product_result_card.dart';

/// Pantalla de búsqueda manual por código de barras.
/// El usuario introduce el código numérico a mano y se consulta OFF.
class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final TextEditingController _controller = TextEditingController();
  final FocusNode _focusNode = FocusNode();

  bool _isFetching = false;
  String? _errorMsg;

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  /// Lanza la búsqueda con el código introducido.
  Future<void> _buscar() async {
    final codigo = _controller.text.trim();

    if (codigo.isEmpty) {
      setState(() => _errorMsg = 'Introduce un código de barras');
      return;
    }

    setState(() {
      _isFetching = true;
      _errorMsg = null;
    });

    try {
      final config = ProductQueryConfiguration(
        codigo,
        version: ProductQueryVersion.v3,
        fields: [ProductField.ALL],
      );

      final result = await OpenFoodAPIClient.getProductV3(config);

      if (!mounted) return;

      if (result.product != null) {
        setState(() => _isFetching = false);

        // Guardar en historial de recientes (fire & forget, no bloquea la UI)
        final uid = FirebaseAuth.instance.currentUser?.uid;
        if (uid != null) {
          UserService.instance.saveRecentScan(
            uid,
            barcode: codigo,
            name: result.product!.productName ?? 'Producto sin nombre',
            imgUrl: result.product!.imageFrontSmallUrl ?? '',
          );
        }

        final healthProfile = Map<String, dynamic>.from(
          UserService.instance.currentUserData?['health_profile'] ?? {},
        );

        await showProductResultCard(
          context,
          product: result.product!,
          healthProfile: healthProfile,
        );
      } else {
        setState(() {
          _isFetching = false;
          _errorMsg = 'Producto no encontrado para ese código';
        });
      }
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isFetching = false;
        _errorMsg = 'Error de conexión. Comprueba tu red.';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final primaryColor = Theme.of(context).primaryColor;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded, color: Colors.black87),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text(
          'Buscar producto',
          style: TextStyle(
            color: Colors.black87,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Instrucción
            Text(
              'Introduce el código de barras del producto',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey.shade600,
              ),
            ),
            const SizedBox(height: 16),

            // Campo de entrada + botón
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: TextField(
                    controller: _controller,
                    focusNode: _focusNode,
                    keyboardType: TextInputType.number,
                    // Solo acepta dígitos
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                    textInputAction: TextInputAction.search,
                    onSubmitted: (_) => _buscar(),
                    decoration: InputDecoration(
                      hintText: 'Ej: 8480017513753',
                      hintStyle: TextStyle(color: Colors.grey.shade400),
                      prefixIcon: Icon(
                        Icons.tag_rounded,
                        color: Colors.grey.shade500,
                        size: 20,
                      ),
                      errorText: _errorMsg,
                      filled: true,
                      fillColor: Colors.grey.shade50,
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 14,
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: Colors.grey.shade300),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: Colors.grey.shade300),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: primaryColor, width: 1.5),
                      ),
                      errorBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(color: Color(0xFFE53935)),
                      ),
                      focusedErrorBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(
                          color: Color(0xFFE53935),
                          width: 1.5,
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 10),

                // Botón buscar
                SizedBox(
                  height: 50,
                  child: ElevatedButton(
                    onPressed: _isFetching ? null : _buscar,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: primaryColor,
                      foregroundColor: Colors.white,
                      disabledBackgroundColor: primaryColor.withValues(alpha: 0.5),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      padding: const EdgeInsets.symmetric(horizontal: 18),
                      elevation: 0,
                    ),
                    child: _isFetching
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : const Icon(Icons.search_rounded, size: 22),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 32),

            // Ilustración / estado vacío
            Expanded(
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.barcode_reader,
                      size: 72,
                      color: Colors.grey.shade200,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Introduce el código y pulsa buscar',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey.shade400,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
