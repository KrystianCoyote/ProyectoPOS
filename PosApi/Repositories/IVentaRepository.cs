// PosApi/Repositories/IVentaRepository.cs
using PosApi.DTOs;
using PosApi.Models;

namespace PosApi.Repositories;

public interface IVentaRepository
{
    Task<Venta> AddAsync(Venta venta);
    Task<Venta?> GetByIdAsync(int id);
    Task<List<Venta>> GetByRangeAsync(DateTime desde, DateTime hasta, int? idUsuario = null);
    Task<CorteCajaDto> ObtenerCorteCajaAsync(DateTime desde, DateTime hasta, int? idUsuario = null);
}
