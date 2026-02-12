import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

class CameraViewfinder extends StatefulWidget {
  final void Function(String)? onScan;

  const CameraViewfinder({super.key, this.onScan});

  @override
  State<CameraViewfinder> createState() => _CameraViewfinderState();
}

class _CameraViewfinderState extends State<CameraViewfinder> {
  final MobileScannerController controller = MobileScannerController();
  bool _isScanning = true;

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  void _handleBarcode(BarcodeCapture capture) {
    if (!_isScanning) return;

    final List<Barcode> barcodes = capture.barcodes;
    for (final barcode in barcodes) {
      if (barcode.rawValue != null) {
        _isScanning = false; // Pause scanning
        widget.onScan?.call(barcode.rawValue!);

        // Resume scanning after a delay or when handled
        // For now, let's just create a small delay to avoid multiple triggers
        // if the user stays on the code.
        Future.delayed(const Duration(seconds: 2), () {
          if (mounted) {
            setState(() => _isScanning = true);
          }
        });
        break; // Process only the first barcode
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: const BorderRadius.only(
        bottomLeft: Radius.circular(32),
        bottomRight: Radius.circular(32),
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          MobileScanner(
            controller: controller,
            onDetect: _handleBarcode,
            fit: BoxFit.cover,
          ),

          // Overlay for scanner
          Container(
            decoration: BoxDecoration(color: Colors.black.withOpacity(0.3)),
          ),

          // Focus Frame
          Container(
            width: 280,
            height: 280,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(24),
              border: Border.all(
                color: Colors.white.withOpacity(0.8),
                width: 2,
              ),
            ),
          ),

          // Directions
          Positioned(
            bottom: 100,
            child: Text(
              'Escanea el código de barras',
              style: TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.w500,
                shadows: [Shadow(color: Colors.black54, blurRadius: 4)],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
