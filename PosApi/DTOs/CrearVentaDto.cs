// PosApi/DTOs/CrearVentaDto.cs
using System.Text.Json.Serialization;

namespace PosApi.DTOs;

public class CrearVentaDto
{
    [JsonPropertyName("idUsuario")]
    public int IdUsuario { get; set; }

    [JsonPropertyName("montoRecibido")]
    public decimal MontoRecibido { get; set; }

    [JsonPropertyName("productos")]
    public List<CrearVentaProductoDto> Productos { get; set; } = new();
}

public class CrearVentaProductoDto
{
    [JsonPropertyName("idProducto")]
    public int IdProducto { get; set; }

    [JsonPropertyName("cantidad")]
    public int Cantidad { get; set; }

    // 👇 nuevo: viene desde Flutter
    [JsonPropertyName("precioUnitario")]
    public decimal? PrecioUnitario { get; set; }
}
