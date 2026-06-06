// PosApi/Services/IProductoService.cs
using PosApi.DTOs;

namespace PosApi.Services;

public interface IProductoService
{
    Task<List<ProductoDto>> GetAllAsync();
    Task<ProductoDto?> GetByIdAsync(int id);
    Task<ProductoDto> CreateAsync(ProductoDto dto);
    Task<bool> UpdateAsync(int id, ProductoDto dto);
    Task<bool> DeleteAsync(int id);

    // 👇 NUEVO
    Task<List<ProductoDto>> GetInactivosAsync();
}
