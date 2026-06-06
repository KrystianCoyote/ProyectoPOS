import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../models/venta.dart';
import '../pages/venta_service.dart';
import '../services/ticket_pdf_service.dart';
import 'package:printing/printing.dart';
import '../config/api_config.dart';

class HistorialVentasPage extends StatefulWidget {
  const HistorialVentasPage({super.key});

  @override
  State<HistorialVentasPage> createState() => _HistorialVentasPageState();
}

class _HistorialVentasPageState extends State<HistorialVentasPage> {
  final _ventaService = VentaService();

  List<Venta> _todas = [];
  List<Venta> _filtradas = [];
  bool _loading = false;
  DateTime _fechaFiltro = DateTime.now();

  final _formatLista = DateFormat('dd/MM/yyyy HH:mm');
  final _formatFechaSolo = DateFormat('dd/MM/yyyy');

  @override
  void initState() {
    super.initState();
    _cargar();
  }

  bool _mismaFecha(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }

  void _aplicarFiltroFecha() {
    setState(() {
      _filtradas = _todas.where((v) {
        final local = v.fechaHora.toLocal();
        return _mismaFecha(local, _fechaFiltro);
      }).toList();
    });
  }

  Future<void> _cargar() async {
    setState(() => _loading = true);
    try {
      final ventas = await _ventaService.obtenerVentas(); // todas
      _todas = ventas;
      _aplicarFiltroFecha();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al cargar ventas: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _loading = false);
      }
    }
  }

  Future<void> _seleccionarFecha() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _fechaFiltro,
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
    );
    if (picked != null) {
      setState(() {
        _fechaFiltro = picked;
      });
      _aplicarFiltroFecha();
    }
  }

  String _formatFechaHora(DateTime fecha) {
    final local = fecha.toLocal();
    return _formatLista.format(local);
  }

  Future<void> _mostrarTicketDialog(Venta venta) async {
    await showDialog(
      context: context,
      builder: (context) {
        final fechaTexto = _formatFechaHora(venta.fechaHora);
        return AlertDialog(
          title: Text('Ticket #${venta.idVenta}'),
          content: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Center(
                  child: Column(
                    children: [
                      Text(
                        fechaTexto,
                        style: const TextStyle(fontSize: 12),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Cajero: ${venta.nombreUsuario}',
                        style: const TextStyle(fontSize: 12),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
                const Divider(),
                const SizedBox(height: 8),
                ...venta.detalles.map(
                      (d) => Padding(
                    padding: const EdgeInsets.only(bottom: 4),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            d.nombre,
                            style: const TextStyle(fontSize: 12),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          '${d.cantidad} x \$${d.precioUnitario.toStringAsFixed(2)}',
                          style: const TextStyle(fontSize: 12),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                const Divider(),
                Align(
                  alignment: Alignment.centerRight,
                  child: Text(
                    'Total: \$${venta.total.toStringAsFixed(2)}',
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              child: const Text('Imprimir / PDF'),
              onPressed: () async {
                final pdfBytes = await TicketPdfService.generarTicketPdf(venta);
                await Printing.layoutPdf(
                  onLayout: (format) async => pdfBytes,
                );
              },
            ),
            TextButton(
              child: const Text('Cerrar'),
              onPressed: () => Navigator.pop(context),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Historial de ventas'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _cargar,
          ),
        ],
      ),
      body: Column(
        children: [
          const SizedBox(height: 8),
          // Filtro por día
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                Expanded(
                  child: TextButton.icon(
                    onPressed: _seleccionarFecha,
                    icon: const Icon(Icons.calendar_today),
                    label: Text(
                      'Día: ${_formatFechaSolo.format(_fechaFiltro)}',
                    ),
                  ),
                ),
                IconButton(
                  tooltip: 'Hoy',
                  onPressed: () {
                    setState(() {
                      _fechaFiltro = DateTime.now();
                    });
                    _aplicarFiltroFecha();
                  },
                  icon: const Icon(Icons.today),
                ),
              ],
            ),
          ),
          const Divider(height: 1),

          Expanded(
            child: _loading
                ? const Center(child: CircularProgressIndicator())
                : _filtradas.isEmpty
                ? const Center(
              child: Text('No hay ventas para este día'),
            )
                : ListView.builder(
              itemCount: _filtradas.length,
              itemBuilder: (context, index) {
                final v = _filtradas[index];
                return Card(
                  margin: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  child: ListTile(
                    title: Text(
                        'Venta #${v.idVenta} - \$${v.total.toStringAsFixed(2)}'),
                    subtitle: Text(
                      '${_formatFechaHora(v.fechaHora)} · Cajero: ${v.nombreUsuario}',
                    ),
                    trailing: IconButton(
                      icon: const Icon(Icons.receipt_long),
                      onPressed: () => _mostrarTicketDialog(v),
                    ),
                    onTap: () => _mostrarTicketDialog(v),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
