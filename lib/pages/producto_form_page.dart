// lib/pages/producto_form_page.dart
import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';

import '../models/producto.dart';
import '../models/categoria.dart';
import '../services/producto_service.dart';
import '../services/categoria_service.dart';
import 'barcode_scanner_page.dart';
import '../config/api_config.dart';

class ProductoFormPage extends StatefulWidget {
  final Producto? producto; // null = crear, con valor = editar

  const ProductoFormPage({super.key, this.producto});

  @override
  State<ProductoFormPage> createState() => _ProductoFormPageState();
}

class _ProductoFormPageState extends State<ProductoFormPage> {
  final _formKey = GlobalKey<FormState>();
  final _nombreController = TextEditingController();
  final _precioController = TextEditingController();
  final _codigoBarrasController = TextEditingController();

  final ProductoService _productoService = ProductoService();
  final CategoriaService _categoriaService = CategoriaService();

  String? _rutaImagenLocal;
  String? _fotoUrlRemota;
  bool _guardando = false;

  // Categorías
  List<Categoria> _categorias = [];
  Categoria? _categoriaSeleccionada;
  bool _cargandoCategorias = false;
  String? _errorCategorias;

  static final String _baseUrlApi = ApiConfig.baseUrl;

  @override
  void initState() {
    super.initState();

    final p = widget.producto;
    if (p != null) {
      _nombreController.text = p.nombre;
      _precioController.text = p.precio.toStringAsFixed(2);
      _codigoBarrasController.text = p.codigoBarras ?? '';
      _fotoUrlRemota = p.fotoUrl;
    }

    _cargarCategorias();
  }

  @override
  void dispose() {
    _nombreController.dispose();
    _precioController.dispose();
    _codigoBarrasController.dispose();
    super.dispose();
  }

  Future<void> _cargarCategorias() async {
    setState(() {
      _cargandoCategorias = true;
      _errorCategorias = null;
    });

    try {
      final lista = await _categoriaService.obtenerCategorias();
      setState(() {
        _categorias = lista;

        // Si estamos editando, preseleccionar la categoría del producto
        final p = widget.producto;
        if (p != null && p.idCategoria != null) {
          _categoriaSeleccionada = _categorias.firstWhere(
                (c) => c.idCategoria == p.idCategoria,
            orElse: () => _categorias.isNotEmpty ? _categorias.first : null as Categoria,
          );
        }
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

  Future<void> _seleccionarImagen() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.image,
    );

    if (result == null || result.files.isEmpty) return;

    final file = result.files.single;
    if (file.path == null) return;

    setState(() {
      _rutaImagenLocal = file.path!;
    });
  }

  Future<void> _scanCodigoBarras() async {
    final codigo = await Navigator.push<String>(
      context,
      MaterialPageRoute(
        builder: (_) => const BarcodeScannerPage(
          title: 'Escanear código de barras',
        ),
      ),
    );

    if (codigo == null || codigo.trim().isEmpty) return;

    setState(() {
      _codigoBarrasController.text = codigo.trim();
    });
  }

  Future<void> _guardar() async {
    if (!_formKey.currentState!.validate()) return;

    final nombre = _nombreController.text.trim();
    final precio = double.tryParse(
      _precioController.text.replaceAll(',', '.'),
    );
    final codigoBarras = _codigoBarrasController.text.trim();
    final idCategoria = _categoriaSeleccionada?.idCategoria;

    if (precio == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Precio inválido')),
      );
      return;
    }

    setState(() {
      _guardando = true;
    });

    try {
      final esEdicion = widget.producto != null;
      late Producto result;

      if (esEdicion) {
        final p = widget.producto!;

        if (_rutaImagenLocal != null) {
          // Actualizar con nueva imagen
          result = await _productoService.actualizarProductoConImagen(
            idProducto: p.idProducto,
            nombre: nombre,
            precio: precio,
            rutaImagenLocal: _rutaImagenLocal!,
            codigoBarras: codigoBarras.isEmpty ? null : codigoBarras,
            idCategoria: idCategoria,
          );
        } else {
          // Actualizar sin cambiar imagen
          result = await _productoService.actualizarProducto(
            idProducto: p.idProducto,
            nombre: nombre,
            precio: precio,
            fotoUrl: _fotoUrlRemota,
            activo: p.activo,
            fechaRegistro: p.fechaRegistro ?? DateTime.now(),
            codigoBarras: codigoBarras.isEmpty ? null : codigoBarras,
            idCategoria: idCategoria,
          );
        }
      } else {
        // Crear nuevo producto
        if (_rutaImagenLocal != null) {
          result = await _productoService.crearProductoConImagen(
            nombre: nombre,
            precio: precio,
            rutaImagenLocal: _rutaImagenLocal!,
            codigoBarras: codigoBarras.isEmpty ? null : codigoBarras,
            idCategoria: idCategoria,
          );
        } else {
          result = await _productoService.crearProducto(
            nombre: nombre,
            precio: precio,
            fotoUrl: null,
            activo: true,
            codigoBarras: codigoBarras.isEmpty ? null : codigoBarras,
            idCategoria: idCategoria,
          );
        }
      }

      if (!mounted) return;

      Navigator.of(context).pop(result);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al guardar producto: $e')),
      );
    } finally {
      if (mounted) {
        setState(() {
          _guardando = false;
        });
      }
    }
  }

  Widget _buildImagenPreview() {
    Widget child = const Icon(
      Icons.image_not_supported,
      size: 64,
    );

    if (_rutaImagenLocal != null) {
      child = Image.file(
        File(_rutaImagenLocal!),
        fit: BoxFit.cover,
      );
    } else if (_fotoUrlRemota != null && _fotoUrlRemota!.isNotEmpty) {
      final url = _fotoUrlRemota!.startsWith('http')
          ? _fotoUrlRemota!
          : '$_baseUrlApi${_fotoUrlRemota!}';

      child = Image.network(
        url,
        fit: BoxFit.cover,
      );
    }

    return Container(
      width: double.infinity,
      height: 150,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade400),
      ),
      clipBehavior: Clip.antiAlias,
      child: Center(child: child),
    );
  }

  Widget _buildDropdownCategorias() {
    if (_cargandoCategorias) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 8.0),
        child: LinearProgressIndicator(),
      );
    }

    if (_errorCategorias != null) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 8.0),
        child: Text(
          _errorCategorias!,
          style: const TextStyle(color: Colors.red),
        ),
      );
    }

    if (_categorias.isEmpty) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 8.0),
        child: Text(
          'No hay categorías registradas (opcional).',
          style: TextStyle(fontSize: 12, color: Colors.black54),
        ),
      );
    }

    return DropdownButtonFormField<Categoria>(
      value: _categoriaSeleccionada,
      decoration: const InputDecoration(
        labelText: 'Categoría (opcional)',
        border: OutlineInputBorder(),
      ),
      items: _categorias
          .map(
            (c) => DropdownMenuItem<Categoria>(
          value: c,
          child: Text(c.nombre),
        ),
      )
          .toList(),
      onChanged: (value) {
        setState(() {
          _categoriaSeleccionada = value;
        });
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final esEdicion = widget.producto != null;

    return Scaffold(
      appBar: AppBar(
        title: Text(esEdicion ? 'Editar producto' : 'Nuevo producto'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: AutofillGroup(
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                TextFormField(
                  controller: _nombreController,
                  decoration: const InputDecoration(
                    labelText: 'Nombre',
                    border: OutlineInputBorder(),
                  ),
                  textInputAction: TextInputAction.next,
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Ingresa el nombre del producto';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _precioController,
                  decoration: const InputDecoration(
                    labelText: 'Precio',
                    prefixText: '\$ ',
                    border: OutlineInputBorder(),
                  ),
                  keyboardType:
                  const TextInputType.numberWithOptions(decimal: true),
                  textInputAction: TextInputAction.next,
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Ingresa el precio';
                    }
                    final v = double.tryParse(
                        value.replaceAll(',', '.').trim());
                    if (v == null || v < 0) {
                      return 'Precio inválido';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _codigoBarrasController,
                  decoration: InputDecoration(
                    labelText: 'Código de barras (opcional)',
                    border: const OutlineInputBorder(),
                    suffixIcon: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (_codigoBarrasController.text.isNotEmpty)
                          IconButton(
                            icon: const Icon(Icons.clear),
                            onPressed: () {
                              setState(() {
                                _codigoBarrasController.clear();
                              });
                            },
                          ),
                        IconButton(
                          icon: const Icon(Icons.qr_code_scanner),
                          tooltip: 'Escanear con cámara',
                          onPressed: _scanCodigoBarras,
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                _buildDropdownCategorias(),
                const SizedBox(height: 16),
                _buildImagenPreview(),
                const SizedBox(height: 8),
                Align(
                  alignment: Alignment.centerLeft,
                  child: TextButton.icon(
                    onPressed: _seleccionarImagen,
                    icon: const Icon(Icons.image),
                    label: const Text('Seleccionar imagen'),
                  ),
                ),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: _guardando ? null : _guardar,
                    icon: const Icon(Icons.save),
                    label: Text(
                      _guardando
                          ? 'Guardando...'
                          : (esEdicion
                          ? 'Guardar cambios'
                          : 'Crear producto'),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
