// lib/services/corte_pdf_service.dart
import 'dart:typed_data';
import 'package:pdf/widgets.dart' as pw;
import 'package:pdf/pdf.dart';
import 'package:printing/printing.dart';

import 'corte_service.dart';

class CortePdfService {
  Future<void> imprimirCorte(CorteCaja corte) async {
    final pdf = pw.Document();

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.roll80,
        build: (context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Center(
                child: pw.Text(
                  'CORTE DE CAJA',
                  style: pw.TextStyle(
                    fontSize: 16,
                    fontWeight: pw.FontWeight.bold,
                  ),
                ),
              ),
              pw.SizedBox(height: 8),
              pw.Text('Cajero: ${corte.usuario}'),
              pw.Text(
                'Desde: ${corte.desde.toLocal()}',
                style: const pw.TextStyle(fontSize: 10),
              ),
              pw.Text(
                'Hasta: ${corte.hasta.toLocal()}',
                style: const pw.TextStyle(fontSize: 10),
              ),
              pw.SizedBox(height: 10),
              pw.Divider(),
              pw.SizedBox(height: 8),
              pw.Text('Tickets: ${corte.totalTickets}'),
              pw.Text(
                  'Total vendido: \$${corte.totalVendido.toStringAsFixed(2)}'),
              pw.Text(
                  'Promedio por ticket: \$${corte.ventaPromedio.toStringAsFixed(2)}'),
              pw.SizedBox(height: 12),
              pw.Divider(),
              pw.SizedBox(height: 6),
              pw.Center(
                child: pw.Text(
                  'Generado por POS App',
                  style: const pw.TextStyle(fontSize: 9),
                ),
              ),
            ],
          );
        },
      ),
    );

    await Printing.layoutPdf(
      onLayout: (PdfPageFormat format) async => pdf.save(),
    );
  }
}
