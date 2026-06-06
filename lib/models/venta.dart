// lib/models/venta.dart

class Venta {
  final int idVenta;
  final DateTime fechaHora;
  final double total;
  final double cambio;
  final int idUsuario;
  final String nombreUsuario;
  final List<DetalleVenta> detalles;

  Venta({
    required this.idVenta,
    required this.fechaHora,
    required this.total,
    required this.cambio,
    required this.idUsuario,
    required this.nombreUsuario,
    required this.detalles,
  });

  // ============================
  // 👇 NUEVO: FOLIO BONITO
  // ============================
  String get folio => idVenta.toString().padLeft(6, '0');

  factory Venta.fromJson(Map<String, dynamic> json) {
    return Venta(
      idVenta: (json['idVenta'] ?? json['IdVenta']) as int,
      fechaHora: DateTime.parse(
        json['fechaHora'] ?? json['FechaHora'],
      ),
      total: (json['total'] ?? json['Total']).toDouble(),
      cambio: (json['cambio'] ?? json['Cambio'] ?? 0).toDouble(),
      idUsuario: (json['idUsuario'] ?? json['IdUsuario']) as int,

      // Si la API no envía nombreUsuario, evitar crash
      nombreUsuario: json['nombreUsuario'] ??
          json['NombreUsuario'] ??
          "Desconocido",

      detalles: (json['detalles'] ?? json['Detalles'] ?? [])
          .map<DetalleVenta>(
            (e) => DetalleVenta.fromJson(e),
      )
          .toList(),
    );
  }
}

class DetalleVenta {
  final int idProducto;
  final String nombre;
  final int cantidad;
  final double precioUnitario;
  final double subtotal;

  DetalleVenta({
    required this.idProducto,
    required this.nombre,
    required this.cantidad,
    required this.precioUnitario,
    required this.subtotal,
  });

  factory DetalleVenta.fromJson(Map<String, dynamic> json) {
    return DetalleVenta(
      idProducto: (json['idProducto'] ?? json['IdProducto']) as int,
      nombre: json['nombre'] ?? json['Nombre'],
      cantidad: (json['cantidad'] ?? json['Cantidad']) as int,
      precioUnitario:
      ((json['precioUnitario'] ?? json['PrecioUnitario']) as num)
          .toDouble(),
      subtotal: ((json['subtotal'] ?? json['Subtotal']) as num).toDouble(),
    );
  }
}
