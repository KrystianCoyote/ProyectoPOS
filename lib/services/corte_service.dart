// lib/services/corte_service.dart
import 'dart:convert';
import 'package:http/http.dart' as http;

import '../config/api_config.dart';

class CorteCaja {
  final DateTime desde;
  final DateTime hasta;
  final String usuario;
  final int totalTickets;
  final double totalVendido;
  final double ventaPromedio;

  CorteCaja({
    required this.desde,
    required this.hasta,
    required this.usuario,
    required this.totalTickets,
    required this.totalVendido,
    required this.ventaPromedio,
  });

  factory CorteCaja.fromJson(Map<String, dynamic> json) {
    return CorteCaja(
      desde: DateTime.parse(json['desde'] as String),
      hasta: DateTime.parse(json['hasta'] as String),
      usuario: json['usuario'] as String? ?? 'Desconocido',
      totalTickets: (json['totalTickets'] as num?)?.toInt() ?? 0,
      totalVendido: (json['totalVendido'] as num?)?.toDouble() ?? 0.0,
      ventaPromedio: (json['ventaPromedio'] as num?)?.toDouble() ?? 0.0,
    );
  }
}

class CorteService {
  String get _baseUrl => ApiConfig.baseUrl;

  Uri _uriCorte({
    required DateTime desde,
    required DateTime hasta,
    int? idUsuario,
  }) {
    final query = <String, String>{
      'desde': desde.toIso8601String(),
      'hasta': hasta.toIso8601String(),
    };
    if (idUsuario != null) {
      query['idUsuario'] = idUsuario.toString();
    }

    return Uri.parse('$_baseUrl/api/ventas/corte')
        .replace(queryParameters: query);
  }

  Future<CorteCaja> obtenerCorte({
    required DateTime desde,
    required DateTime hasta,
    int? idUsuario,
  }) async {
    final response = await http.get(
      _uriCorte(desde: desde, hasta: hasta, idUsuario: idUsuario),
    );

    if (response.statusCode != 200) {
      throw Exception(
        'Error al obtener corte: '
            '${response.statusCode} ${response.body}',
      );
    }

    final data = jsonDecode(response.body) as Map<String, dynamic>;
    return CorteCaja.fromJson(data);
  }
}
