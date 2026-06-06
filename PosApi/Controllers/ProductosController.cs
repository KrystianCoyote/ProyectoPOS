using Microsoft.AspNetCore.Mvc;
using PosApi.DTOs;
using PosApi.Services;

namespace PosApi.Controllers;

[ApiController]
[Route("api/[controller]")]
public class ProductosController : ControllerBase
{
    private readonly IProductoService _service;
    private readonly IWebHostEnvironment _env;

    public ProductosController(IProductoService service, IWebHostEnvironment env)
    {
        _service = service;
        _env = env;
    }

    // ======================
    // GET: api/productos
    // ======================
    [HttpGet]
    public async Task<ActionResult<List<ProductoDto>>> GetAll()
    {
        var productos = await _service.GetAllAsync();
        return Ok(productos);
    }

    // ======================
    // GET: api/productos/inactivos
    // ======================
    [HttpGet("inactivos")]
    public async Task<ActionResult<List<ProductoDto>>> GetInactivos()
    {
        var productos = await _service.GetInactivosAsync();
        return Ok(productos);
    }

    // ======================
    // GET: api/productos/5
    // ======================
    [HttpGet("{id:int}")]
    public async Task<ActionResult<ProductoDto>> GetById(int id)
    {
        var producto = await _service.GetByIdAsync(id);
        if (producto is null) return NotFound();
        return Ok(producto);
    }

    // ======================
    // POST: api/productos  (JSON normal)
    // ======================
    [HttpPost]
    public async Task<ActionResult<ProductoDto>> Create([FromBody] ProductoDto dto)
    {
        var created = await _service.CreateAsync(dto);
        return CreatedAtAction(nameof(GetById), new { id = created.IdProducto }, created);
    }

    // ======================
    // PUT: api/productos/5  (JSON normal)
    // ======================
    [HttpPut("{id:int}")]
    public async Task<IActionResult> Update(int id, [FromBody] ProductoDto dto)
    {
        var ok = await _service.UpdateAsync(id, dto);
        if (!ok) return NotFound();
        return NoContent();
    }

    // ======================
    // DELETE: api/productos/5
    // ======================
    [HttpDelete("{id:int}")]
    public async Task<IActionResult> Delete(int id)
    {
        var ok = await _service.DeleteAsync(id);
        if (!ok) return NotFound();
        return NoContent();
    }

    // ==========================================================
    // Helper: guardar imagen en disco
    // ==========================================================
    private string? GuardarImagen(IFormFile? foto)
    {
        if (foto == null || foto.Length == 0) return null;

        var webRoot = _env.WebRootPath;
        if (string.IsNullOrEmpty(webRoot))
        {
            webRoot = Path.Combine(Directory.GetCurrentDirectory(), "wwwroot");
        }

        var carpetaImagenes = Path.Combine(webRoot, "imagenes");

        if (!Directory.Exists(carpetaImagenes))
        {
            Directory.CreateDirectory(carpetaImagenes);
        }

        var extension = Path.GetExtension(foto.FileName);
        var fileName = $"{Guid.NewGuid()}{extension}";
        var rutaFisica = Path.Combine(carpetaImagenes, fileName);

        using (var stream = System.IO.File.Create(rutaFisica))
        {
            foto.CopyTo(stream);
        }

        // Ruta relativa para Flutter
        return $"/imagenes/{fileName}";
    }

    // ==========================================================
    // POST api/productos/con-foto
    //     nombre, precio, codigoBarras?, idCategoria?, foto
    // ==========================================================
    [HttpPost("con-foto")]
    public async Task<ActionResult<ProductoDto>> CreateConFoto(
        [FromForm] string nombre,
        [FromForm] decimal precio,
        [FromForm] string? codigoBarras,
        [FromForm] int? idCategoria,
        [FromForm] IFormFile? foto)
    {
        var fotoUrl = GuardarImagen(foto);

        var dto = new ProductoDto
        {
            Nombre = nombre,
            Precio = precio,
            FotoUrl = fotoUrl,
            CodigoBarras = codigoBarras,
            IdCategoria = idCategoria,
            Activo = true
        };

        var creado = await _service.CreateAsync(dto);
        return CreatedAtAction(nameof(GetById), new { id = creado.IdProducto }, creado);
    }

    // ==========================================================
    // PUT api/productos/{id}/con-foto
    //     Actualizar datos + (opcional) nueva foto
    // ==========================================================
    [HttpPut("{id:int}/con-foto")]
    public async Task<IActionResult> UpdateConFoto(
        int id,
        [FromForm] string nombre,
        [FromForm] decimal precio,
        [FromForm] string? codigoBarras,
        [FromForm] int? idCategoria,
        [FromForm] IFormFile? foto)
    {
        var actual = await _service.GetByIdAsync(id);
        if (actual is null) return NotFound();

        string? fotoUrl = actual.FotoUrl;

        if (foto != null && foto.Length > 0)
        {
            fotoUrl = GuardarImagen(foto);
        }

        var dto = new ProductoDto
        {
            IdProducto = id,
            Nombre = nombre,
            Precio = precio,
            FotoUrl = fotoUrl,
            CodigoBarras = string.IsNullOrWhiteSpace(codigoBarras)
                ? actual.CodigoBarras
                : codigoBarras,
            IdCategoria = idCategoria ?? actual.IdCategoria,
            Activo = actual.Activo,
            FechaRegistro = actual.FechaRegistro
        };

        var ok = await _service.UpdateAsync(id, dto);
        if (!ok) return NotFound();

        return NoContent();
    }
}
