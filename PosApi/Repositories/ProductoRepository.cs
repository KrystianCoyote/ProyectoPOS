// PosApi/Repositories/ProductoRepository.cs
using Microsoft.EntityFrameworkCore;
using PosApi.Data;
using PosApi.Models;

namespace PosApi.Repositories;

public class ProductoRepository : IProductoRepository
{
    private readonly PosDbContext _context;

    public ProductoRepository(PosDbContext context)
    {
        _context = context;
    }

    public async Task<List<Producto>> GetAllAsync()
        => await _context.Productos
            .Where(p => p.Activo)
            .ToListAsync();

    public async Task<Producto?> GetByIdAsync(int id)
        => await _context.Productos
            .FirstOrDefaultAsync(p => p.IdProducto == id);

    public async Task<Producto> AddAsync(Producto producto)
    {
        _context.Productos.Add(producto);
        await _context.SaveChangesAsync();
        return producto;
    }

    public async Task UpdateAsync(Producto producto)
    {
        _context.Productos.Update(producto);
        await _context.SaveChangesAsync();
    }

    public async Task DeleteAsync(Producto producto)
    {
        // baja lógica
        producto.Activo = false;
        await _context.SaveChangesAsync();
    }

    // 👇 NUEVO: obtener solo inactivos
    public async Task<List<Producto>> GetInactivosAsync()
        => await _context.Productos
            .Where(p => !p.Activo)
            .ToListAsync();
}
