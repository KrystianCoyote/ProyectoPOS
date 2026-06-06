// PosApi/Services/ProductoService.cs
using PosApi.DTOs;
using PosApi.Models;
using PosApi.Repositories;

namespace PosApi.Services;

public class ProductoService : IProductoService
{
    private readonly IProductoRepository _repo;

    public ProductoService(IProductoRepository repo)
    {
        _repo = repo;
    }

    // =========================
    // GET ALL
    // =========================
    public async Task<List<ProductoDto>> GetAllAsync()
    {
        var productos = await _repo.GetAllAsync();
        return productos.Select(MapToDto).ToList();
    }

    // =========================
    // GET BY ID
    // =========================
    public async Task<ProductoDto?> GetByIdAsync(int id)
    {
        var producto = await _repo.GetByIdAsync(id);
        return producto is null ? null : MapToDto(producto);
    }

    // =========================
    // CREATE
    // =========================
    public async Task<ProductoDto> CreateAsync(ProductoDto dto)
    {
        var fecha = dto.FechaRegistro == default
            ? DateTime.Now
            : dto.FechaRegistro;

        var producto = new Producto
        {
            Nombre = dto.Nombre,
            Precio = dto.Precio,
            FotoUrl = dto.FotoUrl,
            CodigoBarras = dto.CodigoBarras,
            Activo = dto.Activo,
            FechaRegistro = fecha,

            // 👇 NUEVO: categoría
            IdCategoria = dto.IdCategoria
        };

        var creado = await _repo.AddAsync(producto);
        return MapToDto(creado);
    }

    // =========================
    // UPDATE
    // =========================
    public async Task<bool> UpdateAsync(int id, ProductoDto dto)
    {
        var producto = await _repo.GetByIdAsync(id);
        if (producto is null) return false;

        producto.Nombre = dto.Nombre;
        producto.Precio = dto.Precio;
        producto.FotoUrl = dto.FotoUrl;
        producto.CodigoBarras = dto.CodigoBarras;
        producto.Activo = dto.Activo;
        // NO tocamos FechaRegistro

        // 👇 también actualizamos categoría
        producto.IdCategoria = dto.IdCategoria;

        await _repo.UpdateAsync(producto);
        return true;
    }

    // =========================
    // DELETE
    // =========================
    public async Task<bool> DeleteAsync(int id)
    {
        var producto = await _repo.GetByIdAsync(id);
        if (producto is null) return false;

        await _repo.DeleteAsync(producto);
        return true;
    }

    // =========================
    // INACTIVOS
    // =========================
    public async Task<List<ProductoDto>> GetInactivosAsync()
    {
        var productos = await _repo.GetInactivosAsync();
        return productos.Select(MapToDto).ToList();
    }

    // =========================
    // MAPEO ENTIDAD → DTO
    // =========================
    private static ProductoDto MapToDto(Producto p) => new()
    {
        IdProducto = p.IdProducto,
        Nombre = p.Nombre,
        Precio = p.Precio,
        FotoUrl = p.FotoUrl,
        CodigoBarras = p.CodigoBarras,
        Activo = p.Activo,
        FechaRegistro = p.FechaRegistro,

        // 👇 que el DTO tenga esta propiedad
        IdCategoria = p.IdCategoria
    };
}
