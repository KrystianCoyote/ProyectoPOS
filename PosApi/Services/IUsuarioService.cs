using PosApi.DTOs;

namespace PosApi.Services
{
    public interface IUsuarioService
    {
        Task<UsuarioDto?> GetByIdAsync(int id);
        Task<List<UsuarioDto>> GetAllAsync();
        Task<UsuarioDto> CreateAsync(UsuarioDto dto);
        Task<UsuarioDto> UpdateAsync(int id, UsuarioDto dto);

        // Para login
        Task<UsuarioDto?> LoginAsync(string usuario, string password);
    }
}
