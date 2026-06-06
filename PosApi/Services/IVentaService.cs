// PosApi/Services/IVentaService.cs
using PosApi.DTOs;

namespace PosApi.Services;

public interface IVentaService
{
    Task<RespuestaVentaDto> CrearVentaAsync(CrearVentaDto dto);

    Task<List<RespuestaVentaDto>> ObtenerVentasAsync(
        DateTime? desde,
        DateTime? hasta,
        int? idUsuario);

    Task<RespuestaVentaDto?> ObtenerVentaPorIdAsync(int id);

    Task<CorteCajaDto> ObtenerCorteCajaAsync(
        DateTime desde,
        DateTime hasta,
        int? idUsuario);
}
