import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:aptoparati/l10n/app_localizations.dart';

class CameraViewfinder extends StatefulWidget {
  final void Function(String)? onScan;

  /// Controlador externo — permite pausar/reanudar la cámara desde el padre.
  final MobileScannerController controller;

  const CameraViewfinder({
    super.key,
    this.onScan,
    required this.controller,
  });

  @override
  State<CameraViewfinder> createState() => _CameraViewfinderState();
}

class _CameraViewfinderState extends State<CameraViewfinder> {
  bool _isScanning = true;

  /// true mientras se ejecuta el ciclo stop()+start() de recuperación.
  /// Evita que múltiples errorBuilder consecutivos lancen recuperaciones paralelas.
  bool _isRecovering = false;

  void _handleBarcode(BarcodeCapture capture) {
    if (!_isScanning) return;

    for (final barcode in capture.barcodes) {
      if (barcode.rawValue != null) {
        _isScanning = false;
        widget.onScan?.call(barcode.rawValue!);
        Future.delayed(const Duration(seconds: 2), () {
          if (mounted) setState(() => _isScanning = true);
        });
        break;
      }
    }
  }

  /// Recuperación ante un doble inicio del controlador.
  ///
  /// Cuando MobileScanner y nuestro código llaman start() en paralelo (race
  /// condition por eventos de ciclo de vida de Android), el controlador guarda
  /// el error en su value y el widget muestra el errorBuilder en lugar del feed.
  /// Como la cámara SÍ está corriendo (el primer start() tuvo éxito), hacemos
  /// un ciclo stop()+start() limpio para borrar el estado de error y restaurar
  /// el feed sin mostrar ningún mensaje al usuario.
  void _recoverCamera() {
    if (_isRecovering) return;
    _isRecovering = true;
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      if (!mounted) return;
      try {
        await widget.controller.stop();
        if (mounted) await widget.controller.start();
      } catch (_) {}
      if (mounted) setState(() => _isRecovering = false);
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Stack(
      alignment: Alignment.center,
      children: [
        MobileScanner(
          controller: widget.controller,
          onDetect: _handleBarcode,
          fit: BoxFit.cover,
          errorBuilder: (context, error) {
            if (error.errorCode ==
                MobileScannerErrorCode.controllerAlreadyInitialized) {
              // La cámara ya está corriendo — recuperar sin mostrar error al usuario
              _recoverCamera();
              return const ColoredBox(color: Colors.black);
            }
            // Error real (permisos denegados, hardware no disponible, etc.)
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    Icons.videocam_off_outlined,
                    color: Colors.white54,
                    size: 52,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    error.errorDetails?.message ?? l10n.cameraUnavailable,
                    style: const TextStyle(color: Colors.white70, fontSize: 14),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            );
          },
        ),

        // Overlay semitransparente
        Container(
          decoration: BoxDecoration(
            color: Colors.black.withValues(alpha: 0.3),
          ),
        ),

        // Marco de enfoque
        Container(
          width: 280,
          height: 280,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(24),
            border: Border.all(
              color: Colors.white.withValues(alpha: 0.8),
              width: 2,
            ),
          ),
        ),

        // Instrucción
        Positioned(
          bottom: 100,
          child: Text(
            l10n.cameraScanInstruction,
            style: TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.w500,
              shadows: const [Shadow(color: Colors.black54, blurRadius: 4)],
            ),
          ),
        ),
      ],
    );
  }
}
