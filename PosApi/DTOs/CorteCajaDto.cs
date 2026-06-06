// PosApi/DTOs/CorteCajaDto.cs
using System;

namespace PosApi.DTOs;

public class CorteCajaDto
{
    public DateTime Desde { get; set; }
    public DateTime Hasta { get; set; }
    public string Usuario { get; set; } = string.Empty;
    public int TotalTickets { get; set; }
    public decimal TotalVendido { get; set; }
    public decimal VentaPromedio { get; set; }
}
