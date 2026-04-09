import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:openfoodfacts/openfoodfacts.dart';
import '../services/user_service.dart';
import '../widgets/product_result_card.dart';

/// Pantalla de escaneos recientes.
/// Muestra los últimos 5 productos escaneados por el usuario,
/// recuperados desde la subcolección `recent_scans` de Firestore.
class RecentScansScreen extends StatefulWidget {
  const RecentScansScreen({super.key});

  @override
  State<RecentScansScreen> createState() => _RecentScansScreenState();
}

class _RecentScansScreenState extends State<RecentScansScreen> {
  /// ID del escaneo que se está cargando en ese momento (para mostrar indicador).
  String? _loadingId;

  /// Consulta la subcolección `recent_scans` del usuario actual.
  Future<List<Map<String, dynamic>>> _fetchRecentScans() async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return [];

    final snapshot = await FirebaseFirestore.instance
        .collection('users')
        .doc(uid)
        .collection('recent_scans')
        .orderBy('scanned_at', descending: true)
        .limit(5)
        .get();

    return snapshot.docs.map((doc) => {'id': doc.id, ...doc.data()}).toList();
  }

  /// Busca el producto en OFF por su código y muestra la card de resultado.
  Future<void> _abrirProducto(String scanId, String barcode) async {
    setState(() => _loadingId = scanId);

    try {
      final config = ProductQueryConfiguration(
        barcode,
        version: ProductQueryVersion.v3,
        fields: [ProductField.ALL],
      );

      final result = await OpenFoodAPIClient.getProductV3(config);

      if (!mounted) return;

      if (result.product != null) {
        setState(() => _loadingId = null);

        final healthProfile = Map<String, dynamic>.from(
          UserService.instance.currentUserData?['health_profile'] ?? {},
        );

        await showProductResultCard(
          context,
          product: result.product!,
          healthProfile: healthProfile,
        );
      } else {
        setState(() => _loadingId = null);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Producto no encontrado (código: $barcode)')),
          );
        }
      }
    } catch (e) {
      if (!mounted) return;
      setState(() => _loadingId = null);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Error de conexión. Comprueba tu red.'),
        ),
      );
    }
  }

  /// Formatea la fecha de escaneo como tiempo relativo en español.
  String _tiempoRelativo(DateTime fecha) {
    final diff = DateTime.now().difference(fecha);
    if (diff.inMinutes < 1) return 'Ahora mismo';
    if (diff.inMinutes < 60) return 'Hace ${diff.inMinutes} min';
    if (diff.inHours < 24) return 'Hace ${diff.inHours} h';
    if (diff.inDays == 1) return 'Ayer';
    return 'Hace ${diff.inDays} días';
  }

  @override
  Widget build(BuildContext context) {
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
          'Escaneos recientes',
          style: TextStyle(
            color: Colors.black87,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: _fetchRecentScans(),
        builder: (context, snapshot) {
          // Estado de carga inicial
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          // Error al cargar
          if (snapshot.hasError) {
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.error_outline,
                      size: 48, color: Colors.grey.shade400),
                  const SizedBox(height: 12),
                  Text(
                    'Error al cargar los escaneos',
                    style: TextStyle(color: Colors.grey.shade500),
                  ),
                ],
              ),
            );
          }

          final scans = snapshot.data ?? [];

          // Estado vacío
          if (scans.isEmpty) {
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.history_rounded,
                      size: 72, color: Colors.grey.shade200),
                  const SizedBox(height: 16),
                  Text(
                    'Aún no has escaneado ningún producto',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey.shade400,
                    ),
                  ),
                ],
              ),
            );
          }

          return ListView.separated(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
            itemCount: scans.length,
            separatorBuilder: (_, __) => const SizedBox(height: 10),
            itemBuilder: (context, index) {
              final scan = scans[index];
              final scanId = scan['id'] as String;
              final barcode = scan['barcode'] as String? ?? '';
              final name = scan['name'] as String? ?? 'Producto sin nombre';
              final imgUrl = scan['img_url'] as String? ?? '';

              // scanned_at puede ser null si el serverTimestamp aún no se resolvió
              DateTime? fecha;
              final ts = scan['scanned_at'];
              if (ts is Timestamp) fecha = ts.toDate();

              final isLoading = _loadingId == scanId;

              return _ScanCard(
                name: name,
                barcode: barcode,
                imgUrl: imgUrl,
                tiempoRelativo: fecha != null ? _tiempoRelativo(fecha) : '',
                isLoading: isLoading,
                onTap: isLoading ? null : () => _abrirProducto(scanId, barcode),
              );
            },
          );
        },
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Card individual de escaneo reciente
// ---------------------------------------------------------------------------

class _ScanCard extends StatelessWidget {
  final String name;
  final String barcode;
  final String imgUrl;
  final String tiempoRelativo;
  final bool isLoading;
  final VoidCallback? onTap;

  const _ScanCard({
    required this.name,
    required this.barcode,
    required this.imgUrl,
    required this.tiempoRelativo,
    required this.isLoading,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.grey.shade200),
          ),
          child: Row(
            children: [
              // Imagen del producto
              Container(
                width: 64,
                height: 64,
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: Colors.grey.shade200),
                ),
                clipBehavior: Clip.hardEdge,
                child: imgUrl.isNotEmpty
                    ? Image.network(
                        imgUrl,
                        fit: BoxFit.contain,
                        errorBuilder: (_, __, ___) =>
                            const _PlaceholderImg(),
                      )
                    : const _PlaceholderImg(),
              ),
              const SizedBox(width: 14),

              // Nombre, código y tiempo
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      name,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Colors.black87,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      barcode,
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey.shade500,
                        fontFamily: 'monospace',
                      ),
                    ),
                    if (tiempoRelativo.isNotEmpty) ...[
                      const SizedBox(height: 2),
                      Text(
                        tiempoRelativo,
                        style: TextStyle(
                          fontSize: 11,
                          color: Colors.grey.shade400,
                        ),
                      ),
                    ],
                  ],
                ),
              ),

              // Indicador de carga o chevron
              const SizedBox(width: 8),
              SizedBox(
                width: 24,
                height: 24,
                child: isLoading
                    ? CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Theme.of(context).primaryColor,
                      )
                    : Icon(
                        Icons.chevron_right_rounded,
                        color: Colors.grey.shade400,
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _PlaceholderImg extends StatelessWidget {
  const _PlaceholderImg();

  @override
  Widget build(BuildContext context) {
    return Icon(
      Icons.image_not_supported_outlined,
      size: 28,
      color: Colors.grey.shade400,
    );
  }
}
