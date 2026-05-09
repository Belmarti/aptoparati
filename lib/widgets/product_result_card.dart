import 'package:flutter/material.dart';
import 'package:openfoodfacts/openfoodfacts.dart';
import '../services/aptitud_service.dart';
import '../services/report_service.dart';
import '../app_globals.dart';
import 'package:aptoparati/l10n/app_localizations.dart';

/// Palabras clave por tag OFF para resaltar ingredientes en el texto.
const Map<String, List<String>> _keywordsPorTag = {
  'en:gluten': ['gluten', 'trigo', 'wheat', 'cebada', 'barley', 'centeno', 'rye', 'espelta', 'spelt', 'kamut'],
  'en:milk': ['leche', 'milk', 'lactosa', 'lactose', 'suero', 'whey', 'mantequilla', 'butter', 'nata', 'cream', 'queso', 'cheese', 'caseína', 'casein'],
  'en:eggs': ['huevo', 'huevos', 'egg', 'eggs', 'yema', 'yolk', 'clara'],
  'en:nuts': ['nuez', 'nueces', 'nut', 'nuts', 'almendra', 'almond', 'avellana', 'hazelnut', 'anacardo', 'cashew', 'pistacho', 'pistachio', 'macadamia', 'pacana', 'pecan'],
  'en:soybeans': ['soja', 'soy', 'soya', 'tofu', 'edamame'],
  'en:fish': ['pescado', 'fish', 'atún', 'tuna', 'salmón', 'salmon', 'bacalao', 'cod', 'anchoa', 'anchovy', 'merluza'],
  'en:crustaceans': ['gamba', 'shrimp', 'langosta', 'lobster', 'cangrejo', 'crab', 'langostino', 'prawn', 'centollo'],
  'en:molluscs': ['molusco', 'mollusc', 'calamar', 'squid', 'mejillón', 'mussel', 'ostra', 'oyster', 'almeja', 'clam', 'pulpo', 'octopus'],
};

/// Abre un bottom sheet expandible con la información del producto y su aptitud.
/// Muestra la card de resultado y devuelve un [Future] que resuelve
/// cuando el usuario cierra el sheet (útil para pausar el escaneo).
Future<void> showProductResultCard(
  BuildContext context, {
  required Product product,
  required Map<String, dynamic> healthProfile,
}) async {
  final l10n = AppLocalizations.of(context)!;
  final resultado = AptitudService.evaluar(product, healthProfile, l10n);

  await showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (_) => _ProductResultSheet(product: product, resultado: resultado),
  );
}

// ---------------------------------------------------------------------------

class _ProductResultSheet extends StatelessWidget {
  final Product product;
  final AptitudResult resultado;

  const _ProductResultSheet({required this.product, required this.resultado});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return DraggableScrollableSheet(
      initialChildSize: 0.36,
      minChildSize: 0.30,
      maxChildSize: 0.93,
      snap: true,
      snapSizes: const [0.36, 0.93],
      builder: (context, scrollController) {
        // Stack de dos capas para eliminar el sangrado de cámara en esquinas:
        // - ColoredBox: rellena el rectángulo completo (esquinas incluidas)
        // - ClipRRect: recorta el contenido a la forma redondeada
        return Stack(
          children: [
            ColoredBox(color: colorScheme.surface),
            ClipRRect(
              borderRadius:
                  const BorderRadius.vertical(top: Radius.circular(24)),
              child: SingleChildScrollView(
                controller: scrollController,
                child: Container(
                  color: colorScheme.surface,
                  padding: const EdgeInsets.fromLTRB(24, 16, 24, 32),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Indicador de arrastre
                  Center(
                    child: Container(
                      width: 40,
                      height: 4,
                      margin: const EdgeInsets.only(bottom: 20),
                      decoration: BoxDecoration(
                        color: colorScheme.outlineVariant,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),

                  // Imagen + datos básicos
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _ImagenProducto(imageUrl: product.imageFrontSmallUrl),
                      const SizedBox(width: 16),
                      Expanded(child: _DatosBasicos(product: product)),
                    ],
                  ),

                  const SizedBox(height: 20),

                  // Banner apto / no apto
                  _BannerAptitud(resultado: resultado),

                  if (!resultado.isApt) ...[
                    const SizedBox(height: 16),
                    _ListaMotivos(motivos: resultado.motivos),
                  ],

                  // ── Contenido expandido ──────────────────────────────────

                  const SizedBox(height: 24),
                  const Divider(),
                  const SizedBox(height: 16),

                  // Ingredientes
                  _SeccionIngredientes(
                    product: product,
                    tagsIncompatibles: resultado.tagsIncompatibles,
                  ),

                  const SizedBox(height: 24),
                  const Divider(),
                  const SizedBox(height: 16),

                  // Tabla nutricional
                  _TablaNutricional(nutriments: product.nutriments),

                  const SizedBox(height: 24),
                  const Divider(),
                  const SizedBox(height: 12),

                  // Botón de reporte de error
                  _BotonReporte(barcode: product.barcode ?? ''),
                ],
              ),
            ),
          ),
        ),
          ],
        );
      },
    );
  }
}

// ---------------------------------------------------------------------------
// Sección de ingredientes
// ---------------------------------------------------------------------------

class _SeccionIngredientes extends StatelessWidget {
  final Product product;
  final Set<String> tagsIncompatibles;

  const _SeccionIngredientes({
    required this.product,
    required this.tagsIncompatibles,
  });

  /// Comprueba si un texto de ingrediente contiene alguna keyword incompatible.
  bool _esIncompatible(String texto) {
    final lower = texto.toLowerCase();
    for (final tag in tagsIncompatibles) {
      final keywords = _keywordsPorTag[tag] ?? [];
      if (keywords.any((k) => lower.contains(k))) return true;
    }
    return false;
  }

  /// Construye un [TextSpan] con las keywords incompatibles resaltadas en rojo.
  TextSpan _buildTextoResaltado(String texto, Color onSurface) {
    if (tagsIncompatibles.isEmpty) {
      return TextSpan(
        text: texto,
        style: TextStyle(fontSize: 13, color: onSurface),
      );
    }

    // Recopila todos los keywords incompatibles presentes en el texto
    final List<String> keywords = [];
    for (final tag in tagsIncompatibles) {
      for (final kw in _keywordsPorTag[tag] ?? []) {
        if (texto.toLowerCase().contains(kw)) keywords.add(kw);
      }
    }

    if (keywords.isEmpty) {
      return TextSpan(
        text: texto,
        style: TextStyle(fontSize: 13, color: onSurface),
      );
    }

    // Patrón que une todas las keywords con alternancia
    final pattern = RegExp(
      keywords.map(RegExp.escape).join('|'),
      caseSensitive: false,
    );

    final spans = <TextSpan>[];
    int cursor = 0;
    for (final match in pattern.allMatches(texto)) {
      if (match.start > cursor) {
        spans.add(TextSpan(
          text: texto.substring(cursor, match.start),
          style: TextStyle(fontSize: 13, color: onSurface),
        ));
      }
      spans.add(TextSpan(
        text: match.group(0),
        style: const TextStyle(
          fontSize: 13,
          color: Color(0xFFC62828),
          fontWeight: FontWeight.bold,
          backgroundColor: Color(0x1AE53935),
        ),
      ));
      cursor = match.end;
    }
    if (cursor < texto.length) {
      spans.add(TextSpan(
        text: texto.substring(cursor),
        style: TextStyle(fontSize: 13, color: onSurface),
      ));
    }
    return TextSpan(children: spans);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final colorScheme = Theme.of(context).colorScheme;
    final ingredientes = product.ingredients;
    final textoPlano = product.ingredientsText;

    final sinDatos = (ingredientes == null || ingredientes.isEmpty) &&
        (textoPlano == null || textoPlano.trim().isEmpty);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          l10n.productIngredients,
          style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 10),

        if (sinDatos)
          Text(
            l10n.noDataAvailable,
            style: TextStyle(fontSize: 13, color: colorScheme.onSurfaceVariant),
          )

        // Lista estructurada (cada Ingredient como fila)
        else if (ingredientes != null && ingredientes.isNotEmpty)
          Wrap(
            spacing: 6,
            runSpacing: 6,
            children: ingredientes.map((ing) {
              final texto = ing.text ?? '';
              final incompatible = _esIncompatible(texto);
              final esAlergenoGeneral = ing.bold == true;

              Color bg;
              Color fg;
              if (incompatible) {
                bg = const Color(0x1AE53935);
                fg = const Color(0xFFC62828);
              } else if (esAlergenoGeneral) {
                bg = const Color(0x1AFF8F00);
                fg = const Color(0xFFE65100);
              } else {
                bg = colorScheme.surfaceContainerHighest;
                fg = colorScheme.onSurface;
              }

              return Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: bg,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: incompatible
                        ? const Color(0x4DE53935)
                        : esAlergenoGeneral
                            ? const Color(0x4DFF8F00)
                            : colorScheme.outlineVariant,
                  ),
                ),
                child: Text(
                  texto,
                  style: TextStyle(
                    fontSize: 12,
                    color: fg,
                    fontWeight: (incompatible || esAlergenoGeneral)
                        ? FontWeight.w600
                        : FontWeight.normal,
                  ),
                ),
              );
            }).toList(),
          )

        // Fallback: texto plano con keywords resaltadas
        else if (textoPlano != null)
          RichText(
            text: _buildTextoResaltado(textoPlano, colorScheme.onSurface),
          ),

        if (!sinDatos && tagsIncompatibles.isNotEmpty) ...[
          const SizedBox(height: 10),
          Row(
            children: [
              Container(width: 12, height: 12,
                decoration: BoxDecoration(
                  color: const Color(0x1AE53935),
                  borderRadius: BorderRadius.circular(2),
                  border: Border.all(color: const Color(0x4DE53935)),
                ),
              ),
              const SizedBox(width: 6),
              Text(l10n.productIncompatibleLabel, style: const TextStyle(fontSize: 11, color: Color(0xFFC62828))),
              const SizedBox(width: 12),
              Container(
                width: 12, height: 12,
                decoration: BoxDecoration(
                  color: const Color(0x1AFF8F00),
                  borderRadius: BorderRadius.circular(2),
                  border: Border.all(color: const Color(0x4DFF8F00)),
                ),
              ),
              const SizedBox(width: 6),
              Text(l10n.productAllergenNotAffecting, style: const TextStyle(fontSize: 11, color: Color(0xFFE65100))),
            ],
          ),
        ],
      ],
    );
  }
}

// ---------------------------------------------------------------------------
// Tabla nutricional
// ---------------------------------------------------------------------------

class _TablaNutricional extends StatelessWidget {
  final Nutriments? nutriments;

  const _TablaNutricional({this.nutriments});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final colorScheme = Theme.of(context).colorScheme;

    if (nutriments == null) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(l10n.productNutritionTitle,
              style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
          const SizedBox(height: 10),
          Text(l10n.noDataAvailable,
              style: TextStyle(fontSize: 13, color: colorScheme.onSurfaceVariant)),
        ],
      );
    }

    final filas = <_FilaNutriente>[
      _FilaNutriente(l10n.productNutritionEnergy, _formatEnergy(), negrita: true),
      _FilaNutriente(l10n.productNutritionFat, _fmt(Nutrient.fat), negrita: true),
      _FilaNutriente(l10n.productNutritionSaturatedFat, _fmt(Nutrient.saturatedFat)),
      _FilaNutriente(l10n.productNutritionCarbs, _fmt(Nutrient.carbohydrates), negrita: true),
      _FilaNutriente(l10n.productNutritionSugars, _fmt(Nutrient.sugars)),
      _FilaNutriente(l10n.productNutritionFiber, _fmt(Nutrient.fiber)),
      _FilaNutriente(l10n.productNutritionProtein, _fmt(Nutrient.proteins), negrita: true),
      _FilaNutriente(l10n.productNutritionSalt, _fmt(Nutrient.salt)),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          l10n.productNutritionTitle,
          style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 4),
        Text(
          l10n.productNutritionPer100,
          style: TextStyle(fontSize: 11, color: colorScheme.onSurfaceVariant),
        ),
        const SizedBox(height: 10),
        Container(
          decoration: BoxDecoration(
            border: Border.all(color: colorScheme.outlineVariant),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Column(
            children: filas.asMap().entries.map((entry) {
              final i = entry.key;
              final fila = entry.value;
              return Container(
                decoration: BoxDecoration(
                  color: i.isEven
                      ? colorScheme.surfaceContainerHighest
                      : colorScheme.surface,
                  borderRadius: BorderRadius.vertical(
                    top: i == 0 ? const Radius.circular(10) : Radius.zero,
                    bottom: i == filas.length - 1
                        ? const Radius.circular(10)
                        : Radius.zero,
                  ),
                ),
                padding:
                    const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      fila.nombre,
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: fila.negrita
                            ? FontWeight.w600
                            : FontWeight.normal,
                        color: colorScheme.onSurface,
                      ),
                    ),
                    Text(
                      fila.valor,
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: fila.negrita
                            ? FontWeight.w600
                            : FontWeight.normal,
                        color: fila.valor == '—'
                            ? colorScheme.onSurfaceVariant
                            : colorScheme.onSurface,
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }

  String _fmt(Nutrient nutrient) {
    final v = nutriments!.getValue(nutrient, PerSize.oneHundredGrams);
    if (v == null) return '—';
    return '${v.toStringAsFixed(1)} g';
  }

  String _formatEnergy() {
    final kcal = nutriments!.getValue(Nutrient.energyKCal, PerSize.oneHundredGrams);
    final kj = nutriments!.getValue(Nutrient.energyKJ, PerSize.oneHundredGrams);
    if (kcal == null && kj == null) return '—';
    final parts = <String>[];
    if (kj != null) parts.add('${kj.toStringAsFixed(0)} kJ');
    if (kcal != null) parts.add('${kcal.toStringAsFixed(0)} kcal');
    return parts.join(' / ');
  }
}

class _FilaNutriente {
  final String nombre;
  final String valor;
  final bool negrita;
  const _FilaNutriente(this.nombre, this.valor, {this.negrita = false});
}

// ---------------------------------------------------------------------------
// Botón de reporte de error
// ---------------------------------------------------------------------------

/// Botón de texto que abre un diálogo para que el usuario reporte un error
/// en el resultado de aptitud del producto.
///
/// El diálogo es completamente síncrono: devuelve el motivo introducido como
/// String?. El envío a Firestore y el SnackBar ocurren DESPUÉS de que el
/// diálogo esté completamente cerrado. El SnackBar se muestra a través de
/// [scaffoldMessengerKey] (GlobalKey) para no llamar nunca a
/// ScaffoldMessenger.of(context) desde código asíncrono.
class _BotonReporte extends StatelessWidget {
  final String barcode;
  const _BotonReporte({required this.barcode});

  Future<void> _abrirDialogo(BuildContext context, AppLocalizations l10n) async {
    final controller = TextEditingController();

    // El diálogo solo recoge el motivo. El botón Enviar es síncrono:
    // devuelve el texto con Navigator.pop(razon) sin hacer ningún await.
    final String? razon = await showDialog<String>(
      context: context,
      builder: (dialogContext) {
        String? errorTexto;
        return StatefulBuilder(
          builder: (ctx, setDialogState) {
            final colorScheme = Theme.of(ctx).colorScheme;
            return AlertDialog(
              title: Text(l10n.reportDialogTitle),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    l10n.reportDialogDescription,
                    style: TextStyle(fontSize: 13, color: colorScheme.onSurfaceVariant),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: controller,
                    maxLines: 4,
                    maxLength: 300,
                    textCapitalization: TextCapitalization.sentences,
                    decoration: InputDecoration(
                      labelText: l10n.reportReasonLabel,
                      hintText: l10n.reportReasonHint,
                      errorText: errorTexto,
                      alignLabelWithHint: true,
                    ),
                    onChanged: (_) {
                      if (errorTexto != null) setDialogState(() => errorTexto = null);
                    },
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(ctx).pop(null),
                  child: Text(l10n.cancelButton),
                ),
                FilledButton(
                  // Handler síncrono: no hay await, no hay operaciones async aquí.
                  onPressed: () {
                    final texto = controller.text.trim();
                    if (texto.isEmpty) {
                      setDialogState(() => errorTexto = l10n.reportReasonEmpty);
                      return;
                    }
                    Navigator.of(ctx).pop(texto);
                  },
                  child: Text(l10n.sendButton),
                ),
              ],
            );
          },
        );
      },
    );

    controller.dispose();

    // El diálogo ya está completamente cerrado y eliminado del árbol.
    if (razon == null || razon.isEmpty) return;

    // Usamos scaffoldMessengerKey.currentState en lugar de
    // ScaffoldMessenger.of(context) para no registrar ninguna dependencia
    // sobre InheritedWidgets desde código asíncrono.
    try {
      await ReportService.sendReport(barcode: barcode, reason: razon);
      scaffoldMessengerKey.currentState?.showSnackBar(
        SnackBar(content: Text(l10n.reportSuccess)),
      );
    } catch (_) {
      scaffoldMessengerKey.currentState?.showSnackBar(
        SnackBar(content: Text(l10n.reportError)),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final colorScheme = Theme.of(context).colorScheme;

    return Center(
      child: TextButton.icon(
        onPressed: () => _abrirDialogo(context, l10n),
        icon: Icon(Icons.flag_outlined, size: 16, color: colorScheme.onSurfaceVariant),
        label: Text(
          l10n.reportButton,
          style: TextStyle(fontSize: 13, color: colorScheme.onSurfaceVariant),
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Widgets auxiliares compartidos
// ---------------------------------------------------------------------------

class _ImagenProducto extends StatelessWidget {
  final String? imageUrl;
  const _ImagenProducto({this.imageUrl});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      width: 80,
      height: 80,
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: colorScheme.outlineVariant),
      ),
      clipBehavior: Clip.hardEdge,
      child: imageUrl != null
          ? Image.network(
              imageUrl!,
              fit: BoxFit.contain,
              errorBuilder: (context, error, stack) => const _PlaceholderImagen(),
            )
          : const _PlaceholderImagen(),
    );
  }
}

class _PlaceholderImagen extends StatelessWidget {
  const _PlaceholderImagen();

  @override
  Widget build(BuildContext context) {
    return Icon(Icons.image_not_supported_outlined,
        size: 36, color: Theme.of(context).colorScheme.onSurfaceVariant);
  }
}

class _DatosBasicos extends StatelessWidget {
  final Product product;
  const _DatosBasicos({required this.product});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final colorScheme = Theme.of(context).colorScheme;
    final nombre = product.productName ?? l10n.productNameUnknown;
    final marca = product.brands ?? '';
    final cantidad = product.quantity ?? '';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          nombre,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
        if (marca.isNotEmpty) ...[
          const SizedBox(height: 4),
          Text(marca,
              style: TextStyle(fontSize: 13, color: colorScheme.onSurfaceVariant)),
        ],
        if (cantidad.isNotEmpty) ...[
          const SizedBox(height: 2),
          Text(cantidad,
              style: TextStyle(fontSize: 12, color: colorScheme.onSurfaceVariant)),
        ],
      ],
    );
  }
}

class _BannerAptitud extends StatelessWidget {
  final AptitudResult resultado;
  const _BannerAptitud({required this.resultado});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final isApt = resultado.isApt;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
      decoration: BoxDecoration(
        color: isApt
            ? const Color(0xFF4CAF50).withValues(alpha: 0.1)
            : const Color(0xFFE53935).withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isApt ? const Color(0xFF4CAF50) : const Color(0xFFE53935),
          width: 1.5,
        ),
      ),
      child: Row(
        children: [
          Icon(
            isApt ? Icons.check_circle : Icons.cancel,
            color: isApt ? const Color(0xFF4CAF50) : const Color(0xFFE53935),
            size: 28,
          ),
          const SizedBox(width: 12),
          Text(
            isApt ? l10n.productApt : l10n.productNotApt,
            style: TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.bold,
              color:
                  isApt ? const Color(0xFF388E3C) : const Color(0xFFC62828),
            ),
          ),
        ],
      ),
    );
  }
}

class _ListaMotivos extends StatelessWidget {
  final List<String> motivos;
  const _ListaMotivos({required this.motivos});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final colorScheme = Theme.of(context).colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          l10n.productIncompatibleProfile,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: colorScheme.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: 8),
        ...motivos.map(
          (m) => Padding(
            padding: const EdgeInsets.only(bottom: 6),
            child: Row(
              children: [
                const Icon(Icons.warning_amber_rounded,
                    size: 16, color: Color(0xFFE53935)),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(m,
                    style: const TextStyle(fontSize: 14),
                    softWrap: true,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
