// lib/pages/venta_page.dart
import 'package:flutter/material.dart';
import 'package:printing/printing.dart';

import '../models/producto.dart';
import '../models/venta.dart';
import '../models/categoria.dart';
import '../services/producto_service.dart';
import '../services/categoria_service.dart';
import '../pages/venta_service.dart';
import '../services/ticket_pdf_service.dart';
import 'barcode_scanner_page.dart';
import '../config/api_config.dart';

class CarritoItem {
  final String clave;           // idProducto + tamaño (para distinguir)
  final Producto producto;
  final String? tamano;         // Chico / Mediano / Grande / null
  final double precioUnitario;  // según tamaño elegido
  int cantidad;

  CarritoItem({
    required this.clave,
    required this.producto,
    required this.precioUnitario,
    this.tamano,
    this.cantidad = 1,
  });

  double get subtotal => precioUnitario * cantidad;
}

class VentaPage extends StatefulWidget {
  const VentaPage({super.key});

  @override
  State<VentaPage> createState() => _VentaPageState();
}

class _VentaPageState extends State<VentaPage> {
  final ProductoService _productoService = ProductoService();
  final CategoriaService _categoriaService = CategoriaService();
  final VentaService _ventaService = VentaService();

  // Productos
  bool _cargandoProductos = true;
  String? _errorProductos;
  final List<Producto> _productos = [];
  final List<Producto> _productosFiltrados = [];

  // Categorías
  bool _cargandoCategorias = false;
  String? _errorCategorias;
  final List<Categoria> _categorias = [];
  Categoria? _categoriaSeleccionada; // null = Todas

  // Carrito
  final Map<String, CarritoItem> _carrito = {};
  bool _registrando = false;

  // Filtro texto
  final TextEditingController _searchController = TextEditingController();

  static final String _baseUrlApi = ApiConfig.baseUrl;

  @override
  void initState() {
    super.initState();
    _cargarTodo();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  // =======================
  // CARGA INICIAL
  // =======================

  Future<void> _cargarTodo() async {
    await Future.wait([
      _cargarCategorias(),
      _cargarProductos(),
    ]);
  }

  Future<void> _cargarProductos() async {
    setState(() {
      _cargandoProductos = true;
      _errorProductos = null;
    });

    try {
      final lista = await _productoService.obtenerProductos();
      setState(() {
        _productos
          ..clear()
          ..addAll(lista);
      });
      _aplicarFiltro();
    } catch (e) {
      setState(() {
        _errorProductos = 'Error al cargar productos: $e';
      });
    } finally {
      if (mounted) {
        setState(() {
          _cargandoProductos = false;
        });
      }
    }
  }

  Future<void> _cargarCategorias() async {
    setState(() {
      _cargandoCategorias = true;
      _errorCategorias = null;
    });

    try {
      final lista = await _categoriaService.obtenerCategorias();
      setState(() {
        _categorias
          ..clear()
          ..addAll(lista.where((c) => c.activo));
        _categoriaSeleccionada = null; // "Todas"
      });
    } catch (e) {
      setState(() {
        _errorCategorias = 'Error al cargar categorías: $e';
      });
    } finally {
      if (mounted) {
        setState(() {
          _cargandoCategorias = false;
        });
      }
    }
  }

  // =======================
  // FILTRO (texto + categoría)
  // =======================

  void _aplicarFiltro() {
    final query = _searchController.text.toLowerCase().trim();
    final idCat = _categoriaSeleccionada?.idCategoria;

    setState(() {
      _productosFiltrados
        ..clear()
        ..addAll(
          _productos.where((p) {
            // 1) filtro por categoría
            final matchCategoria =
            idCat == null ? true : p.idCategoria == idCat;

            // 2) filtro por texto
            final texto = p.nombre.toLowerCase();
            final matchTexto = query.isEmpty
                ? true
                : (texto.contains(query) ||
                (p.codigoBarras != null &&
                    p.codigoBarras!.toLowerCase().contains(query)));

            return matchCategoria && matchTexto;
          }),
        );
    });
  }

  Future<void> _scanCodigoBarras() async {
    final codigo = await Navigator.push<String>(
      context,
      MaterialPageRoute(
        builder: (_) => const BarcodeScannerPage(title: 'Escanear producto'),
      ),
    );

    if (codigo == null || codigo.trim().isEmpty) return;

    _searchController.text = codigo.trim();
    _aplicarFiltro();
  }

  // =======================
  // CARRITO
  // =======================

  String _claveCarrito(int idProducto, String? tamano) {
    return '$idProducto|${tamano ?? "N"}';
  }

  // producto sin tamaños
  void _agregarProductoSimple(Producto p) {
    final clave = _claveCarrito(p.idProducto, null);

    setState(() {
      final itemExistente = _carrito[clave];
      if (itemExistente == null) {
        _carrito[clave] = CarritoItem(
          clave: clave,
          producto: p,
          precioUnitario: p.precio,
          tamano: null,
          cantidad: 1,
        );
      } else {
        itemExistente.cantidad++;
      }
    });
  }

  // producto con tamaños -> mostrar ventanita estilo Starbucks
  Future<void> _agregarProductoConTamano(Producto p) async {
    // Armar lista de opciones válidas
    final opciones = <_OpcionTamano>[];

    if (p.precioChico != null && p.precioChico! > 0) {
      opciones.add(_OpcionTamano('Chico', p.precioChico!));
    }
    if (p.precioMediano != null && p.precioMediano! > 0) {
      opciones.add(_OpcionTamano('Mediano', p.precioMediano!));
    }
    if (p.precioGrande != null && p.precioGrande! > 0) {
      opciones.add(_OpcionTamano('Grande', p.precioGrande!));
    }

    // Si NO tiene precios, lo tratamos como normal
    if (!p.usaTamanos || opciones.isEmpty) {
      _agregarProductoSimple(p);
      return;
    }

    // Mostrar modal elegante
    final seleccion = await showDialog<_OpcionTamano>(
      context: context,
      barrierDismissible: true, // Permite cerrar tocando afuera
      builder: (ctx) {
        final String foto = p.fotoUrl ?? "";
        final String url = foto.startsWith("http")
            ? foto
            : (foto.isNotEmpty ? "$_baseUrlApi$foto" : "");

        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Imagen grande del producto
                ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: url.isNotEmpty
                      ? Image.network(
                    url,
                    width: 180,
                    height: 180,
                    fit: BoxFit.cover,
                  )
                      : Container(
                    width: 180,
                    height: 180,
                    color: Colors.grey.shade200,
                    child: Center(
                      child: Text(
                        p.nombre[0].toUpperCase(),
                        style: const TextStyle(
                          fontSize: 40,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 16),

                // Nombre del producto
                Text(
                  p.nombre,
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),

                const SizedBox(height: 20),
                const Text(
                  "Selecciona el tamaño",
                  style: TextStyle(fontSize: 16),
                ),
                const SizedBox(height: 12),

                // Botones de tamaños
                for (final op in opciones)
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.black87,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                      onPressed: () => Navigator.of(ctx).pop(op),
                      child: Text(
                        "${op.nombre}   ·   \$${op.precio.toStringAsFixed(2)}",
                        style: const TextStyle(fontSize: 18),
                      ),
                    ),
                  ),

                const SizedBox(height: 10),

                // Botón cancelar
                TextButton(
                  onPressed: () => Navigator.of(ctx).pop(),
                  child: const Text(
                    "Cancelar",
                    style: TextStyle(fontSize: 16),
                  ),
                )
              ],
            ),
          ),
        );
      },
    );

    if (seleccion == null) return;

    // clave compuesta para diferenciar tamaños
    final clave = _claveCarrito(p.idProducto, seleccion.nombre);

    setState(() {
      final existente = _carrito[clave];
      if (existente == null) {
        _carrito[clave] = CarritoItem(
          clave: clave,
          producto: p,
          precioUnitario: seleccion.precio,
          tamano: seleccion.nombre,
          cantidad: 1,
        );
      } else {
        existente.cantidad++;
      }
    });
  }

  void _onAgregarProducto(Producto p) {
    if (p.usaTamanos == true) {
      _agregarProductoConTamano(p);
    } else {
      _agregarProductoSimple(p);
    }
  }

  void _cambiarCantidad(CarritoItem item, int delta) {
    final clave = item.clave;
    final actual = _carrito[clave];
    if (actual == null) return;

    setState(() {
      actual.cantidad += delta;
      if (actual.cantidad <= 0) {
        _carrito.remove(clave);
      }
    });
  }

  void _eliminarDelCarrito(CarritoItem item) {
    setState(() {
      _carrito.remove(item.clave);
    });
  }

  void _limpiarCarrito() {
    setState(() {
      _carrito.clear();
    });
  }

  double get _totalCarrito {
    return _carrito.values.fold<double>(
      0,
          (sum, item) => sum + item.subtotal,
    );
  }

  // =======================
  // REGISTRO DE VENTA
  // =======================

  Future<void> _registrarVentaEImprimir() async {
    if (_carrito.isEmpty || _registrando) return;

    setState(() {
      _registrando = true;
    });

    try {
      final venta = await _ventaService.registrarVenta(
        _carrito.values.toList(),
      );

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Venta registrada correctamente')),
      );

      final bytes = await TicketPdfService.generarTicketPdf(venta);

      await Printing.layoutPdf(
        onLayout: (format) async => bytes,
      );

      setState(() {
        _carrito.clear();
      });
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al registrar venta: $e')),
      );
    } finally {
      if (mounted) {
        setState(() {
          _registrando = false;
        });
      }
    }
  }

  // =======================
  // UI AUXILIAR
  // =======================

  Widget _buildProductoLeading(Producto p) {
    final String foto = p.fotoUrl ?? "";
    final bool tieneFoto = foto.isNotEmpty;

    if (!tieneFoto) {
      return CircleAvatar(
        child: Text(
          p.nombre.isNotEmpty ? p.nombre[0].toUpperCase() : '?',
        ),
      );
    }

    final String url = foto.startsWith('http') ? foto : '$_baseUrlApi$foto';

    return ClipRRect(
      borderRadius: BorderRadius.circular(8),
      child: Image.network(
        url,
        width: 48,
        height: 48,
        fit: BoxFit.cover,
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

  String _buildPrecioProductoLabel(Producto p) {
    if (p.usaTamanos) {
      final partes = <String>[];
      if (p.precioChico != null) {
        partes.add('Ch: \$${p.precioChico!.toStringAsFixed(2)}');
      }
      if (p.precioMediano != null) {
        partes.add('M: \$${p.precioMediano!.toStringAsFixed(2)}');
      }
      if (p.precioGrande != null) {
        partes.add('G: \$${p.precioGrande!.toStringAsFixed(2)}');
      }
      if (partes.isNotEmpty) {
        return partes.join('  ·  ');
      }
    }
    return '\$${p.precio.toStringAsFixed(2)}';
  }

  Widget _buildBuscador() {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: TextField(
        controller: _searchController,
        onChanged: (_) => _aplicarFiltro(),
        decoration: InputDecoration(
          prefixIcon: const Icon(Icons.search),
          hintText: 'Buscar producto por nombre o código',
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          suffixIcon: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (_searchController.text.isNotEmpty)
                IconButton(
                  icon: const Icon(Icons.clear),
                  onPressed: () {
                    _searchController.clear();
                    _aplicarFiltro();
                  },
                ),
              IconButton(
                icon: const Icon(Icons.qr_code_scanner),
                tooltip: 'Escanear código de barras',
                onPressed: _scanCodigoBarras,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildChipsCategorias() {
    if (_cargandoCategorias) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 4),
        child: LinearProgressIndicator(),
      );
    }

    if (_errorCategorias != null) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 4),
        child: Text(
          _errorCategorias!,
          style: const TextStyle(color: Colors.red),
        ),
      );
    }

    if (_categorias.isEmpty) {
      return const SizedBox.shrink();
    }

    return SizedBox(
      height: 40,
      child: ListView(
        scrollDirection: Axis.horizontal,
        children: [
          const SizedBox(width: 8),
          ChoiceChip(
            label: const Text('Todas'),
            selected: _categoriaSeleccionada == null,
            onSelected: (_) {
              setState(() {
                _categoriaSeleccionada = null;
              });
              _aplicarFiltro();
            },
          ),
          const SizedBox(width: 8),
          ..._categorias.map((c) {
            final selected =
                _categoriaSeleccionada?.idCategoria == c.idCategoria;
            return Padding(
              padding: const EdgeInsets.only(right: 8.0),
              child: ChoiceChip(
                label: Text(c.nombre),
                selected: selected,
                onSelected: (_) {
                  setState(() {
                    _categoriaSeleccionada = c;
                  });
                  _aplicarFiltro();
                },
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildListaProductos() {
    if (_cargandoProductos) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_errorProductos != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Text(
            _errorProductos!,
            textAlign: TextAlign.center,
          ),
        ),
      );
    }

    if (_productosFiltrados.isEmpty) {
      return const Center(
        child: Text('No se encontraron productos'),
      );
    }

    return ListView.builder(
      itemCount: _productosFiltrados.length,
      itemBuilder: (context, index) {
        final p = _productosFiltrados[index];

        return Card(
          child: ListTile(
            leading: _buildProductoLeading(p),
            title: Text(p.nombre),
            subtitle: Text(_buildPrecioProductoLabel(p)),
            trailing: IconButton(
              icon: const Icon(Icons.add_shopping_cart),
              onPressed: () => _onAgregarProducto(p),
            ),
          ),
        );
      },
    );
  }

  Widget _buildCarrito() {
    final carritoList = _carrito.values.toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const Text(
          'Carrito',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        Expanded(
          child: carritoList.isEmpty
              ? const Center(
            child: Text('No hay productos en el carrito'),
          )
              : ListView.builder(
            itemCount: carritoList.length,
            itemBuilder: (context, index) {
              final item = carritoList[index];
              final tamanoText =
              item.tamano != null ? ' (${item.tamano})' : '';
              return ListTile(
                title: Text(item.producto.nombre),
                subtitle: Text(
                  '${item.cantidad} x \$${item.precioUnitario.toStringAsFixed(2)}'
                      '$tamanoText = \$${item.subtotal.toStringAsFixed(2)}',
                ),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.remove),
                      onPressed: () => _cambiarCantidad(item, -1),
                    ),
                    IconButton(
                      icon: const Icon(Icons.add),
                      onPressed: () => _cambiarCantidad(item, 1),
                    ),
                    IconButton(
                      icon: const Icon(Icons.delete, color: Colors.red),
                      onPressed: () => _eliminarDelCarrito(item),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Total: \$${_totalCarrito.toStringAsFixed(2)}',
          textAlign: TextAlign.right,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            OutlinedButton.icon(
              onPressed: _carrito.isEmpty ? null : _limpiarCarrito,
              icon: const Icon(Icons.delete_sweep),
              label: const Text('Limpiar'),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: ElevatedButton.icon(
                onPressed: _carrito.isEmpty || _registrando
                    ? null
                    : _registrarVentaEImprimir,
                icon: const Icon(Icons.print),
                label: _registrando
                    ? const Text('Registrando...')
                    : const Text('Registrar e imprimir'),
              ),
            ),
          ],
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final bool esAncho = size.width >= 800;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Registrar venta'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: 'Recargar',
            onPressed: _cargarTodo,
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: esAncho
            ? Row(
          children: [
            Expanded(
              flex: 2,
              child: Column(
                children: [
                  _buildBuscador(),
                  _buildChipsCategorias(),
                  const SizedBox(height: 4),
                  Expanded(child: _buildListaProductos()),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              flex: 1,
              child: _buildCarrito(),
            ),
          ],
        )
            : Column(
          children: [
            _buildBuscador(),
            _buildChipsCategorias(),
            const SizedBox(height: 4),
            Expanded(
              flex: 3,
              child: _buildListaProductos(),
            ),
            const Divider(),
            Expanded(
              flex: 2,
              child: _buildCarrito(),
            ),
          ],
        ),
      ),
    );
  }
}

// Clase interna para las opciones de tamaño
class _OpcionTamano {
  final String nombre;
  final double precio;

  const _OpcionTamano(this.nombre, this.precio);
}