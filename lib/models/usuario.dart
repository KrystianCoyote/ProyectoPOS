// lib/models/usuario.dart

class Usuario {
  final int idUsuario;
  final String nombre;
  final String usuarioLogin;
  final String rol;
  final bool activo;

  Usuario({
    required this.idUsuario,
    required this.nombre,
    required this.usuarioLogin,
    required this.rol,
    required this.activo,
  });

  /// Es admin si el rol es "Administrador" o "Admin" (insensible a mayúsculas)
  bool get esAdmin {
    final r = rol.toLowerCase().trim();
    return r == 'administrador' || r == 'admin';
  }

  factory Usuario.fromJson(Map<String, dynamic> json) {
    final rawId = json['idUsuario'] ?? json['IdUsuario'] ?? 0;

    final dynamic rawActivo = json['activo'] ?? json['Activo'] ?? true;
    bool parsedActivo;

    if (rawActivo is bool) {
      parsedActivo = rawActivo;
    } else if (rawActivo is num) {
      parsedActivo = rawActivo == 1;
    } else if (rawActivo is String) {
      parsedActivo =
          rawActivo.toLowerCase() == 'true' || rawActivo.trim() == '1';
    } else {
      parsedActivo = true;
    }

    return Usuario(
      idUsuario: rawId is int ? rawId : int.tryParse(rawId.toString()) ?? 0,
      nombre: json['nombre'] ?? json['Nombre'] ?? '',
      usuarioLogin: json['usuarioLogin'] ?? json['UsuarioLogin'] ?? '',
      rol: json['rol'] ?? json['Rol'] ?? '',
      activo: parsedActivo,
    );
  }
}
