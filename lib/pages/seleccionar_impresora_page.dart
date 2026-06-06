// lib/pages/seleccionar_impresora_page.dart
import 'package:flutter/material.dart';
import 'package:blue_thermal_printer/blue_thermal_printer.dart';

import '../services/impresora_bluetooth_service.dart';

class SeleccionarImpresoraPage extends StatefulWidget {
  const SeleccionarImpresoraPage({super.key});

  @override
  State<SeleccionarImpresoraPage> createState() =>
      _SeleccionarImpresoraPageState();
}

class _SeleccionarImpresoraPageState extends State<SeleccionarImpresoraPage> {
  List<BluetoothDevice> _dispositivos = [];
  bool _cargando = false;
  BluetoothDevice? _actual;

  @override
  void initState() {
    super.initState();
    _cargarDispositivos();
  }

  Future<void> _cargarDispositivos() async {
    setState(() {
      _cargando = true;
    });

    final dispositivos =
    await ImpresoraBluetoothService.obtenerDispositivosVinculados();

    setState(() {
      _dispositivos = dispositivos;
      _actual = ImpresoraBluetoothService.dispositivoSeleccionado;
      _cargando = false;
    });
  }

  Future<void> _conectar(BluetoothDevice device) async {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Conectando a impresora...')),
    );

    try {
      await ImpresoraBluetoothService.conectar(device);
      if (!mounted) return;
      setState(() {
        _actual = device;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Conectado a ${device.name ?? device.address}')),
      );
      Navigator.pop(context, device);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al conectar: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!ImpresoraBluetoothService.soportado) {
      return Scaffold(
        appBar: AppBar(title: const Text('Impresora Bluetooth')),
        body: const Center(
          child: Padding(
            padding: EdgeInsets.all(16),
            child: Text(
              'La impresión Bluetooth solo está disponible en Android.\n'
                  'En Windows / Web sigue usando la impresión en PDF.',
              textAlign: TextAlign.center,
            ),
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Seleccionar impresora'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _cargarDispositivos,
          ),
        ],
      ),
      body: _cargando
          ? const Center(child: CircularProgressIndicator())
          : _dispositivos.isEmpty
          ? const Center(
        child: Padding(
          padding: EdgeInsets.all(16),
          child: Text(
            'No se encontraron impresoras Bluetooth emparejadas.\n\n'
                'Primero empareja la impresora en la configuración de Bluetooth del teléfono.',
            textAlign: TextAlign.center,
          ),
        ),
      )
          : ListView.builder(
        itemCount: _dispositivos.length,
        itemBuilder: (context, index) {
          final d = _dispositivos[index];
          final seleccionado =
              _actual != null && _actual!.address == d.address;
          return ListTile(
            leading: const Icon(Icons.print),
            title: Text(d.name ?? 'Impresora'),
            subtitle: Text(d.address ?? ''),
            trailing: seleccionado
                ? const Icon(Icons.check, color: Colors.green)
                : null,
            onTap: () => _conectar(d),
          );
        },
      ),
    );
  }
}
