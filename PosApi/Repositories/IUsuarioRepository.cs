using PosApi.Models;

namespace PosApi.Repositories
{
    public interface IUsuarioRepository
    {
        Task<Usuario?> GetByIdAsync(int id);
        Task<List<Usuario>> GetAllAsync();
        Task AddAsync(Usuario usuario);
        Task UpdateAsync(Usuario usuario);

        // Para login
        Task<Usuario?> GetByLoginAsync(string usuarioLogin, string password);
    }
}
