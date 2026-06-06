using Microsoft.AspNetCore.Mvc;
using PosApi.DTOs;
using PosApi.Services;

namespace PosApi.Controllers;

[ApiController]
[Route("api/[controller]")]
public class CategoriasController : ControllerBase
{
    private readonly ICategoriaService _service;

    public CategoriasController(ICategoriaService service)
    {
        _service = service;
    }

    // GET: api/categorias
    [HttpGet]
    public async Task<ActionResult<List<CategoriaDto>>> GetAll()
    {
        var categorias = await _service.GetAllAsync();
        return Ok(categorias);
    }

    // GET: api/categorias/5
    [HttpGet("{id:int}")]
    public async Task<ActionResult<CategoriaDto>> GetById(int id)
    {
        var cat = await _service.GetByIdAsync(id);
        if (cat == null) return NotFound();
        return Ok(cat);
    }
}
