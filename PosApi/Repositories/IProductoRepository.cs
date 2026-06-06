// PosApi/Repositories/IProductoRepository.cs
using PosApi.Models;

namespace PosApi.Repositories;

public interface IProductoRepository
{
    Task<List<Producto>> GetAllAsync();
    Task<Producto?> GetByIdAsync(int id);
    Task<Producto> AddAsync(Producto producto);
    Task UpdateAsync(Producto producto);
    Task DeleteAsync(Producto producto);

    // 👇 NUEVO: productos inactivos
    Task<List<Producto>> GetInactivosAsync();
}
