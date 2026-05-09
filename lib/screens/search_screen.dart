import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:openfoodfacts/openfoodfacts.dart';
import '../services/user_service.dart';
import '../widgets/product_result_card.dart';
import '../widgets/dashboard_actions.dart';
import 'recent_scans_screen.dart';
import 'package:aptoparati/l10n/app_localizations.dart';

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
    final l10n = AppLocalizations.of(context)!;
    final codigo = _controller.text.trim();

    if (codigo.isEmpty) {
      setState(() => _errorMsg = l10n.searchEmptyCodeError);
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
            name: result.product!.productName ?? l10n.productNameUnknown,
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
          _errorMsg = l10n.searchProductNotFound;
        });
      }
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isFetching = false;
        _errorMsg = l10n.errorConnection;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final colorScheme = Theme.of(context).colorScheme;
    final primaryColor = colorScheme.primary;

    return Scaffold(
      bottomNavigationBar: DashboardActions(
        onSearchTap: () {},
        onScanTap: () => Navigator.pop(context),
        onHistoryTap: () => Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const RecentScansScreen()),
        ),
      ),
      appBar: AppBar(
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          l10n.searchTitle,
          style: const TextStyle(
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
              l10n.searchInstruction,
              style: TextStyle(
                fontSize: 14,
                color: colorScheme.onSurfaceVariant,
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
                      hintText: l10n.searchHint,
                      hintStyle: TextStyle(color: colorScheme.onSurfaceVariant),
                      prefixIcon: Icon(
                        Icons.tag_rounded,
                        color: colorScheme.onSurfaceVariant,
                        size: 20,
                      ),
                      errorText: _errorMsg,
                      filled: true,
                      fillColor: colorScheme.surfaceContainerHighest,
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 14,
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: colorScheme.outlineVariant),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: colorScheme.outlineVariant),
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
                      // Evita que el tema de baja visión (minimumSize: double.infinity)
                      // rompa el layout al estar dentro de un Row con Expanded.
                      minimumSize: Size.zero,
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
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
                      color: colorScheme.outlineVariant,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      l10n.searchEmptyState,
                      style: TextStyle(
                        fontSize: 14,
                        color: colorScheme.onSurfaceVariant,
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
