// PosApi/Repositories/VentaRepository.cs
using Microsoft.EntityFrameworkCore;
using PosApi.Data;
using PosApi.DTOs;
using PosApi.Models;

namespace PosApi.Repositories;

public class VentaRepository : IVentaRepository
{
    private readonly PosDbContext _context;

    public VentaRepository(PosDbContext context)
    {
        _context = context;
    }

    public async Task<Venta> AddAsync(Venta venta)
    {
        _context.Ventas.Add(venta);
        await _context.SaveChangesAsync();
        return venta;
    }

    public async Task<Venta?> GetByIdAsync(int id)
    {
        return await _context.Ventas
            .Include(v => v.Usuario)
            .Include(v => v.Detalles)
                .ThenInclude(d => d.Producto)
            .FirstOrDefaultAsync(v => v.IdVenta == id);
    }

    public async Task<List<Venta>> GetByRangeAsync(DateTime desde, DateTime hasta, int? idUsuario = null)
    {
        var query = _context.Ventas
            .Include(v => v.Usuario)
            .Include(v => v.Detalles)
                .ThenInclude(d => d.Producto)
            .Where(v => v.FechaHora >= desde && v.FechaHora <= hasta)
            .AsQueryable();

        if (idUsuario.HasValue)
        {
            query = query.Where(v => v.IdUsuario == idUsuario.Value);
        }

        return await query
            .OrderBy(v => v.FechaHora)
            .ToListAsync();
    }

    public async Task<CorteCajaDto> ObtenerCorteCajaAsync(DateTime desde, DateTime hasta, int? idUsuario = null)
    {
        var ventas = await GetByRangeAsync(desde, hasta, idUsuario);

        if (ventas.Count == 0)
        {
            return new CorteCajaDto
            {
                Desde = desde,
                Hasta = hasta,
                Usuario = idUsuario.HasValue ? string.Empty : "Todos",
                TotalTickets = 0,
                TotalVendido = 0,
                VentaPromedio = 0
            };
        }

        var totalVendido = ventas.Sum(v => v.Total);
        var totalTickets = ventas.Count;
        var usuarioNombre = idUsuario.HasValue
        ? ventas.First().Usuario.UsuarioLogin   // 👈 propiedad real del modelo
    :   "Todos";


        return new CorteCajaDto
        {
            Desde = desde,
            Hasta = hasta,
            Usuario = usuarioNombre,
            TotalTickets = totalTickets,
            TotalVendido = totalVendido,
            VentaPromedio = totalTickets > 0 ? totalVendido / totalTickets : 0
        };
    }
}
