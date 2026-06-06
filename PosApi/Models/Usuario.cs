using System.ComponentModel.DataAnnotations;

namespace PosApi.Models;

public class Usuario
{
    [Key]                          // 👈 PK
    public int IdUsuario { get; set; }

    public string Nombre { get; set; } = null!;
    public string UsuarioLogin { get; set; } = null!;
    public string PasswordHash { get; set; } = null!;
    public string Rol { get; set; } = null!;
    public bool Activo { get; set; }
    public DateTime FechaAlta { get; set; }

    public ICollection<Venta> Ventas { get; set; } = new List<Venta>();
}
