using Microsoft.EntityFrameworkCore;
using PosApi.Data;
using PosApi.Repositories;
using PosApi.Services;
// using PosApi.Middleware;  // 👈 descomenta si quieres usar tus middlewares personalizados

var builder = WebApplication.CreateBuilder(args);

// ✅ Conexión a MySQL SIN migraciones
builder.Services.AddDbContext<PosDbContext>(options =>
{
    var connectionString = builder.Configuration.GetConnectionString("DefaultConnection");

    options.UseMySql(
        connectionString,
        new MySqlServerVersion(new Version(8, 0, 36)) // tu versión de MySQL
    );
});

// ✅ REGISTRO DE REPOSITORIOS (capa de acceso a datos)
builder.Services.AddScoped<IProductoRepository, ProductoRepository>();
builder.Services.AddScoped<IUsuarioRepository, UsuarioRepository>();
builder.Services.AddScoped<IVentaRepository, VentaRepository>();

// ✅ REGISTRO DE SERVICIOS (lógica de negocio)
builder.Services.AddScoped<IProductoService, ProductoService>();
builder.Services.AddScoped<IUsuarioService, UsuarioService>();
builder.Services.AddScoped<IVentaService, VentaService>();
builder.Services.AddScoped<ICategoriaService, CategoriaService>();

// ✅ Controladores (API)
builder.Services.AddControllers();
// builder.Services.AddEndpointsApiExplorer(); // opcional, puedes dejarlo comentado si no usas Swagger

var app = builder.Build();

// 👉 Si quieres usar tus middlewares personalizados, descomenta:
// app.UseMiddleware<RequestLoggingMiddleware>();
// app.UseMiddleware<ErrorHandlingMiddleware>();

// app.UseHttpsRedirection();

app.UseStaticFiles();

app.MapControllers();

app.Urls.Add("http://0.0.0.0:5271");

app.Run();
