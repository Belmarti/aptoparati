import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

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

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.center,
      children: [
        MobileScanner(
          controller: widget.controller,
          onDetect: _handleBarcode,
          fit: BoxFit.cover,
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
            'Escanea el código de barras',
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
