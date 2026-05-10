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

/// Sheet principal. StatefulWidget para gestionar el formulario de reporte
/// inline (sin showDialog), eliminando cualquier conflicto con InheritedWidgets
/// de rutas superpuestas.
class _ProductResultSheet extends StatefulWidget {
  final Product product;
  final AptitudResult resultado;

  const _ProductResultSheet({required this.product, required this.resultado});

  @override
  State<_ProductResultSheet> createState() => _ProductResultSheetState();
}

class _ProductResultSheetState extends State<_ProductResultSheet> {
  // Estado del formulario de reporte
  bool _mostrandoFormulario = false;
  bool _enviado = false;
  final _reportController = TextEditingController();
  String? _reportError;
  bool _enviando = false;

  @override
  void dispose() {
    _reportController.dispose();
    super.dispose();
  }

  Future<void> _enviarReporte() async {
    final l10n = AppLocalizations.of(context)!;
    final texto = _reportController.text.trim();

    if (texto.isEmpty) {
      setState(() => _reportError = l10n.reportReasonEmpty);
      return;
    }

    setState(() {
      _reportError = null;
      _enviando = true;
    });

    try {
      await ReportService.sendReport(
        barcode: widget.product.barcode ?? '',
        productName: widget.product.productName ?? '',
        reason: texto,
      );
      if (!mounted) return;
      setState(() {
        _mostrandoFormulario = false;
        _enviado = true;
        _enviando = false;
        _reportController.clear();
        _reportError = null;
      });
    } catch (e) {
      debugPrint('[Reporte] Error al enviar: $e');
      if (!mounted) return;
      setState(() => _enviando = false);
      scaffoldMessengerKey.currentState?.showSnackBar(
        SnackBar(content: Text(l10n.reportError)),
      );
    }
  }

  void _abrirFormulario() {
    setState(() {
      _mostrandoFormulario = true;
      _reportError = null;
      _reportController.clear();
    });
  }

  void _cancelarFormulario() {
    setState(() {
      _mostrandoFormulario = false;
      _reportError = null;
      _reportController.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final l10n = AppLocalizations.of(context)!;

    return DraggableScrollableSheet(
      initialChildSize: 0.36,
      minChildSize: 0.30,
      maxChildSize: 0.93,
      snap: true,
      snapSizes: const [0.36, 0.93],
      builder: (sheetContext, scrollController) {
        return Stack(
          children: [
            ColoredBox(color: colorScheme.surface),
            ClipRRect(
              borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
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
                          _ImagenProducto(imageUrl: widget.product.imageFrontSmallUrl),
                          const SizedBox(width: 16),
                          Expanded(child: _DatosBasicos(product: widget.product)),
                        ],
                      ),

                      const SizedBox(height: 20),

                      // Banner apto / no apto
                      _BannerAptitud(resultado: widget.resultado),

                      if (!widget.resultado.isApt) ...[
                        const SizedBox(height: 16),
                        _ListaMotivos(motivos: widget.resultado.motivos),
                      ],

                      // Advertencia de trazas (solo cuando el producto es apto pero hay trazas)
                      if (widget.resultado.isApt &&
                          widget.resultado.motivosTraza.isNotEmpty) ...[
                        const SizedBox(height: 12),
                        _AdvertenciaTrazas(
                          motivosTraza: widget.resultado.motivosTraza,
                        ),
                      ],

                      const SizedBox(height: 24),
                      const Divider(),
                      const SizedBox(height: 16),

                      // Ingredientes
                      _SeccionIngredientes(
                        product: widget.product,
                        tagsIncompatibles: widget.resultado.tagsIncompatibles,
                        tagsTraza: widget.resultado.tagsTraza,
                      ),

                      const SizedBox(height: 24),
                      const Divider(),
                      const SizedBox(height: 16),

                      // Tabla nutricional
                      _TablaNutricional(nutriments: widget.product.nutriments),

                      const SizedBox(height: 24),
                      const Divider(),
                      const SizedBox(height: 12),

                      // Sección de reporte — inline, sin showDialog
                      if (_enviado)
                        Center(
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(Icons.check_circle_outline,
                                  color: Color(0xFF4CAF50), size: 18),
                              const SizedBox(width: 8),
                              Text(
                                l10n.reportSuccess,
                                style: const TextStyle(
                                  fontSize: 13,
                                  color: Color(0xFF388E3C),
                                ),
                              ),
                            ],
                          ),
                        )
                      else if (!_mostrandoFormulario)
                        Center(
                          child: TextButton.icon(
                            onPressed: _abrirFormulario,
                            icon: Icon(
                              Icons.flag_outlined,
                              size: 16,
                              color: colorScheme.onSurfaceVariant,
                            ),
                            label: Text(
                              l10n.reportButton,
                              style: TextStyle(
                                fontSize: 13,
                                color: colorScheme.onSurfaceVariant,
                              ),
                            ),
                          ),
                        )
                      else
                        _FormularioReporte(
                          controller: _reportController,
                          errorTexto: _reportError,
                          enviando: _enviando,
                          onChanged: (v) {
                            if (_reportError != null) {
                              setState(() => _reportError = null);
                            }
                          },
                          onCancelar: _cancelarFormulario,
                          onEnviar: _enviarReporte,
                        ),
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
// Formulario de reporte inline
// ---------------------------------------------------------------------------

/// Formulario de reporte renderizado directamente en el bottom sheet.
/// No usa showDialog ni ningún overlay, eliminando conflictos con el
/// ciclo de vida de InheritedWidgets en rutas superpuestas.
class _FormularioReporte extends StatelessWidget {
  final TextEditingController controller;
  final String? errorTexto;
  final bool enviando;
  final ValueChanged<String> onChanged;
  final VoidCallback onCancelar;
  final VoidCallback onEnviar;

  const _FormularioReporte({
    required this.controller,
    required this.errorTexto,
    required this.enviando,
    required this.onChanged,
    required this.onCancelar,
    required this.onEnviar,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final colorScheme = Theme.of(context).colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          l10n.reportDialogTitle,
          style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 6),
        Text(
          l10n.reportDialogDescription,
          style: TextStyle(fontSize: 13, color: colorScheme.onSurfaceVariant),
        ),
        const SizedBox(height: 14),
        TextField(
          controller: controller,
          maxLines: 4,
          maxLength: 300,
          textCapitalization: TextCapitalization.sentences,
          enabled: !enviando,
          decoration: InputDecoration(
            labelText: l10n.reportReasonLabel,
            hintText: l10n.reportReasonHint,
            errorText: errorTexto,
            alignLabelWithHint: true,
            border: const OutlineInputBorder(),
          ),
          onChanged: onChanged,
        ),
        const SizedBox(height: 12),
        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            TextButton(
              onPressed: enviando ? null : onCancelar,
              child: Text(l10n.cancelButton),
            ),
            const SizedBox(width: 8),
            FilledButton(
              onPressed: enviando ? null : onEnviar,
              child: enviando
                  ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : Text(l10n.sendButton),
            ),
          ],
        ),
      ],
    );
  }
}

// ---------------------------------------------------------------------------
// Sección de ingredientes
// ---------------------------------------------------------------------------

class _SeccionIngredientes extends StatelessWidget {
  final Product product;
  final Set<String> tagsIncompatibles;

  /// Tags de alérgenos presentes solo como trazas (advertencia, no incompatibilidad).
  final Set<String> tagsTraza;

  const _SeccionIngredientes({
    required this.product,
    required this.tagsIncompatibles,
    required this.tagsTraza,
  });

  /// Devuelve true si el ingrediente coincide con un tag de incompatibilidad directa.
  bool _esIncompatible(String texto) {
    final lower = texto.toLowerCase();
    for (final tag in tagsIncompatibles) {
      final keywords = _keywordsPorTag[tag] ?? [];
      if (keywords.any((k) => lower.contains(k))) return true;
    }
    return false;
  }

  /// Devuelve true si el ingrediente coincide con un tag de traza (y no es incompatible directo).
  bool _esSoloTraza(String texto) {
    final lower = texto.toLowerCase();
    for (final tag in tagsTraza) {
      final keywords = _keywordsPorTag[tag] ?? [];
      if (keywords.any((k) => lower.contains(k))) return true;
    }
    return false;
  }

  /// Construye el texto plano con palabras resaltadas por prioridad:
  /// rojo = incompatible directo, ámbar = solo traza.
  TextSpan _buildTextoResaltado(String texto, Color onSurface) {
    final hayIncompatibles = tagsIncompatibles.isNotEmpty;
    final hayTrazas = tagsTraza.isNotEmpty;

    if (!hayIncompatibles && !hayTrazas) {
      return TextSpan(text: texto, style: TextStyle(fontSize: 13, color: onSurface));
    }

    // Construir mapa keyword → estilo con prioridad: incompatible > traza
    final Map<String, TextStyle> keywordEstilo = {};

    for (final tag in tagsTraza) {
      for (final kw in _keywordsPorTag[tag] ?? []) {
        if (texto.toLowerCase().contains(kw)) {
          keywordEstilo[kw] = const TextStyle(
            fontSize: 13,
            color: Color(0xFFF57C00),
            fontWeight: FontWeight.bold,
            backgroundColor: Color(0x1AFFB300),
          );
        }
      }
    }
    // Los incompatibles directos sobreescriben en caso de colisión
    for (final tag in tagsIncompatibles) {
      for (final kw in _keywordsPorTag[tag] ?? []) {
        if (texto.toLowerCase().contains(kw)) {
          keywordEstilo[kw] = const TextStyle(
            fontSize: 13,
            color: Color(0xFFC62828),
            fontWeight: FontWeight.bold,
            backgroundColor: Color(0x1AE53935),
          );
        }
      }
    }

    if (keywordEstilo.isEmpty) {
      return TextSpan(text: texto, style: TextStyle(fontSize: 13, color: onSurface));
    }

    final pattern = RegExp(
      keywordEstilo.keys.map(RegExp.escape).join('|'),
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
      final kwLower = match.group(0)!.toLowerCase();
      spans.add(TextSpan(
        text: match.group(0),
        style: keywordEstilo[kwLower] ??
            TextStyle(fontSize: 13, color: onSurface),
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
        else if (ingredientes != null && ingredientes.isNotEmpty)
          Wrap(
            spacing: 6,
            runSpacing: 6,
            children: ingredientes.map((ing) {
              final texto = ing.text ?? '';
              final incompatible = _esIncompatible(texto);
              final soloTraza = !incompatible && _esSoloTraza(texto);
              final esAlergenoGeneral = ing.bold == true;

              Color bg;
              Color fg;
              Color borderColor;

              if (incompatible) {
                // Rojo: incompatibilidad directa con el perfil del usuario
                bg = const Color(0x1AE53935);
                fg = const Color(0xFFC62828);
                borderColor = const Color(0x4DE53935);
              } else if (soloTraza) {
                // Ámbar: solo trazas, el producto sigue siendo apto
                bg = const Color(0x1AFFB300);
                fg = const Color(0xFFF57C00);
                borderColor = const Color(0x4DFFB300);
              } else if (esAlergenoGeneral) {
                // Naranja: alérgeno marcado por OFF que no afecta al usuario
                bg = const Color(0x1AFF8F00);
                fg = const Color(0xFFE65100);
                borderColor = const Color(0x4DFF8F00);
              } else {
                bg = colorScheme.surfaceContainerHighest;
                fg = colorScheme.onSurface;
                borderColor = colorScheme.outlineVariant;
              }

              return Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: bg,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: borderColor),
                ),
                child: Text(
                  texto,
                  style: TextStyle(
                    fontSize: 12,
                    color: fg,
                    fontWeight: (incompatible || soloTraza || esAlergenoGeneral)
                        ? FontWeight.w600
                        : FontWeight.normal,
                  ),
                ),
              );
            }).toList(),
          )
        else if (textoPlano != null)
          RichText(
            text: _buildTextoResaltado(textoPlano, colorScheme.onSurface),
          ),

        // Leyenda de colores (solo si hay algo que explicar)
        if (!sinDatos &&
            (tagsIncompatibles.isNotEmpty || tagsTraza.isNotEmpty)) ...[
          const SizedBox(height: 10),
          Wrap(
            spacing: 12,
            runSpacing: 6,
            children: [
              if (tagsIncompatibles.isNotEmpty)
                _ItemLeyenda(
                  color: const Color(0x1AE53935),
                  borderColor: const Color(0x4DE53935),
                  textColor: const Color(0xFFC62828),
                  label: l10n.productIncompatibleLabel,
                ),
              if (tagsTraza.isNotEmpty)
                _ItemLeyenda(
                  color: const Color(0x1AFFB300),
                  borderColor: const Color(0x4DFFB300),
                  textColor: const Color(0xFFF57C00),
                  label: l10n.productTracesIngredientLabel,
                ),
              _ItemLeyenda(
                color: const Color(0x1AFF8F00),
                borderColor: const Color(0x4DFF8F00),
                textColor: const Color(0xFFE65100),
                label: l10n.productAllergenNotAffecting,
              ),
            ],
          ),
        ],
      ],
    );
  }
}

/// Un ítem de la leyenda de colores de ingredientes.
class _ItemLeyenda extends StatelessWidget {
  final Color color;
  final Color borderColor;
  final Color textColor;
  final String label;

  const _ItemLeyenda({
    required this.color,
    required this.borderColor,
    required this.textColor,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(2),
            border: Border.all(color: borderColor),
          ),
        ),
        const SizedBox(width: 6),
        Text(label, style: TextStyle(fontSize: 11, color: textColor)),
      ],
    );
  }
}

// ---------------------------------------------------------------------------
// Advertencia de trazas
// ---------------------------------------------------------------------------

/// Tarjeta ámbar que aparece cuando el producto es apto pero contiene trazas
/// de alérgenos del usuario. No bloquea el consumo; informa para que el
/// usuario decida según la gravedad de su caso.
class _AdvertenciaTrazas extends StatelessWidget {
  final List<String> motivosTraza;

  const _AdvertenciaTrazas({required this.motivosTraza});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 14),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF8E1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFFFB300), width: 1.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Cabecera con icono y título
          Row(
            children: [
              const Icon(
                Icons.warning_amber_rounded,
                color: Color(0xFFF57C00),
                size: 20,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  l10n.productTracesTitle,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFFE65100),
                  ),
                ),
              ),
            ],
          ),

          // Lista de alérgenos detectados como trazas
          const SizedBox(height: 6),
          ...motivosTraza.map(
            (m) => Padding(
              padding: const EdgeInsets.only(left: 28, top: 3),
              child: Row(
                children: [
                  const Icon(Icons.circle, size: 5, color: Color(0xFFF57C00)),
                  const SizedBox(width: 6),
                  Text(
                    m,
                    style: const TextStyle(
                      fontSize: 13,
                      color: Color(0xFF7F4000),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Explicación breve
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.only(left: 28),
            child: Text(
              l10n.productTracesExplanation,
              style: const TextStyle(
                fontSize: 11,
                color: Color(0xFF9E6B00),
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
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
        Text(l10n.productNutritionTitle,
            style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
        const SizedBox(height: 4),
        Text(l10n.productNutritionPer100,
            style: TextStyle(fontSize: 11, color: colorScheme.onSurfaceVariant)),
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
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      fila.nombre,
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: fila.negrita ? FontWeight.w600 : FontWeight.normal,
                        color: colorScheme.onSurface,
                      ),
                    ),
                    Text(
                      fila.valor,
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: fila.negrita ? FontWeight.w600 : FontWeight.normal,
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
          Text(marca, style: TextStyle(fontSize: 13, color: colorScheme.onSurfaceVariant)),
        ],
        if (cantidad.isNotEmpty) ...[
          const SizedBox(height: 2),
          Text(cantidad, style: TextStyle(fontSize: 12, color: colorScheme.onSurfaceVariant)),
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
              color: isApt ? const Color(0xFF388E3C) : const Color(0xFFC62828),
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
