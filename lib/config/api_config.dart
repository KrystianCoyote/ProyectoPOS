// lib/config/api_config.dart
import 'dart:io';
import 'package:flutter/foundation.dart';

class ApiConfig {
  static String get baseUrl {
    // 👉 Si algún día usas Flutter Web
    if (kIsWeb) {
      return 'http://localhost:5271';
    }

    // 👉 Android (emulador o teléfono físico)
    //
    // Aquí USAMOS la IP REAL de tu PC:
    // 192.168.100.3  (la que viste en ipconfig)
    //
    // Esto funciona si el emulador y el cel están
    // en la MISMA red que tu PC (tu módem).
    if (Platform.isAndroid) {
      return 'http://192.168.100.3:5271';
    }

    // 👉 Windows / Linux / macOS (desktop)
    return 'http://localhost:5271';
  }
}
