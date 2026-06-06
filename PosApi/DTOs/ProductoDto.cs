public class ProductoDto
{
    public int IdProducto { get; set; }
    public string Nombre { get; set; } = null!;
    public decimal Precio { get; set; }
    public string? CodigoBarras { get; set; }
    public string? FotoUrl { get; set; }
    public bool Activo { get; set; }
    public DateTime FechaRegistro { get; set; }

    public int? IdCategoria { get; set; }
    public bool UsaTamanos { get; set; }
    public decimal? PrecioChico { get; set; }
    public decimal? PrecioMediano { get; set; }
    public decimal? PrecioGrande { get; set; }
}
