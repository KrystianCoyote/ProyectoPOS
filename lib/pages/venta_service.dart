// lib/pages/venta_service.dart
import 'dart:convert';
import 'package:http/http.dart' as http;

import '../models/venta.dart';
import '../pages/venta_page.dart' show CarritoItem;
import '../services/auth_service.dart';
import '../config/api_config.dart';

class VentaService {
  // 👇 base URL dinámica (Android / Windows / Web)
  String get _baseUrl => ApiConfig.baseUrl;

  Uri _uri(String path, [Map<String, String>? query]) {
    final uri = Uri.parse('$_baseUrl$path');
    if (query == null || query.isEmpty) return uri;
    return uri.replace(queryParameters: query);
  }

  // =========================================
  // REGISTRAR VENTA (alineado con CrearVentaDto)
  // =========================================
  Future<Venta> registrarVenta(
      List<CarritoItem> items, {
        double? montoRecibido,
      }) async {
    if (items.isEmpty) {
      throw Exception('No hay productos en el carrito.');
    }

    final usuario = AuthService.instance.usuarioActual;
    if (usuario == null) {
      throw Exception('No hay usuario logueado.');
    }
    final int idUsuario = usuario.idUsuario;

    // total solo para calcular pago por defecto
    final total = items.fold<double>(
      0,
          (sum, item) => sum + item.subtotal,
    );

    final pago = montoRecibido ?? total;

    // 👇 IMPORTANTE: estos nombres deben coincidir con CrearVentaDto
    final bodyMap = {
      // CrearVentaDto.IdUsuario  [JsonPropertyName("idUsuario")]
      'idUsuario': idUsuario,
      // CrearVentaDto.MontoRecibido [JsonPropertyName("montoRecibido")]
      'montoRecibido': pago,
      // CrearVentaDto.Productos [JsonPropertyName("productos")]
      'productos': items
          .map((item) => {
        // CrearVentaProductoDto.IdProducto [JsonPropertyName("idProducto")]
        'idProducto': item.producto.idProducto,
        // CrearVentaProductoDto.Cantidad [JsonPropertyName("cantidad")]
        'cantidad': item.cantidad,
        // CrearVentaProductoDto.PrecioUnitario [JsonPropertyName("precioUnitario")]
        // 👇 precio que ya viene del tamaño elegido (chico/mediano/grande)
        'precioUnitario': item.precioUnitario,
      })
          .toList(),
    };

    final response = await http.post(
      _uri('/api/ventas'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(bodyMap),
    );

    if (response.statusCode != 200 && response.statusCode != 201) {
      throw Exception(
        'Error al registrar venta: '
            '${response.statusCode} ${response.body}',
      );
    }

    final data = jsonDecode(response.body) as Map<String, dynamic>;
    return Venta.fromJson(data);
  }

  // =========================================
  // HISTORIAL
  // =========================================
  Future<List<Venta>> obtenerVentas({DateTime? desde, DateTime? hasta}) async {
    final query = <String, String>{};
    if (desde != null) {
      query['desde'] = desde.toIso8601String();
    }
    if (hasta != null) {
      query['hasta'] = hasta.toIso8601String();
    }

    final response = await http.get(_uri('/api/ventas', query));

    if (response.statusCode != 200) {
      throw Exception(
        'Error al obtener ventas: '
            '${response.statusCode} ${response.body}',
      );
    }

    final List<dynamic> data = jsonDecode(response.body) as List<dynamic>;
    return data
        .map((e) => Venta.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<Venta> obtenerVentaPorId(int id) async {
    final response = await http.get(_uri('/api/ventas/$id'));

    if (response.statusCode != 200) {
      throw Exception(
        'Error al obtener venta: '
            '${response.statusCode} ${response.body}',
      );
    }

    final data = jsonDecode(response.body) as Map<String, dynamic>;
    return Venta.fromJson(data);
  }
}
