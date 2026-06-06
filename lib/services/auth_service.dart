// lib/services/auth_service.dart
import 'dart:convert';
import 'package:http/http.dart' as http;

import '../models/usuario.dart';
import '../config/api_config.dart';

class AuthService {
  AuthService._();
  static final AuthService instance = AuthService._();

  String get _baseUrl => ApiConfig.baseUrl;

  Usuario? usuarioActual;

  Future<Usuario> login(String usuario, String password) async {
    final url = Uri.parse('$_baseUrl/api/auth/login');

    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'usuario': usuario,
        'password': password,
      }),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);

      if (data['exito'] == true && data['usuario'] != null) {
        final usuarioObj = Usuario.fromJson(data['usuario']);
        usuarioActual = usuarioObj;
        return usuarioObj;
      } else {
        throw Exception(data['mensaje'] ?? 'Error al iniciar sesión');
      }
    } else if (response.statusCode == 401) {
      final data = jsonDecode(response.body);
      throw Exception(data['mensaje'] ?? 'Usuario o contraseña incorrectos');
    } else {
      throw Exception(
        'Error en el servidor (${response.statusCode}): ${response.body}',
      );
    }
  }
}
