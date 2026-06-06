using PosApi.DTOs;

public class RespuestaVentaDto
{
    public int IdVenta { get; set; }
    public DateTime FechaHora { get; set; }
    public decimal Total { get; set; }
    public decimal Cambio { get; set; }
    public int IdUsuario { get; set; }

    public string NombreUsuario { get; set; } = string.Empty;

    public List<DetalleVentaDto> Detalles { get; set; } = new();
}
