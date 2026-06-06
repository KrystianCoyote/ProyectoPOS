namespace PosApi.DTOs
{
    public class UsuarioDto
    {
        public int IdUsuario { get; set; }

        public string Nombre { get; set; } = string.Empty;

        public string UsuarioLogin { get; set; } = string.Empty;

        public string Rol { get; set; } = "Cajero"; // o Administrador

        public bool Activo { get; set; } = true;

        public DateTime FechaAlta { get; set; } = DateTime.Now;

        // Solo para creación / edición / login
        public string? Password { get; set; }
    }
}
