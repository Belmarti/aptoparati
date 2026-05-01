import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:openfoodfacts/openfoodfacts.dart';
import '../services/user_service.dart';
import '../widgets/product_result_card.dart';
import 'package:aptoparati/l10n/app_localizations.dart';

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
          final l10n = AppLocalizations.of(context)!;
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(l10n.homeProductNotFound(barcode))),
          );
        }
      }
    } catch (e) {
      if (!mounted) return;
      setState(() => _loadingId = null);
      final l10n = AppLocalizations.of(context)!;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.errorConnection)),
      );
    }
  }

  /// Formatea la fecha de escaneo como tiempo relativo localizado.
  String _tiempoRelativo(AppLocalizations l10n, DateTime fecha) {
    final diff = DateTime.now().difference(fecha);
    if (diff.inMinutes < 1) return l10n.timeNow;
    if (diff.inMinutes < 60) return l10n.timeMinutesAgo(diff.inMinutes);
    if (diff.inHours < 24) return l10n.timeHoursAgo(diff.inHours);
    if (diff.inDays == 1) return l10n.timeYesterday;
    return l10n.timeDaysAgo(diff.inDays);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          l10n.recentScansTitle,
          style: const TextStyle(
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
                      size: 48, color: colorScheme.onSurfaceVariant),
                  const SizedBox(height: 12),
                  Text(
                    l10n.recentScansLoadError,
                    style: TextStyle(color: colorScheme.onSurfaceVariant),
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
                      size: 72, color: colorScheme.outlineVariant),
                  const SizedBox(height: 16),
                  Text(
                    l10n.recentScansEmpty,
                    style: TextStyle(
                      fontSize: 14,
                      color: colorScheme.onSurfaceVariant,
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
              final name = scan['name'] as String? ?? l10n.productNameUnknown;
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
                tiempoRelativo: fecha != null ? _tiempoRelativo(l10n, fecha) : '',
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
    final colorScheme = Theme.of(context).colorScheme;

    return Material(
      color: colorScheme.surface,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: colorScheme.outlineVariant),
          ),
          child: Row(
            children: [
              // Imagen del producto
              Container(
                width: 64,
                height: 64,
                decoration: BoxDecoration(
                  color: colorScheme.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: colorScheme.outlineVariant),
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
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: colorScheme.onSurface,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      barcode,
                      style: TextStyle(
                        fontSize: 12,
                        color: colorScheme.onSurfaceVariant,
                        fontFamily: 'monospace',
                      ),
                    ),
                    if (tiempoRelativo.isNotEmpty) ...[
                      const SizedBox(height: 2),
                      Text(
                        tiempoRelativo,
                        style: TextStyle(
                          fontSize: 11,
                          color: colorScheme.onSurfaceVariant,
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
                        color: colorScheme.primary,
                      )
                    : Icon(
                        Icons.chevron_right_rounded,
                        color: colorScheme.onSurfaceVariant,
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
      color: Theme.of(context).colorScheme.onSurfaceVariant,
    );
  }
}
