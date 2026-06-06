// lib/pages/corte_caja_page.dart
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../services/corte_service.dart';
import '../services/corte_pdf_service.dart';

class CorteCajaPage extends StatefulWidget {
  const CorteCajaPage({super.key});

  @override
  State<CorteCajaPage> createState() => _CorteCajaPageState();
}

class _CorteCajaPageState extends State<CorteCajaPage> {
  final _service = CorteService();
  final _pdfService = CortePdfService();

  DateTime _desde = DateTime.now();
  DateTime _hasta = DateTime.now();
  CorteCaja? _corte;
  bool _loading = false;

  final _dateFormat = DateFormat('yyyy-MM-dd');
  final _prettyFormat = DateFormat('dd/MM/yyyy');

  void _setHoy() {
    final hoy = DateTime.now();
    setState(() {
      _desde = DateTime(hoy.year, hoy.month, hoy.day);
      _hasta = DateTime(hoy.year, hoy.month, hoy.day, 23, 59, 59);
    });
    _buscar();
  }

  void _setAyer() {
    final hoy = DateTime.now();
    final ayer = hoy.subtract(const Duration(days: 1));
    setState(() {
      _desde = DateTime(ayer.year, ayer.month, ayer.day);
      _hasta = DateTime(ayer.year, ayer.month, ayer.day, 23, 59, 59);
    });
    _buscar();
  }

  void _setUltimos7Dias() {
    final hoy = DateTime.now();
    final inicio = hoy.subtract(const Duration(days: 6));
    setState(() {
      _desde = DateTime(inicio.year, inicio.month, inicio.day);
      _hasta = DateTime(hoy.year, hoy.month, hoy.day, 23, 59, 59);
    });
    _buscar();
  }

  Future<void> _seleccionarDesde() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _desde,
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
    );
    if (picked != null) {
      setState(() {
        _desde = DateTime(picked.year, picked.month, picked.day);
      });
    }
  }

  Future<void> _seleccionarHasta() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _hasta,
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
    );
    if (picked != null) {
      setState(() {
        _hasta = DateTime(picked.year, picked.month, picked.day, 23, 59, 59);
      });
    }
  }

  Future<void> _buscar() async {
    setState(() {
      _loading = true;
    });

    try {
      final data = await _service.obtenerCorte(
        desde: _desde,
        hasta: _hasta,
      );

      setState(() {
        _corte = data;
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al obtener corte: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _loading = false;
        });
      }
    }
  }

  @override
  void initState() {
    super.initState();
    final hoy = DateTime.now();
    _desde = DateTime(hoy.year, hoy.month, hoy.day);
    _hasta = DateTime(hoy.year, hoy.month, hoy.day, 23, 59, 59);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Corte de caja'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Seleccionar periodo:',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              children: [
                ChoiceChip(
                  label: const Text('Hoy'),
                  selected: false,
                  onSelected: (_) => _setHoy(),
                ),
                ChoiceChip(
                  label: const Text('Ayer'),
                  selected: false,
                  onSelected: (_) => _setAyer(),
                ),
                ChoiceChip(
                  label: const Text('Últimos 7 días'),
                  selected: false,
                  onSelected: (_) => _setUltimos7Dias(),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                TextButton.icon(
                  onPressed: _seleccionarDesde,
                  icon: const Icon(Icons.date_range),
                  label: Text('Desde: ${_dateFormat.format(_desde)}'),
                ),
                TextButton.icon(
                  onPressed: _seleccionarHasta,
                  icon: const Icon(Icons.date_range),
                  label: Text('Hasta: ${_dateFormat.format(_hasta)}'),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Align(
              alignment: Alignment.centerLeft,
              child: ElevatedButton.icon(
                onPressed: _buscar,
                icon: const Icon(Icons.search),
                label: const Text('Generar corte'),
              ),
            ),
            const SizedBox(height: 16),
            if (_loading)
              const Expanded(
                child: Center(child: CircularProgressIndicator()),
              )
            else if (_corte == null)
              const Expanded(
                child: Center(
                  child: Text(
                    'Selecciona un periodo y presiona "Generar corte".',
                    textAlign: TextAlign.center,
                  ),
                ),
              )
            else
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      Align(
                        alignment: Alignment.centerRight,
                        child: ElevatedButton.icon(
                          onPressed: () async {
                            if (_corte == null) return;
                            try {
                              await _pdfService.imprimirCorte(_corte!);
                            } catch (e) {
                              if (mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(
                                        'Error al imprimir corte: $e'),
                                  ),
                                );
                              }
                            }
                          },
                          icon: const Icon(Icons.print),
                          label: const Text('Imprimir corte'),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Card(
                        elevation: 3,
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Cajero: ${_corte!.usuario}',
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'Periodo: ${_prettyFormat.format(_corte!.desde.toLocal())} '
                                    'al ${_prettyFormat.format(_corte!.hasta.toLocal())}',
                              ),
                              const SizedBox(height: 12),
                              const Divider(),
                              const SizedBox(height: 8),
                              Row(
                                children: [
                                  Expanded(
                                    child: _MetricTile(
                                      icon: Icons.receipt_long,
                                      label: 'Tickets',
                                      value: '${_corte!.totalTickets}',
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: _MetricTile(
                                      icon: Icons.attach_money,
                                      label: 'Total vendido',
                                      value:
                                      '\$${_corte!.totalVendido.toStringAsFixed(2)}',
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: _MetricTile(
                                      icon: Icons.bar_chart,
                                      label: 'Promedio ticket',
                                      value:
                                      '\$${_corte!.ventaPromedio.toStringAsFixed(2)}',
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _MetricTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _MetricTile({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Icon(icon, size: 24, color: Colors.deepPurple),
        const SizedBox(height: 4),
        Text(
          label,
          style: const TextStyle(fontSize: 12, color: Colors.black54),
        ),
        const SizedBox(height: 2),
        Text(
          value,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }
}
