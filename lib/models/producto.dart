// lib/models/producto.dart

class Producto {
  final int idProducto;
  final String nombre;
  final double precio;          // precio base (cuando no usa tamaños)
  final String? fotoUrl;
  final bool activo;
  final DateTime? fechaRegistro;
  final String? codigoBarras;

  // Categoría
  final int? idCategoria;
  final String? nombreCategoria;

  // Tamaños
  final bool usaTamanos;
  final double? precioChico;
  final double? precioMediano;
  final double? precioGrande;

  Producto({
    required this.idProducto,
    required this.nombre,
    required this.precio,
    this.fotoUrl,
    required this.activo,
    this.fechaRegistro,
    this.codigoBarras,
    this.idCategoria,
    this.nombreCategoria,
    this.usaTamanos = false,
    this.precioChico,
    this.precioMediano,
    this.precioGrande,
  });

  // --------- HELPERS DE PARSEO ---------

  // bool que puede venir como 0/1, true/false, "true"/"false", etc.
  static bool _parseBool(dynamic value, {bool defaultValue = false}) {
    if (value == null) return defaultValue;
    if (value is bool) return value;
    if (value is num) return value == 1;
    if (value is String) {
      final v = value.toLowerCase().trim();
      return v == '1' || v == 'true' || v == 't' || v == 'yes' || v == 'si';
    }
    return defaultValue;
  }

  static double? _parseDouble(dynamic value) {
    if (value == null) return null;
    if (value is num) return value.toDouble();
    return double.tryParse(value.toString());
  }

  static int _parseInt(dynamic value) {
    if (value is int) return value;
    if (value is num) return value.toInt();
    if (value is String) {
      final parsed = int.tryParse(value);
      if (parsed != null) return parsed;
    }
    throw const FormatException('idProducto inválido en JSON');
  }

  // --------- FROM JSON ---------

  factory Producto.fromJson(Map<String, dynamic> json) {
    // IdProducto
    final rawId = json['idProducto'] ?? json['IdProducto'];

    // Activo
    final bool activo = _parseBool(
      json['activo'] ?? json['Activo'] ?? 1,
      defaultValue: true,
    );

    // FechaRegistro
    DateTime? fecha;
    final rawFecha = json['fechaRegistro'] ?? json['FechaRegistro'];
    if (rawFecha == null) {
      fecha = null;
    } else if (rawFecha is DateTime) {
      fecha = rawFecha;
    } else {
      fecha = DateTime.tryParse(rawFecha.toString());
    }

    // IdCategoria
    final dynamic rawIdCat = json['idCategoria'] ?? json['IdCategoria'];
    int? idCat;
    if (rawIdCat != null) {
      if (rawIdCat is int) {
        idCat = rawIdCat;
      } else if (rawIdCat is num) {
        idCat = rawIdCat.toInt();
      } else if (rawIdCat is String && rawIdCat.isNotEmpty) {
        idCat = int.tryParse(rawIdCat);
      }
    }

    // Nombre de categoría
    final String? nombreCat = (json['nombreCategoria'] ??
        json['NombreCategoria'] ??
        json['categoriaNombre']) as String?;

    // Usa tamaños
    final bool usaTamanos = _parseBool(
      json['usaTamanos'] ?? json['UsaTamanos'] ?? 0,
      defaultValue: false,
    );

    // Precio base
    final rawPrecio = json['precio'] ?? json['Precio'] ?? 0;
    final double precioBase =
    rawPrecio is num ? rawPrecio.toDouble() : double.parse(rawPrecio.toString());

    return Producto(
      idProducto: _parseInt(rawId),
      nombre: (json['nombre'] ?? json['Nombre']) as String,
      precio: precioBase,
      fotoUrl: (json['fotoUrl'] ?? json['FotoUrl'] ?? json['Foto']) as String?,
      activo: activo,
      fechaRegistro: fecha,
      codigoBarras:
      (json['codigoBarras'] ?? json['CodigoBarras']) as String?,
      idCategoria: idCat,
      nombreCategoria: nombreCat,
      usaTamanos: usaTamanos,
      precioChico: _parseDouble(json['precioChico'] ?? json['PrecioChico']),
      precioMediano:
      _parseDouble(json['precioMediano'] ?? json['PrecioMediano']),
      precioGrande:
      _parseDouble(json['precioGrande'] ?? json['PrecioGrande']),
    );
  }
}
