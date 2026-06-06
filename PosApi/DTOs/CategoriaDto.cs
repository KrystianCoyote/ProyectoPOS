// DTOs/CategoriaDto.cs
namespace PosApi.DTOs
{
    public class CategoriaDto
    {
        public int IdCategoria { get; set; }
        public string Nombre { get; set; } = string.Empty;
        public bool Activo { get; set; } = true;
    }
}
