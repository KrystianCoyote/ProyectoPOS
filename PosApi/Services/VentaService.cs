// PosApi/Services/VentaService.cs
using PosApi.DTOs;
using PosApi.Models;
using PosApi.Repositories;

namespace PosApi.Services;

public class VentaService : IVentaService
{
    private readonly IVentaRepository _ventaRepository;
    private readonly IProductoRepository _productoRepository;
    private readonly IUsuarioRepository _usuarioRepository;

    public VentaService(
        IVentaRepository ventaRepository,
        IProductoRepository productoRepository,
        IUsuarioRepository usuarioRepository)
    {
        _ventaRepository = ventaRepository;
        _productoRepository = productoRepository;
        _usuarioRepository = usuarioRepository;
    }

    // ============================
    //  CREAR VENTA
    // ============================
    public async Task<RespuestaVentaDto> CrearVentaAsync(CrearVentaDto dto)
    {
        // Validar usuario
        var usuario = await _usuarioRepository.GetByIdAsync(dto.IdUsuario);
        if (usuario == null)
        {
            throw new InvalidOperationException("Usuario no encontrado");
        }

        if (dto.Productos == null || dto.Productos.Count == 0)
        {
            throw new InvalidOperationException("La venta debe tener al menos un producto.");
        }

        var detalles = new List<DetalleVenta>();
        decimal total = 0;

        foreach (var p in dto.Productos)
        {
            var prod = await _productoRepository.GetByIdAsync(p.IdProducto);
            if (prod == null)
            {
                throw new InvalidOperationException($"Producto {p.IdProducto} no encontrado.");
            }

            // 👇 si Flutter manda precioUnitario (por tamaño), lo usamos;
            // si viene nulo o <= 0, usamos el precio del producto en BD.
            decimal precioUnitario = (p.PrecioUnitario.HasValue && p.PrecioUnitario.Value > 0)
                ? p.PrecioUnitario.Value
                : prod.Precio;

            var subtotal = precioUnitario * p.Cantidad;
            total += subtotal;

            detalles.Add(new DetalleVenta
            {
                IdProducto = prod.IdProducto,
                Cantidad = p.Cantidad,
                PrecioUnitario = precioUnitario,
                Subtotal = subtotal
            });
        }

        if (dto.MontoRecibido < total)
        {
            throw new InvalidOperationException("El monto recibido es menor al total.");
        }

        var venta = new Venta
        {
            FechaHora = DateTime.Now,
            IdUsuario = usuario.IdUsuario,
            Total = total,
            MontoRecibido = dto.MontoRecibido,
            Cambio = dto.MontoRecibido - total,
            Detalles = detalles
        };

        await _ventaRepository.AddAsync(venta);

        var ventaGuardada = await _ventaRepository.GetByIdAsync(venta.IdVenta)
                             ?? throw new InvalidOperationException("No se pudo recargar la venta guardada.");

        return MapToDto(ventaGuardada);
    }

    // ============================
    //  HISTORIAL / LISTA
    // ============================
    public async Task<List<RespuestaVentaDto>> ObtenerVentasAsync(
        DateTime? desde,
        DateTime? hasta,
        int? idUsuario)
    {
        var hoy = DateTime.Now;
        var d = desde ?? hoy.Date;
        var h = hasta ?? hoy.Date.AddDays(1).AddTicks(-1);

        var ventas = await _ventaRepository.GetByRangeAsync(d, h, idUsuario);
        return ventas.Select(MapToDto).ToList();
    }

    // ============================
    //  OBTENER POR ID
    // ============================
    public async Task<RespuestaVentaDto?> ObtenerVentaPorIdAsync(int id)
    {
        var venta = await _ventaRepository.GetByIdAsync(id);
        return venta == null ? null : MapToDto(venta);
    }

    // ============================
    //  CORTE DE CAJA
    // ============================
    public Task<CorteCajaDto> ObtenerCorteCajaAsync(
        DateTime desde,
        DateTime hasta,
        int? idUsuario)
        => _ventaRepository.ObtenerCorteCajaAsync(desde, hasta, idUsuario);

    // ============================
    //  MAPPER
    // ============================
    private static RespuestaVentaDto MapToDto(Venta venta)
    {
        return new RespuestaVentaDto
        {
            IdVenta = venta.IdVenta,
            FechaHora = venta.FechaHora,
            Total = venta.Total,
            Cambio = venta.Cambio,
            IdUsuario = venta.IdUsuario,

            // 👇 Nombre REAL del cajero, NO usuarioLogin, NO IdUsuario
            NombreUsuario = venta.Usuario?.Nombre ?? "Desconocido",

            Detalles = venta.Detalles.Select(d => new DetalleVentaDto
            {
                IdProducto = d.IdProducto,
                Nombre = d.Producto.Nombre,
                Cantidad = d.Cantidad,
                PrecioUnitario = d.PrecioUnitario,
                Subtotal = d.Subtotal
            }).ToList()
        };
    }
}
