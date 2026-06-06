// lib/main.dart
import 'package:flutter/material.dart';

import 'models/producto.dart';
import 'pages/productos_inactivos_page.dart';
import 'services/producto_service.dart';
import 'pages/producto_form_page.dart';
import 'pages/venta_page.dart';
import 'pages/login_page.dart';
import 'services/auth_service.dart'; // 👈 para saber si es admin
import '../config/api_config.dart';

void main() {
  runApp(const PosApp());
}

class PosApp extends StatelessWidget {
  const PosApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'POS Productos',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      // 👇 Pantalla inicial: login
      home: const LoginPage(),
    );
  }
}

class ListaProductosPage extends StatefulWidget {
  const ListaProductosPage({super.key});

  @override
  State<ListaProductosPage> createState() => _ListaProductosPageState();
}

class _ListaProductosPageState extends State<ListaProductosPage> {
  final ProductoService _service = ProductoService();
  late Future<List<Producto>> _futureProductos;

  // 🔗 Base de la API para armar la URL completa de la imagen
  static final String _baseUrlApi = ApiConfig.baseUrl;

  @override
  void initState() {
    super.initState();
    _cargar();
  }

  void _cargar() {
    _futureProductos = _service.obtenerProductos();
  }

  void _recargar() {
    setState(_cargar);
  }

  Future<void> _agregarProducto() async {
    final result = await Navigator.push<Producto?>(
      context,
      MaterialPageRoute(
        builder: (_) => const ProductoFormPage(),
      ),
    );
    if (result != null) {
      _recargar();
    }
  }

  Future<void> _editarProducto(Producto p) async {
    final result = await Navigator.push<Producto?>(
      context,
      MaterialPageRoute(
        builder: (_) => ProductoFormPage(producto: p),
      ),
    );
    if (result != null) {
      _recargar();
    }
  }

  Future<void> _eliminarProducto(Producto p) async {
    final confirma = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Eliminar producto'),
        content: Text('¿Seguro que deseas eliminar "${p.nombre}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Eliminar'),
          ),
        ],
      ),
    );

    if (confirma != true) return;

    try {
      await _service.eliminarProducto(p.idProducto);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Producto eliminado')),
        );
        _recargar();
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al eliminar: $e')),
      );
    }
  }

  void _abrirVentas() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const VentaPage()),
    );
  }

  /// Construye el widget de imagen/avatar del producto
  Widget _buildProductoLeading(Producto p) {
    final String foto = p.fotoUrl ?? "";
    final bool tieneFoto = foto.isNotEmpty;

    if (!tieneFoto) {
      // 👉 Sin foto: avatar con la inicial
      return CircleAvatar(
        child: Text(
          p.nombre.isNotEmpty ? p.nombre[0].toUpperCase() : '?',
        ),
      );
    }

    // Armar URL completa (si viene relativa tipo "/imagenes/xyz.jpg")
    final String url = foto.startsWith('http') ? foto : '$_baseUrlApi$foto';

    return ClipRRect(
      borderRadius: BorderRadius.circular(8),
      child: Image.network(
        url,
        width: 48,
        height: 48,
        fit: BoxFit.cover,
        // 👉 Si falla la imagen, regresamos al avatar con inicial
        errorBuilder: (context, error, stackTrace) {
          return CircleAvatar(
            child: Text(
              p.nombre.isNotEmpty ? p.nombre[0].toUpperCase() : '?',
            ),
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // 👇 usuario actual y si es admin
    final usuario = AuthService.instance.usuarioActual;
    final bool esAdmin = usuario?.esAdmin ?? false;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Lista de productos'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _recargar,
            tooltip: 'Recargar activos',
          ),
          if (esAdmin)
            IconButton(
              icon: const Icon(Icons.archive_outlined),
              tooltip: 'Ver inactivos',
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const ProductosInactivosPage(),
                  ),
                );
              },
            ),
          IconButton(
            icon: const Icon(Icons.shopping_cart_checkout),
            tooltip: 'Ir a ventas',
            onPressed: _abrirVentas,
          ),
        ],
      ),
      // 👉 Solo los admins pueden agregar productos
      floatingActionButton: esAdmin
          ? FloatingActionButton.extended(
        onPressed: _agregarProducto,
        icon: const Icon(Icons.add),
        label: const Text('Agregar'),
      )
          : null,
      body: FutureBuilder<List<Producto>>(
        future: _futureProductos,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Text(
                  'Error al cargar productos:\n${snapshot.error}',
                  textAlign: TextAlign.center,
                ),
              ),
            );
          }

          final productos = snapshot.data ?? [];

          if (productos.isEmpty) {
            return const Center(
              child: Text(
                'No hay productos registrados',
                style: TextStyle(fontSize: 16),
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(8),
            itemCount: productos.length,
            itemBuilder: (context, index) {
              final p = productos[index];

              return Card(
                child: ListTile(
                  leading: _buildProductoLeading(p),
                  title: Text(p.nombre),
                  subtitle: Text('\$${p.precio.toStringAsFixed(2)}'),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.edit),
                        onPressed: () => _editarProducto(p),
                      ),
                      // 👉 Solo los admins pueden inhabilitar/eliminar
                      if (esAdmin)
                        IconButton(
                          icon: const Icon(Icons.close, color: Colors.red),
                          onPressed: () => _eliminarProducto(p),
                        ),
                    ],
                  ),
                  // sigue abriendo ventas al tocar el producto
                  onTap: _abrirVentas,
                ),
              );
            },
          );
        },
      ),
    );
  }
}
