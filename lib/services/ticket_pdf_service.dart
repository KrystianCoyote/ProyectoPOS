// lib/services/ticket_pdf_service.dart
import 'dart:typed_data';
import 'package:pdf/widgets.dart' as pw;
import 'package:pdf/pdf.dart';
import 'package:intl/intl.dart';

import '../models/venta.dart';

class TicketPdfService {
  static final DateFormat _dateFormat = DateFormat('dd/MM/yyyy HH:mm');

  static String _formatFecha(DateTime fecha) {
    final local = fecha.toLocal();
    return _dateFormat.format(local);
  }

  static Future<Uint8List> generarTicketPdf(Venta venta) async {
    final pdf = pw.Document();

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat(
          48 * PdfPageFormat.mm, // ancho ticket 58mm
          double.infinity,
          marginAll: 5,
        ),
        build: (context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              // 👇 Encabezado EXACTO como lo pediste
              pw.Center(
                child: pw.Text(
                  "TICKET #${venta.idVenta}",
                  style: pw.TextStyle(
                    fontSize: 14,
                    fontWeight: pw.FontWeight.bold,
                  ),
                ),
              ),

              pw.SizedBox(height: 2),

              pw.Center(
                child: pw.Text(
                  "Folio: ${venta.folio}",
                  style: pw.TextStyle(
                    fontSize: 8,
                    fontWeight: pw.FontWeight.bold,
                  ),
                ),
              ),

              pw.SizedBox(height: 6),

              pw.Center(
                child: pw.Text(
                  "Fecha: ${_formatFecha(venta.fechaHora)}",
                  style: const pw.TextStyle(fontSize: 8),
                ),
              ),

              pw.Center(
                child: pw.Text(
                  "Cajero: ${venta.nombreUsuario}",
                  style: const pw.TextStyle(fontSize: 8),
                ),
              ),

              pw.SizedBox(height: 6),
              pw.Divider(),
              pw.SizedBox(height: 6),

              // Productos
              ...venta.detalles.map((d) {
                return pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Row(
                      mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                      children: [
                        pw.Expanded(
                          child: pw.Text(
                            d.nombre,
                            style: const pw.TextStyle(fontSize: 10),
                          ),
                        ),
                        pw.Text(
                          "\$${d.subtotal.toStringAsFixed(2)}",
                          style: const pw.TextStyle(fontSize: 10),
                        ),
                      ],
                    ),
                    pw.Text(
                      "${d.cantidad} x \$${d.precioUnitario.toStringAsFixed(2)}",
                      style: const pw.TextStyle(fontSize: 8),
                    ),
                    pw.SizedBox(height: 4),
                  ],
                );
              }).toList(),

              pw.Divider(),

              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Text(
                    "TOTAL:",
                    style: pw.TextStyle(
                      fontSize: 12,
                      fontWeight: pw.FontWeight.bold,
                    ),
                  ),
                  pw.Text(
                    "\$${venta.total.toStringAsFixed(2)}",
                    style: pw.TextStyle(
                      fontSize: 12,
                      fontWeight: pw.FontWeight.bold,
                    ),
                  ),
                ],
              ),

              pw.SizedBox(height: 10),

              pw.Center(
                child: pw.Text(
                  "¡Gracias por su compra! :)",
                  style: const pw.TextStyle(fontSize: 8),
                ),
              ),
            ],
          );
        },
      ),
    );

    return pdf.save();
  }
}
