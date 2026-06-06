using Microsoft.AspNetCore.Mvc;
using PosApi.DTOs;
using PosApi.Services;

namespace PosApi.Controllers
{
    [ApiController]
    [Route("api/[controller]")]
    public class AuthController : ControllerBase
    {
        private readonly IUsuarioService _usuarioService;

        public AuthController(IUsuarioService usuarioService)
        {
            _usuarioService = usuarioService;
        }

        [HttpPost("login")]
        public async Task<ActionResult<LoginResponseDto>> Login([FromBody] LoginRequestDto request)
        {
            if (string.IsNullOrWhiteSpace(request.Usuario) || string.IsNullOrWhiteSpace(request.Password))
            {
                return BadRequest(new LoginResponseDto
                {
                    Exito = false,
                    Mensaje = "Usuario y contraseña son requeridos."
                });
            }

            var usuario = await _usuarioService.LoginAsync(request.Usuario, request.Password);

            if (usuario == null)
            {
                return Unauthorized(new LoginResponseDto
                {
                    Exito = false,
                    Mensaje = "Usuario o contraseña incorrectos."
                });
            }

            return Ok(new LoginResponseDto
            {
                Exito = true,
                Usuario = usuario
            });
        }
    }
}
