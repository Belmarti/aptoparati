import 'package:flutter/material.dart';

class CameraViewfinder extends StatelessWidget {
  final VoidCallback? onScan;

  const CameraViewfinder({super.key, this.onScan});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: double.infinity,
      decoration: BoxDecoration(
        color: Colors.grey[900], // Placeholder for camera feed
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(32),
          bottomRight: Radius.circular(32),
        ),
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Placeholder Text
          const Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.camera_alt_outlined, color: Colors.white54, size: 48),
              SizedBox(height: 16),
              Text(
                'Escanea un código de barras',
                style: TextStyle(color: Colors.white54, fontSize: 16),
              ),
            ],
          ),

          // Focus Frame (Decorative)
          Container(
            width: 280,
            height: 280,
            decoration: BoxDecoration(
              border: Border.all(color: Colors.white30, width: 2),
              borderRadius: BorderRadius.circular(24),
            ),
          ),

          // Simulated Scanning Line (Could be animated)
          Positioned(
            top: 200,
            child: Container(
              width: 260,
              height: 2,
              decoration: BoxDecoration(
                color: Colors.greenAccent.withOpacity(0.8),
                boxShadow: [
                  BoxShadow(
                    color: Colors.greenAccent.withOpacity(0.5),
                    blurRadius: 10,
                    spreadRadius: 2,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
