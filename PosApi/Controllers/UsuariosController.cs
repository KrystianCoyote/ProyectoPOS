using Microsoft.AspNetCore.Mvc;
using PosApi.DTOs;
using PosApi.Services;

namespace PosApi.Controllers
{
    [ApiController]
    [Route("api/[controller]")]
    public class UsuariosController : ControllerBase
    {
        private readonly IUsuarioService _usuarioService;

        public UsuariosController(IUsuarioService usuarioService)
        {
            _usuarioService = usuarioService;
        }

        [HttpGet]
        public async Task<ActionResult<List<UsuarioDto>>> GetAll()
        {
            var usuarios = await _usuarioService.GetAllAsync();
            return Ok(usuarios);
        }

        [HttpGet("{id}")]
        public async Task<ActionResult<UsuarioDto>> GetById(int id)
        {
            var usuario = await _usuarioService.GetByIdAsync(id);
            if (usuario == null)
                return NotFound();

            return Ok(usuario);
        }

        [HttpPost]
        public async Task<ActionResult<UsuarioDto>> Create([FromBody] UsuarioDto dto)
        {
            var creado = await _usuarioService.CreateAsync(dto);
            return CreatedAtAction(nameof(GetById), new { id = creado.IdUsuario }, creado);
        }

        [HttpPut("{id}")]
        public async Task<ActionResult<UsuarioDto>> Update(int id, [FromBody] UsuarioDto dto)
        {
            var actualizado = await _usuarioService.UpdateAsync(id, dto);
            return Ok(actualizado);
        }
    }
}
