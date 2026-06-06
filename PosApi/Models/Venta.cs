using System.ComponentModel.DataAnnotations;

namespace PosApi.Models;

public class Venta
{
    [Key]                          // 👈 PK
    public int IdVenta { get; set; }

    public DateTime FechaHora { get; set; }
    public decimal Total { get; set; }
    public decimal MontoRecibido { get; set; }
    public decimal Cambio { get; set; }

    public int IdUsuario { get; set; }
    public Usuario Usuario { get; set; } = null!;

    public ICollection<DetalleVenta> Detalles { get; set; } = new List<DetalleVenta>();
}
