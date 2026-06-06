using Microsoft.EntityFrameworkCore;
using PosApi.Models;

namespace PosApi.Data;

public class PosDbContext : DbContext
{
    public PosDbContext(DbContextOptions<PosDbContext> options) : base(options) { }

    public DbSet<Usuario> Usuarios => Set<Usuario>();
    public DbSet<Producto> Productos => Set<Producto>();
    public DbSet<Venta> Ventas => Set<Venta>();
    public DbSet<DetalleVenta> DetallesVenta => Set<DetalleVenta>();
    public DbSet<Categoria> Categorias => Set<Categoria>();   // 👈

    protected override void OnModelCreating(ModelBuilder modelBuilder)
    {
        // ===== CATEGORIA =====
        modelBuilder.Entity<Categoria>(entity =>
        {
            entity.ToTable("Categorias");
            entity.HasKey(c => c.IdCategoria);
        });

        // ===== PRODUCTO =====
        modelBuilder.Entity<Producto>(entity =>
        {
            entity.ToTable("Productos");
            entity.HasKey(p => p.IdProducto);

            // 👇 AQUÍ le decimos que la FK es IdCategoria (no CategoriaIdCategoria)
            entity.HasOne(p => p.Categoria)
                  .WithMany(c => c.Productos)
                  .HasForeignKey(p => p.IdCategoria);
        });

        // ===== USUARIO – VENTAS =====
        modelBuilder.Entity<Usuario>()
            .HasMany(u => u.Ventas)
            .WithOne(v => v.Usuario)
            .HasForeignKey(v => v.IdUsuario);

        // ===== VENTA – DETALLES =====
        modelBuilder.Entity<DetalleVenta>()
            .HasOne(d => d.Venta)
            .WithMany(v => v.Detalles)
            .HasForeignKey(d => d.IdVenta);

        // ===== PRODUCTO – DETALLES =====
        modelBuilder.Entity<DetalleVenta>()
            .HasOne(d => d.Producto)
            .WithMany(p => p.Detalles)
            .HasForeignKey(d => d.IdProducto);

        base.OnModelCreating(modelBuilder);
    }
}
