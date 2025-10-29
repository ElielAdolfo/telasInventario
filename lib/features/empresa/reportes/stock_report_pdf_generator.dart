// lib/features/empresa/reportes/stock_report_pdf_generator.dart
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:intl/intl.dart';
import '../models/stock_empresa_model.dart';
import '../models/stock_tienda_model.dart';

class StockReportPdfGenerator {
  // Colores para las tablas
  static const headerColor = PdfColors.grey800;
  static const evenRowColor = PdfColors.white;
  static const oddRowColor = PdfColors.grey200;

  // Genera un PDF para el reporte de stock de empresa
  static Future<pw.Document> generateStockEmpresaPdf({
    required List<StockEmpresa> stockEmpresa,
    required String titulo,
  }) async {
    final pdf = pw.Document();
    final now = DateTime.now();

    // Configuración base
    const pageFormat = PdfPageFormat.letter;
    const margin = 1.0 * PdfPageFormat.cm;
    const rowsPerPage = 15;
    final totalPages = (stockEmpresa.length / rowsPerPage).ceil();

    for (int pageIndex = 0; pageIndex < totalPages; pageIndex++) {
      final startIndex = pageIndex * rowsPerPage;
      final endIndex = (startIndex + rowsPerPage) < stockEmpresa.length
          ? startIndex + rowsPerPage
          : stockEmpresa.length;

      pdf.addPage(
        pw.Page(
          pageFormat: pageFormat,
          margin: const pw.EdgeInsets.all(margin),
          build: (pw.Context context) {
            return pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                if (pageIndex == 0) ...[
                  pw.Text(
                    titulo,
                    style: pw.TextStyle(
                      fontSize: 24,
                      fontWeight: pw.FontWeight.bold,
                    ),
                  ),
                  pw.SizedBox(height: 8),
                  pw.Text(
                    'Fecha: ${DateFormat('yyyy-MM-dd HH:mm').format(now)}',
                  ),
                  pw.SizedBox(height: 16),
                  pw.Text(
                    'Total de Productos: ${stockEmpresa.length}',
                    style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                  ),
                  pw.SizedBox(height: 16),
                ] else ...[
                  pw.Text(
                    'Stock de Empresa (Continuación)',
                    style: pw.TextStyle(
                      fontSize: 18,
                      fontWeight: pw.FontWeight.bold,
                    ),
                  ),
                  pw.SizedBox(height: 16),
                ],
                pw.Table(
                  border: pw.TableBorder.all(),
                  columnWidths: {
                    0: const pw.FlexColumnWidth(3),
                    1: const pw.FlexColumnWidth(2),
                    2: const pw.FlexColumnWidth(1),
                    3: const pw.FlexColumnWidth(1),
                    4: const pw.FlexColumnWidth(1),
                    5: const pw.FlexColumnWidth(1),
                  },
                  children: [
                    pw.TableRow(
                      decoration: const pw.BoxDecoration(color: headerColor),
                      children: [
                        _headerCell('Producto'),
                        _headerCell('Color'),
                        _headerCell('Cantidad'),
                        _headerCell('Unidad'),
                        _headerCell('Precio'),
                        _headerCell('Total'),
                      ],
                    ),
                    ...List.generate(endIndex - startIndex, (index) {
                      final stock = stockEmpresa[startIndex + index];
                      final isEven = index % 2 == 0;
                      return pw.TableRow(
                        decoration: pw.BoxDecoration(
                          color: isEven ? evenRowColor : oddRowColor,
                        ),
                        children: [
                          _cell(stock.nombre),
                          _cell(stock.idColor ?? 'Sin Color'),
                          _cell(stock.cantidadDisponible.toString()),
                          _cell(stock.unidadMedida),
                          _cell(
                            '\$${stock.precioVentaMenor.toStringAsFixed(2)}',
                          ),
                          _cell(
                            '\$${(stock.cantidadDisponible * stock.precioVentaMenor).toStringAsFixed(2)}',
                          ),
                        ],
                      );
                    }),
                  ],
                ),
                pw.SizedBox(height: 20),
                pw.Align(
                  alignment: pw.Alignment.bottomRight,
                  child: pw.Text('Página ${pageIndex + 1} de $totalPages'),
                ),
              ],
            );
          },
        ),
      );
    }

    return pdf;
  }

  // Genera un PDF para el reporte de stock de tienda
  static Future<pw.Document> generateStockTiendaPdf({
    required List<StockTienda> stockTienda,
    required String titulo,
  }) async {
    final pdf = pw.Document();
    final now = DateTime.now();

    const pageFormat = PdfPageFormat.letter;
    const margin = 1.0 * PdfPageFormat.cm;
    const rowsPerPage = 15;
    final totalPages = (stockTienda.length / rowsPerPage).ceil();

    for (int pageIndex = 0; pageIndex < totalPages; pageIndex++) {
      final startIndex = pageIndex * rowsPerPage;
      final endIndex = (startIndex + rowsPerPage) < stockTienda.length
          ? startIndex + rowsPerPage
          : stockTienda.length;

      pdf.addPage(
        pw.Page(
          pageFormat: pageFormat,
          margin: const pw.EdgeInsets.all(margin),
          build: (pw.Context context) {
            return pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                if (pageIndex == 0) ...[
                  pw.Text(
                    titulo,
                    style: pw.TextStyle(
                      fontSize: 24,
                      fontWeight: pw.FontWeight.bold,
                    ),
                  ),
                  pw.SizedBox(height: 8),
                  pw.Text(
                    'Fecha: ${DateFormat('yyyy-MM-dd HH:mm').format(now)}',
                  ),
                  pw.SizedBox(height: 16),
                  pw.Text(
                    'Total de Productos: ${stockTienda.length}',
                    style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                  ),
                  pw.SizedBox(height: 16),
                ] else ...[
                  pw.Text(
                    'Stock de Tienda (Continuación)',
                    style: pw.TextStyle(
                      fontSize: 18,
                      fontWeight: pw.FontWeight.bold,
                    ),
                  ),
                  pw.SizedBox(height: 16),
                ],
                pw.Table(
                  border: pw.TableBorder.all(),
                  columnWidths: {
                    0: const pw.FlexColumnWidth(3),
                    1: const pw.FlexColumnWidth(2),
                    2: const pw.FlexColumnWidth(1),
                    3: const pw.FlexColumnWidth(1),
                    4: const pw.FlexColumnWidth(1),
                    5: const pw.FlexColumnWidth(1),
                  },
                  children: [
                    pw.TableRow(
                      decoration: const pw.BoxDecoration(color: headerColor),
                      children: [
                        _headerCell('Producto'),
                        _headerCell('Color'),
                        _headerCell('Cantidad'),
                        _headerCell('Unidad'),
                        _headerCell('Precio'),
                        _headerCell('Total'),
                      ],
                    ),
                    ...List.generate(endIndex - startIndex, (index) {
                      final stock = stockTienda[startIndex + index];
                      final isEven = index % 2 == 0;
                      return pw.TableRow(
                        decoration: pw.BoxDecoration(
                          color: isEven ? evenRowColor : oddRowColor,
                        ),
                        children: [
                          _cell(stock.nombre),
                          _cell(stock.colorNombre ?? 'Sin Color'),
                          _cell(stock.cantidadDisponible.toString()),
                          _cell(stock.unidadMedida),
                          _cell(
                            '\$${stock.precioVentaMenor.toStringAsFixed(2)}',
                          ),
                          _cell(
                            '\$${(stock.cantidadDisponible * stock.precioVentaMenor).toStringAsFixed(2)}',
                          ),
                        ],
                      );
                    }),
                  ],
                ),
                pw.SizedBox(height: 20),
                pw.Align(
                  alignment: pw.Alignment.bottomRight,
                  child: pw.Text('Página ${pageIndex + 1} de $totalPages'),
                ),
              ],
            );
          },
        ),
      );
    }

    return pdf;
  }

  // Helpers de celdas
  static pw.Widget _headerCell(String text, {double fontSize = 10}) {
    return pw.Padding(
      padding: const pw.EdgeInsets.all(5),
      child: pw.Text(
        text,
        style: pw.TextStyle(
          color: PdfColors.white,
          fontWeight: pw.FontWeight.bold,
          fontSize: fontSize,
        ),
      ),
    );
  }

  static pw.Widget _cell(String text, {double fontSize = 10}) {
    return pw.Padding(
      padding: const pw.EdgeInsets.all(5),
      child: pw.Text(text, style: pw.TextStyle(fontSize: fontSize)),
    );
  }
}
