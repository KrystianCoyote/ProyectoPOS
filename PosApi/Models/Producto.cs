using System;
using System.Collections.Generic;

namespace PosApi.Models;

public class Producto
{
    public int IdProducto { get; set; }
    public string Nombre { get; set; } = null!;
    public decimal Precio { get; set; }
    public string? FotoUrl { get; set; }
    public bool Activo { get; set; }
    public DateTime FechaRegistro { get; set; }
    public string? CodigoBarras { get; set; }

    // 👇 ESTA es la FK REAL hacia Categorias (columna que queremos en la BD)
    public int? IdCategoria { get; set; }

    // Navegación (opcional, pero útil para después)
    public Categoria? Categoria { get; set; }

    public List<DetalleVenta> Detalles { get; set; } = new();
}
