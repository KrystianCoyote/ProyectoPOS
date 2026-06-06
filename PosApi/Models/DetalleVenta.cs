using System.ComponentModel.DataAnnotations;

namespace PosApi.Models;

public class DetalleVenta
{
    [Key]                          // 👈 PK
    public int IdDetalle { get; set; }

    public int IdVenta { get; set; }
    public Venta Venta { get; set; } = null!;

    public int IdProducto { get; set; }
    public Producto Producto { get; set; } = null!;

    public int Cantidad { get; set; }
    public decimal PrecioUnitario { get; set; }
    public decimal Subtotal { get; set; }
}
