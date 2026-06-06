// lib/pages/productos_inactivos_page.dart
import 'package:flutter/material.dart';

import '../models/producto.dart';
import '../services/producto_service.dart';

class ProductosInactivosPage extends StatefulWidget {
  const ProductosInactivosPage({super.key});

  @override
  State<ProductosInactivosPage> createState() => _ProductosInactivosPageState();
}

class _ProductosInactivosPageState extends State<ProductosInactivosPage> {
  final _service = ProductoService();
  List<Producto> _productos = [];
  bool _cargando = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _cargarInactivos();
  }

  Future<void> _cargarInactivos() async {
    setState(() {
      _cargando = true;
      _error = null;
    });
    try {
      final lista = await _service.obtenerProductosInactivos();
      setState(() {
        _productos = lista;
      });
    } catch (e) {
      setState(() => _error = e.toString());
    } finally {
      if (mounted) {
        setState(() => _cargando = false);
      }
    }
  }

  Future<void> _reactivarProducto(Producto p) async {
    try {
      await _service.actualizarProducto(
        idProducto: p.idProducto,
        nombre: p.nombre,
        precio: p.precio,
        fotoUrl: p.fotoUrl,
        activo: true, // 👈 lo reactivamos
        fechaRegistro: p.fechaRegistro ?? DateTime.now(),
      );

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Producto "${p.nombre}" reactivado')),
      );

      await _cargarInactivos(); // recargar lista
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al reactivar: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Productos inactivos'),
      ),
      body: _cargando
          ? const Center(child: CircularProgressIndicator())
          : _error != null
          ? Center(child: Text('Error: $_error'))
          : _productos.isEmpty
          ? const Center(
        child: Text('No hay productos inactivos'),
      )
          : RefreshIndicator(
        onRefresh: _cargarInactivos,
        child: ListView.builder(
          itemCount: _productos.length,
          itemBuilder: (context, index) {
            final p = _productos[index];
            return ListTile(
              leading: CircleAvatar(
                child: Text(
                  p.nombre.isNotEmpty
                      ? p.nombre[0].toUpperCase()
                      : '?',
                ),
              ),
              title: Text(p.nombre),
              subtitle: Text('\$${p.precio.toStringAsFixed(2)}'),
              trailing: IconButton(
                icon: const Icon(Icons.check_circle, color: Colors.green),
                tooltip: 'Activar',
                onPressed: () => _reactivarProducto(p),
              ),
            );
          },
        ),
      ),
    );
  }
}
