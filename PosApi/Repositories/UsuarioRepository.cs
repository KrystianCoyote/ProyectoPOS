using Microsoft.EntityFrameworkCore;
using PosApi.Data;
using PosApi.Models;

namespace PosApi.Repositories
{
    public class UsuarioRepository : IUsuarioRepository
    {
        private readonly PosDbContext _context;

        public UsuarioRepository(PosDbContext context)
        {
            _context = context;
        }

        public async Task<Usuario?> GetByIdAsync(int id)
        {
            return await _context.Usuarios.FindAsync(id);
        }

        public async Task<List<Usuario>> GetAllAsync()
        {
            return await _context.Usuarios.ToListAsync();
        }

        public async Task AddAsync(Usuario usuario)
        {
            _context.Usuarios.Add(usuario);
            await _context.SaveChangesAsync();
        }

        public async Task UpdateAsync(Usuario usuario)
        {
            _context.Usuarios.Update(usuario);
            await _context.SaveChangesAsync();
        }

        public async Task<Usuario?> GetByLoginAsync(string usuarioLogin, string password)
        {
            // Para proyecto escolar: password en texto plano.
            // En producción se debe usar hashing.
            return await _context.Usuarios
                .FirstOrDefaultAsync(u =>
                    u.UsuarioLogin == usuarioLogin &&
                    u.PasswordHash == password &&
                    u.Activo);
        }
    }
}
