// lib/pages/barcode_scanner_page.dart
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

class BarcodeScannerPage extends StatefulWidget {
  final String title;

  const BarcodeScannerPage({
    super.key,
    this.title = 'Escanear código',
  });

  @override
  State<BarcodeScannerPage> createState() => _BarcodeScannerPageState();
}

class _BarcodeScannerPageState extends State<BarcodeScannerPage> {
  bool _scanned = false;
  late final bool _soportaScanner;
  MobileScannerController? _controller;

  @override
  void initState() {
    super.initState();

    // Solo soportamos Android / iOS (y opcionalmente Web).
    final isMobile = (!kIsWeb && (Platform.isAndroid || Platform.isIOS));
    _soportaScanner = isMobile; // si quieres, aquí puedes incluir web

    if (_soportaScanner) {
      _controller =
          MobileScannerController(detectionSpeed: DetectionSpeed.noDuplicates);
    }
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  void _onDetect(BarcodeCapture capture) {
    if (_scanned) return;
    if (capture.barcodes.isEmpty) return;

    final barcode = capture.barcodes.first;
    final value = barcode.rawValue;

    if (value == null || value.isEmpty) return;

    setState(() {
      _scanned = true;
    });

    Navigator.of(context).pop(value);
  }

  @override
  Widget build(BuildContext context) {
    if (!_soportaScanner) {
      // Vista para Windows / plataformas no soportadas
      return Scaffold(
        appBar: AppBar(
          title: Text(widget.title),
        ),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.desktop_windows,
                  size: 72,
                ),
                const SizedBox(height: 16),
                const Text(
                  'El escaneo con cámara solo está disponible en Android/iOS.\n\n'
                      'Ejecuta la app en un emulador o dispositivo móvil para usar esta función.',
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),
                ElevatedButton.icon(
                  onPressed: () => Navigator.of(context).pop(),
                  icon: const Icon(Icons.arrow_back),
                  label: const Text('Regresar'),
                ),
              ],
            ),
          ),
        ),
      );
    }

    // Vista normal con cámara (Android/iOS)
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
        actions: [
          IconButton(
            icon: const Icon(Icons.flash_on),
            onPressed: () => _controller?.toggleTorch(),
          ),
          IconButton(
            icon: const Icon(Icons.cameraswitch),
            onPressed: () => _controller?.switchCamera(),
          ),
        ],
      ),
      body: Stack(
        children: [
          MobileScanner(
            controller: _controller!,
            onDetect: _onDetect,
          ),
          Center(
            child: Container(
              width: 260,
              height: 260,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: Colors.white.withValues(alpha: 0.8),
                  width: 3,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
