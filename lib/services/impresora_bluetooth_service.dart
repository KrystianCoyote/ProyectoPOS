// lib/services/impresora_bluetooth_service.dart
import 'dart:io' show Platform;
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:blue_thermal_printer/blue_thermal_printer.dart';
import 'package:intl/intl.dart';

import '../models/venta.dart';

class ImpresoraBluetoothService {
  static final BlueThermalPrinter _printer = BlueThermalPrinter.instance;

  // Guardamos el dispositivo elegido (puedes luego persistirlo con SharedPreferences si quieres)
  static BluetoothDevice? dispositivoSeleccionado;

  static bool get soportado => !kIsWeb && Platform.isAndroid;

  static Future<bool> get estaConectada async {
    if (!soportado) return false;
    try {
      final conectado = await _printer.isConnected;
      return conectado ?? false;
    } catch (_) {
      return false;
    }
  }

  // Obtener dispositivos Bluetooth ya emparejados en el sistema
  static Future<List<BluetoothDevice>> obtenerDispositivosVinculados() async {
    if (!soportado) return [];
    try {
      final devices = await _printer.getBondedDevices();
      return devices;
    } catch (e) {
      return [];
    }
  }

  // Conectar a un dispositivo concreto
  static Future<void> conectar(BluetoothDevice device) async {
    if (!soportado) {
      throw Exception('Impresión Bluetooth solo disponible en Android');
    }
    try {
      await _printer.connect(device);
      dispositivoSeleccionado = device;
    } catch (e) {
      throw Exception('Error al conectar a la impresora: $e');
    }
  }

  // Imprime una venta en la impresora térmica (sin PDF)
  static Future<void> imprimirVenta(Venta venta) async {
    if (!soportado) {
      // En Windows/web/iOS simplemente no hacemos nada
      throw Exception('Impresión Bluetooth solo está disponible en Android.');
    }

    // Intentar reconectar si no está conectada
    if (!await estaConectada) {
      if (dispositivoSeleccionado != null) {
        try {
          await _printer.connect(dispositivoSeleccionado!);
        } catch (e) {
          throw Exception(
              'No se pudo conectar a la impresora seleccionada. Abre la pantalla de selección de impresora.');
        }
      } else {
        throw Exception(
            'No hay impresora seleccionada. Configura primero la impresora Bluetooth.');
      }
    }

    final df = DateFormat('dd/MM/yyyy HH:mm');
    final fechaStr = df.format(venta.fechaHora.toLocal());

    // --- Comenzamos a mandar líneas ---
    await _printer.printNewLine();
    await _printer.printCustom('TICKET #${venta.idVenta}', 2, 1); // grande, centrado
    await _printer.printCustom('Folio: ${venta.folio}', 1, 1);    // mediano, centrado
    await _printer.printNewLine();

    await _printer.printCustom('Fecha: $fechaStr', 0, 0);
    await _printer.printCustom('Cajero: ${venta.nombreUsuario}', 0, 0);
    await _printer.printNewLine();

    await _printer.printCustom('-----------------------------', 0, 0);

    for (final d in venta.detalles) {
      // Nombre + total a la derecha (simple)
      await _printer.printCustom(
        '${d.nombre}  \$${d.subtotal.toStringAsFixed(2)}',
        0,
        0,
      );
      await _printer.printCustom(
        '${d.cantidad} x \$${d.precioUnitario.toStringAsFixed(2)}',
        0,
        0,
      );
      await _printer.printNewLine();
    }

    await _printer.printCustom('-----------------------------', 0, 0);
    await _printer.printCustom(
      'TOTAL: \$${venta.total.toStringAsFixed(2)}',
      2,
      1, // grande y centrado
    );
    await _printer.printNewLine();
    await _printer.printCustom('¡Gracias por su compra!', 0, 1);
    await _printer.printNewLine();
    await _printer.printNewLine();
  }
}
