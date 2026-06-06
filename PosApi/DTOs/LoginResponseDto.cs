namespace PosApi.DTOs
{
    public class LoginResponseDto
    {
        public bool Exito { get; set; }
        public string? Mensaje { get; set; }
        public UsuarioDto? Usuario { get; set; }
    }
}
