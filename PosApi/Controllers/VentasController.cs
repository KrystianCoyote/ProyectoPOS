// PosApi/Controllers/VentasController.cs
using Microsoft.AspNetCore.Mvc;
using PosApi.DTOs;
using PosApi.Services;

namespace PosApi.Controllers;

[ApiController]
[Route("api/[controller]")]
public class VentasController : ControllerBase
{
    private readonly IVentaService _ventaService;

    public VentasController(IVentaService ventaService)
    {
        _ventaService = ventaService;
    }

    // GET: api/ventas?desde=...&hasta=...&idUsuario=...
    [HttpGet]
    public async Task<ActionResult<List<RespuestaVentaDto>>> Get(
        [FromQuery] DateTime? desde,
        [FromQuery] DateTime? hasta,
        [FromQuery] int? idUsuario)
    {
        var ventas = await _ventaService.ObtenerVentasAsync(desde, hasta, idUsuario);
        return Ok(ventas);
    }

    // GET: api/ventas/5
    [HttpGet("{id:int}")]
    public async Task<ActionResult<RespuestaVentaDto>> GetById(int id)
    {
        var venta = await _ventaService.ObtenerVentaPorIdAsync(id);
        if (venta == null) return NotFound();
        return Ok(venta);
    }

    // POST: api/ventas
    [HttpPost]
    public async Task<ActionResult<RespuestaVentaDto>> Post([FromBody] CrearVentaDto dto)
    {
        var venta = await _ventaService.CrearVentaAsync(dto);
        return CreatedAtAction(nameof(GetById), new { id = venta.IdVenta }, venta);
    }

    // GET: api/ventas/corte?desde=...&hasta=...&idUsuario=...
    [HttpGet("corte")]
    public async Task<ActionResult<CorteCajaDto>> ObtenerCorte(
        [FromQuery] DateTime desde,
        [FromQuery] DateTime hasta,
        [FromQuery] int? idUsuario)
    {
        var corte = await _ventaService.ObtenerCorteCajaAsync(desde, hasta, idUsuario);
        return Ok(corte);
    }
}
