using PosApi.DTOs;
using PosApi.Models;
using PosApi.Repositories;

namespace PosApi.Services
{
    public class UsuarioService : IUsuarioService
    {
        private readonly IUsuarioRepository _usuarioRepository;

        public UsuarioService(IUsuarioRepository usuarioRepository)
        {
            _usuarioRepository = usuarioRepository;
        }

        public async Task<UsuarioDto?> GetByIdAsync(int id)
        {
            var usuario = await _usuarioRepository.GetByIdAsync(id);
            return usuario == null ? null : MapToDto(usuario);
        }

        public async Task<List<UsuarioDto>> GetAllAsync()
        {
            var usuarios = await _usuarioRepository.GetAllAsync();
            return usuarios.Select(MapToDto).ToList();
        }

        public async Task<UsuarioDto> CreateAsync(UsuarioDto dto)
        {
            var usuario = new Usuario
            {
                Nombre = dto.Nombre,
                UsuarioLogin = dto.UsuarioLogin,
                Rol = dto.Rol,
                Activo = dto.Activo,
                FechaAlta = dto.FechaAlta,
                PasswordHash = dto.Password ?? "1234"
            };

            await _usuarioRepository.AddAsync(usuario);
            return MapToDto(usuario);
        }

        public async Task<UsuarioDto> UpdateAsync(int id, UsuarioDto dto)
        {
            var usuario = await _usuarioRepository.GetByIdAsync(id)
                ?? throw new Exception("Usuario no encontrado");

            usuario.Nombre = dto.Nombre;
            usuario.UsuarioLogin = dto.UsuarioLogin;
            usuario.Rol = dto.Rol;
            usuario.Activo = dto.Activo;
            usuario.FechaAlta = dto.FechaAlta;

            if (!string.IsNullOrWhiteSpace(dto.Password))
            {
                usuario.PasswordHash = dto.Password;
            }

            await _usuarioRepository.UpdateAsync(usuario);
            return MapToDto(usuario);
        }

        public async Task<UsuarioDto?> LoginAsync(string usuario, string password)
        {
            var entidad = await _usuarioRepository.GetByLoginAsync(usuario, password);
            return entidad == null ? null : MapToDto(entidad);
        }

        private static UsuarioDto MapToDto(Usuario u)
        {
            return new UsuarioDto
            {
                IdUsuario = u.IdUsuario,
                Nombre = u.Nombre,
                UsuarioLogin = u.UsuarioLogin,
                Rol = u.Rol,
                Activo = u.Activo,
                FechaAlta = u.FechaAlta,
                Password = null // nunca devolvemos el password
            };
        }
    }
}
