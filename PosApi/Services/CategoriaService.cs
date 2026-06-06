using MySqlConnector;
using PosApi.DTOs;

namespace PosApi.Services
{
    public interface ICategoriaService
    {
        Task<List<CategoriaDto>> GetAllAsync();
        Task<CategoriaDto?> GetByIdAsync(int id);
        Task<CategoriaDto> CreateAsync(CategoriaDto dto);
        Task<bool> UpdateAsync(int id, CategoriaDto dto);
        Task<bool> DeleteAsync(int id);
    }

    public class CategoriaService : ICategoriaService
    {
        private readonly string _connectionString;

        public CategoriaService(IConfiguration config)
        {
            _connectionString = config.GetConnectionString("DefaultConnection")
                ?? throw new Exception("Falta cadena de conexión 'DefaultConnection'");
        }

        private MySqlConnection GetConnection()
            => new MySqlConnection(_connectionString);

        // --------------------- GET ALL ---------------------
        public async Task<List<CategoriaDto>> GetAllAsync()
        {
            var lista = new List<CategoriaDto>();

            using var conn = GetConnection();
            await conn.OpenAsync();

            var cmd = new MySqlCommand(@"
                SELECT IdCategoria, Nombre, Activo
                FROM Categorias;
            ", conn);

            using var reader = await cmd.ExecuteReaderAsync();
            while (await reader.ReadAsync())
            {
                lista.Add(new CategoriaDto
                {
                    IdCategoria = reader.GetInt32("IdCategoria"),
                    Nombre = reader.GetString("Nombre"),
                    Activo = reader.GetBoolean("Activo")
                });
            }

            return lista;
        }

        // --------------------- GET BY ID -------------------
        public async Task<CategoriaDto?> GetByIdAsync(int id)
        {
            using var conn = GetConnection();
            await conn.OpenAsync();

            var cmd = new MySqlCommand(@"
                SELECT IdCategoria, Nombre, Activo
                FROM Categorias
                WHERE IdCategoria = @id;
            ", conn);

            cmd.Parameters.AddWithValue("@id", id);

            using var reader = await cmd.ExecuteReaderAsync();
            if (await reader.ReadAsync())
            {
                return new CategoriaDto
                {
                    IdCategoria = reader.GetInt32("IdCategoria"),
                    Nombre = reader.GetString("Nombre"),
                    Activo = reader.GetBoolean("Activo")
                };
            }

            return null;
        }

        // --------------------- CREATE ----------------------
        public async Task<CategoriaDto> CreateAsync(CategoriaDto dto)
        {
            using var conn = GetConnection();
            await conn.OpenAsync();

            var cmd = new MySqlCommand(@"
                INSERT INTO Categorias (Nombre, Activo, FechaRegistro)
                VALUES (@nombre, @activo, NOW());
                SELECT LAST_INSERT_ID();
            ", conn);

            cmd.Parameters.AddWithValue("@nombre", dto.Nombre);
            cmd.Parameters.AddWithValue("@activo", dto.Activo);

            var id = Convert.ToInt32(await cmd.ExecuteScalarAsync());
            dto.IdCategoria = id;

            return dto;
        }

        // --------------------- UPDATE ----------------------
        public async Task<bool> UpdateAsync(int id, CategoriaDto dto)
        {
            using var conn = GetConnection();
            await conn.OpenAsync();

            var cmd = new MySqlCommand(@"
                UPDATE Categorias
                SET Nombre = @nombre,
                    Activo = @activo
                WHERE IdCategoria = @id;
            ", conn);

            cmd.Parameters.AddWithValue("@id", id);
            cmd.Parameters.AddWithValue("@nombre", dto.Nombre);
            cmd.Parameters.AddWithValue("@activo", dto.Activo);

            var rows = await cmd.ExecuteNonQueryAsync();
            return rows > 0;
        }

        // --------------------- DELETE ----------------------
        public async Task<bool> DeleteAsync(int id)
        {
            using var conn = GetConnection();
            await conn.OpenAsync();

            var cmd = new MySqlCommand(@"
                DELETE FROM Categorias
                WHERE IdCategoria = @id;
            ", conn);

            cmd.Parameters.AddWithValue("@id", id);

            var rows = await cmd.ExecuteNonQueryAsync();
            return rows > 0;
        }
    }
}
