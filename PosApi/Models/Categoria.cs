namespace PosApi.Models;

public class Categoria
{
    public int IdCategoria { get; set; }
    public string Nombre { get; set; } = null!;
    public bool Activo { get; set; }
    public DateTime FechaRegistro { get; set; }

    public List<Producto> Productos { get; set; } = new();
}
