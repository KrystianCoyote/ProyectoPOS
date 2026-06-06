namespace PosApi.DTOs;

public class DetalleVentaDto
{
    public int IdProducto { get; set; }
    public string Nombre { get; set; } = null!;
    public int Cantidad { get; set; }
    public decimal PrecioUnitario { get; set; }
    public decimal Subtotal { get; set; }
}
