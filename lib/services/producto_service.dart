// lib/services/producto_service.dart
import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;

import '../config/api_config.dart';
import '../models/producto.dart';

class ProductoService {
  String get _baseUrl => ApiConfig.baseUrl;

  Uri _uriBase() => Uri.parse('$_baseUrl/api/productos');

  Uri _uriById(int id) => Uri.parse('$_baseUrl/api/productos/$id');

  Uri _uriInactivos() => Uri.parse('$_baseUrl/api/productos/inactivos');

  Uri _uriConFoto() => Uri.parse('$_baseUrl/api/productos/con-foto');

  Uri _uriUpdateConFoto(int id) =>
      Uri.parse('$_baseUrl/api/productos/$id/con-foto');

  // =========================================
  // OBTENER PRODUCTOS
  // =========================================

  Future<List<Producto>> obtenerProductos() async {
    final resp = await http.get(_uriBase());

    if (resp.statusCode != 200) {
      throw Exception(
        'Error al obtener productos: '
            '${resp.statusCode} ${resp.body}',
      );
    }

    final data = jsonDecode(resp.body) as List<dynamic>;
    return data
        .map((e) => Producto.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<List<Producto>> obtenerProductosInactivos() async {
    final resp = await http.get(_uriInactivos());

    if (resp.statusCode != 200) {
      throw Exception(
        'Error al obtener productos inactivos: '
            '${resp.statusCode} ${resp.body}',
      );
    }

    final data = jsonDecode(resp.body) as List<dynamic>;
    return data
        .map((e) => Producto.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  // =========================================
  // CREAR / ACTUALIZAR (JSON normal)
  // =========================================

  Future<Producto> crearProducto({
    required String nombre,
    required double precio,
    String? fotoUrl,
    bool activo = true,
    String? codigoBarras,
    int? idCategoria,
  }) async {
    final body = jsonEncode({
      'idProducto': 0,
      'nombre': nombre,
      'precio': precio,
      'fotoUrl': fotoUrl,
      'activo': activo,
      'fechaRegistro': DateTime.now().toIso8601String(),
      'codigoBarras': codigoBarras,
      'idCategoria': idCategoria,
    });

    final resp = await http.post(
      _uriBase(),
      headers: {'Content-Type': 'application/json'},
      body: body,
    );

    if (resp.statusCode != 201 && resp.statusCode != 200) {
      throw Exception(
        'Error al crear producto: '
            '${resp.statusCode} ${resp.body}',
      );
    }

    final data = jsonDecode(resp.body) as Map<String, dynamic>;
    return Producto.fromJson(data);
  }

  Future<Producto> actualizarProducto({
    required int idProducto,
    required String nombre,
    required double precio,
    String? fotoUrl,
    required bool activo,
    required DateTime fechaRegistro,
    String? codigoBarras,
    int? idCategoria,
  }) async {
    final body = jsonEncode({
      'idProducto': idProducto,
      'nombre': nombre,
      'precio': precio,
      'fotoUrl': fotoUrl,
      'activo': activo,
      'fechaRegistro': fechaRegistro.toIso8601String(),
      'codigoBarras': codigoBarras,
      'idCategoria': idCategoria,
    });

    final resp = await http.put(
      _uriById(idProducto),
      headers: {'Content-Type': 'application/json'},
      body: body,
    );

    if (resp.statusCode != 204 && resp.statusCode != 200) {
      throw Exception(
        'Error al actualizar producto: '
            '${resp.statusCode} ${resp.body}',
      );
    }

    // La API devuelve NoContent, así que opcionalmente podrías volver
    // a pedir el producto por id si lo necesitas. Aquí simplemente
    // devolvemos un Producto con los datos que mandamos:
    return Producto(
      idProducto: idProducto,
      nombre: nombre,
      precio: precio,
      fotoUrl: fotoUrl,
      activo: activo,
      fechaRegistro: fechaRegistro,
      codigoBarras: codigoBarras,
      idCategoria: idCategoria,
      nombreCategoria: null,
    );
  }

  // =========================================
  // CREAR / ACTUALIZAR CON IMAGEN (multipart)
  // =========================================

  Future<Producto> crearProductoConImagen({
    required String nombre,
    required double precio,
    required String rutaImagenLocal,
    String? codigoBarras,
    int? idCategoria,
  }) async {
    final uri = _uriConFoto();
    final request = http.MultipartRequest('POST', uri);

    request.fields['nombre'] = nombre;
    request.fields['precio'] = precio.toString();
    if (codigoBarras != null && codigoBarras.isNotEmpty) {
      request.fields['codigoBarras'] = codigoBarras;
    }
    if (idCategoria != null) {
      request.fields['idCategoria'] = idCategoria.toString();
    }

    request.files.add(
      await http.MultipartFile.fromPath(
        'foto',
        rutaImagenLocal,
        filename: File(rutaImagenLocal).uri.pathSegments.last,
      ),
    );

    final streamed = await request.send();
    final resp = await http.Response.fromStream(streamed);

    if (resp.statusCode != 201 && resp.statusCode != 200) {
      throw Exception(
        'Error al crear producto con imagen: '
            '${resp.statusCode} ${resp.body}',
      );
    }

    final data = jsonDecode(resp.body) as Map<String, dynamic>;
    return Producto.fromJson(data);
  }

  Future<Producto> actualizarProductoConImagen({
    required int idProducto,
    required String nombre,
    required double precio,
    required String rutaImagenLocal,
    String? codigoBarras,
    int? idCategoria,
  }) async {
    final uri = _uriUpdateConFoto(idProducto);
    final request = http.MultipartRequest('PUT', uri);

    request.fields['nombre'] = nombre;
    request.fields['precio'] = precio.toString();
    if (codigoBarras != null && codigoBarras.isNotEmpty) {
      request.fields['codigoBarras'] = codigoBarras;
    }
    if (idCategoria != null) {
      request.fields['idCategoria'] = idCategoria.toString();
    }

    request.files.add(
      await http.MultipartFile.fromPath(
        'foto',
        rutaImagenLocal,
        filename: File(rutaImagenLocal).uri.pathSegments.last,
      ),
    );

    final streamed = await request.send();
    final resp = await http.Response.fromStream(streamed);

    if (resp.statusCode != 204 && resp.statusCode != 200) {
      throw Exception(
        'Error al actualizar producto con imagen: '
            '${resp.statusCode} ${resp.body}',
      );
    }

    // Igual que antes: devolvemos un objeto con lo que sabemos
    return Producto(
      idProducto: idProducto,
      nombre: nombre,
      precio: precio,
      fotoUrl: null, // podrías volver a cargar desde la API si lo necesitas
      activo: true,
      fechaRegistro: DateTime.now(),
      codigoBarras: codigoBarras,
      idCategoria: idCategoria,
      nombreCategoria: null,
    );
  }

  // =========================================
  // ELIMINAR / CAMBIAR ESTADO
  // =========================================

  Future<void> eliminarProducto(int idProducto) async {
    final resp = await http.delete(_uriById(idProducto));

    if (resp.statusCode != 204 && resp.statusCode != 200) {
      throw Exception(
        'Error al eliminar/inhabilitar producto: '
            '${resp.statusCode} ${resp.body}',
      );
    }
  }
}
