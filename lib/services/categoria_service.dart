// lib/services/categoria_service.dart
import 'dart:convert';
import 'package:http/http.dart' as http;

import '../config/api_config.dart';
import '../models/categoria.dart';

class CategoriaService {
  String get _baseUrl => ApiConfig.baseUrl;

  Future<List<Categoria>> obtenerCategorias() async {
    final uri = Uri.parse('$_baseUrl/api/categorias');

    final resp = await http.get(uri);

    if (resp.statusCode != 200) {
      throw Exception(
        'Error al obtener categorías: '
            '${resp.statusCode} ${resp.body}',
      );
    }

    final data = jsonDecode(resp.body) as List<dynamic>;

    return data
        .map((e) => Categoria.fromJson(e as Map<String, dynamic>))
        .toList();
  }
}
