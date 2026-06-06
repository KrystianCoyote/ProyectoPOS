// lib/models/categoria.dart

class Categoria {
  final int idCategoria;
  final String nombre;
  final bool activo;

  Categoria({
    required this.idCategoria,
    required this.nombre,
    required this.activo,
  });

  factory Categoria.fromJson(Map<String, dynamic> json) {
    return Categoria(
      idCategoria: (json['idCategoria'] ?? json['IdCategoria']) as int,
      nombre: (json['nombre'] ?? json['Nombre']) as String,
      activo: (json['activo'] ?? json['Activo'] ?? 1) is bool
          ? (json['activo'] ?? json['Activo']) as bool
          : ((json['activo'] ?? json['Activo'] ?? 1) as num) == 1,
    );
  }
}
