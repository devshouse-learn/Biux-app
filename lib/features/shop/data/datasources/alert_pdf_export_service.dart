import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

class AlertPdfExportService {
  static Future<void> exportAlerts({
    required List<QueryDocumentSnapshot> alerts,
    String? cityFilter,
    String? dateRange,
  }) async {
    final pdf = pw.Document();
    final now = DateTime.now();
    final dateStr = DateFormat('dd/MM/yyyy HH:mm').format(now);

    // Header info
    final totalAlerts = alerts.length;
    final uniqueSellers = alerts
        .map((d) => (d.data() as Map<String, dynamic>)['sellerUid'])
        .toSet()
        .length;
    final uniqueCities = <String>{};
    for (final doc in alerts) {
      final data = doc.data() as Map<String, dynamic>;
      final bike = data['bikeData'] as Map<String, dynamic>? ?? {};
      final city = bike['city']?.toString() ?? 'Desconocida';
      uniqueCities.add(city);
    }

    // City stats
    final cityCount = <String, int>{};
    for (final doc in alerts) {
      final data = doc.data() as Map<String, dynamic>;
      final bike = data['bikeData'] as Map<String, dynamic>? ?? {};
      final c = bike['city']?.toString() ?? 'Desconocida';
      cityCount[c] = (cityCount[c] ?? 0) + 1;
    }
    final sortedCities = cityCount.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    // Brand stats
    final brandCount = <String, int>{};
    for (final doc in alerts) {
      final data = doc.data() as Map<String, dynamic>;
      final bike = data['bikeData'] as Map<String, dynamic>? ?? {};
      final b = bike['brand']?.toString() ?? 'Desconocida';
      brandCount[b] = (brandCount[b] ?? 0) + 1;
    }
    final sortedBrands = brandCount.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(32),
        header: (context) => _buildPdfHeader(dateStr, cityFilter, dateRange),
        footer: (context) => _buildPdfFooter(context),
        build: (context) => [
          // Summary
          _buildSummarySection(totalAlerts, uniqueSellers, uniqueCities.length),
          pw.SizedBox(height: 20),

          // City stats
          if (sortedCities.isNotEmpty) ...[
            _buildSectionTitle('Alertas por Ciudad'),
            pw.SizedBox(height: 8),
            _buildStatsTable(
              headers: ['Ciudad', 'Alertas', 'Porcentaje'],
              rows: sortedCities.take(15).map((e) => [
                e.key,
                e.value.toString(),
                '${(e.value / totalAlerts * 100).toStringAsFixed(1)}%',
              ]).toList(),
            ),
            pw.SizedBox(height: 20),
          ],

          // Brand stats
          if (sortedBrands.isNotEmpty) ...[
            _buildSectionTitle('Marcas mas Afectadas'),
            pw.SizedBox(height: 8),
            _buildStatsTable(
              headers: ['Marca', 'Alertas', 'Porcentaje'],
              rows: sortedBrands.take(10).map((e) => [
                e.key,
                e.value.toString(),
                '${(e.value / totalAlerts * 100).toStringAsFixed(1)}%',
              ]).toList(),
            ),
            pw.SizedBox(height: 20),
          ],

          // Detailed alerts
          _buildSectionTitle('Detalle de Alertas'),
          pw.SizedBox(height: 8),
          ...alerts.map((doc) => _buildAlertRow(doc)),
        ],
      ),
    );

    await Printing.layoutPdf(
      onLayout: (format) async => pdf.save(),
      name: 'Reporte_Alertas_Biux_${DateFormat('yyyyMMdd_HHmm').format(now)}',
    );
  }

  static pw.Widget _buildPdfHeader(String date, String? city, String? dateRange) {
    return pw.Container(
      padding: const pw.EdgeInsets.only(bottom: 16),
      decoration: const pw.BoxDecoration(
        border: pw.Border(bottom: pw.BorderSide(color: PdfColors.red, width: 2)),
      ),
      child: pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        children: [
          pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Text('BIUX', style: pw.TextStyle(
                fontSize: 28, fontWeight: pw.FontWeight.bold, color: PdfColors.red800,
              )),
              pw.SizedBox(height: 2),
              pw.Text('Reporte de Alertas de Bicicletas Robadas', style: pw.TextStyle(
                fontSize: 12, color: PdfColors.grey700,
              )),
            ],
          ),
          pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.end,
            children: [
              pw.Text('Generado: $date', style: const pw.TextStyle(fontSize: 9, color: PdfColors.grey600)),
              if (city != null && city != 'Todas')
                pw.Text('Ciudad: $city', style: const pw.TextStyle(fontSize: 9, color: PdfColors.grey600)),
              if (dateRange != null)
                pw.Text('Periodo: $dateRange', style: const pw.TextStyle(fontSize: 9, color: PdfColors.grey600)),
            ],
          ),
        ],
      ),
    );
  }

  static pw.Widget _buildPdfFooter(pw.Context context) {
    return pw.Container(
      padding: const pw.EdgeInsets.only(top: 8),
      decoration: const pw.BoxDecoration(
        border: pw.Border(top: pw.BorderSide(color: PdfColors.grey300)),
      ),
      child: pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        children: [
          pw.Text('Biux - Plataforma de Ciclismo', style: const pw.TextStyle(fontSize: 8, color: PdfColors.grey500)),
          pw.Text('Pagina ${context.pageNumber} de ${context.pagesCount}',
            style: const pw.TextStyle(fontSize: 8, color: PdfColors.grey500)),
        ],
      ),
    );
  }

  static pw.Widget _buildSummarySection(int total, int sellers, int cities) {
    return pw.Container(
      padding: const pw.EdgeInsets.all(16),
      decoration: pw.BoxDecoration(
        color: PdfColors.red50,
        borderRadius: pw.BorderRadius.circular(8),
        border: pw.Border.all(color: PdfColors.red200),
      ),
      child: pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceAround,
        children: [
          _summaryItem('Total Alertas', total.toString(), PdfColors.red800),
          _summaryItem('Vendedores Unicos', sellers.toString(), PdfColors.orange800),
          _summaryItem('Ciudades Afectadas', cities.toString(), PdfColors.blue800),
        ],
      ),
    );
  }

  static pw.Widget _summaryItem(String label, String value, PdfColor color) {
    return pw.Column(children: [
      pw.Text(value, style: pw.TextStyle(fontSize: 24, fontWeight: pw.FontWeight.bold, color: color)),
      pw.SizedBox(height: 4),
      pw.Text(label, style: const pw.TextStyle(fontSize: 9, color: PdfColors.grey700)),
    ]);
  }

  static pw.Widget _buildSectionTitle(String title) {
    return pw.Container(
      width: double.infinity,
      padding: const pw.EdgeInsets.symmetric(vertical: 6, horizontal: 10),
      decoration: pw.BoxDecoration(
        color: PdfColors.grey800,
        borderRadius: pw.BorderRadius.circular(4),
      ),
      child: pw.Text(title, style: pw.TextStyle(
        fontSize: 12, fontWeight: pw.FontWeight.bold, color: PdfColors.white,
      )),
    );
  }

  static pw.Widget _buildStatsTable({
    required List<String> headers,
    required List<List<String>> rows,
  }) {
    return pw.TableHelper.fromTextArray(
      headerStyle: pw.TextStyle(fontSize: 10, fontWeight: pw.FontWeight.bold, color: PdfColors.white),
      headerDecoration: const pw.BoxDecoration(color: PdfColors.red400),
      cellStyle: const pw.TextStyle(fontSize: 9),
      cellHeight: 24,
      cellAlignments: {
        0: pw.Alignment.centerLeft,
        1: pw.Alignment.center,
        2: pw.Alignment.center,
      },
      headerAlignments: {
        0: pw.Alignment.centerLeft,
        1: pw.Alignment.center,
        2: pw.Alignment.center,
      },
      oddRowDecoration: const pw.BoxDecoration(color: PdfColors.grey100),
      headers: headers,
      data: rows,
    );
  }

  static pw.Widget _buildAlertRow(QueryDocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    final ts = data['timestamp'] as Timestamp?;
    final date = ts != null ? DateFormat('dd/MM/yyyy HH:mm').format(ts.toDate()) : 'Sin fecha';
    final seller = data['sellerName']?.toString() ?? 'Desconocido';
    final sellerUid = data['sellerUid']?.toString() ?? '';
    final bike = data['bikeData'] as Map<String, dynamic>? ?? {};
    final serial = bike['frameSerial']?.toString() ?? 'N/A';
    final brand = bike['brand']?.toString() ?? 'N/A';
    final model = bike['model']?.toString() ?? 'N/A';
    final color = bike['color']?.toString() ?? 'N/A';
    final city = bike['city']?.toString() ?? 'N/A';

    return pw.Container(
      margin: const pw.EdgeInsets.only(bottom: 8),
      padding: const pw.EdgeInsets.all(10),
      decoration: pw.BoxDecoration(
        border: pw.Border.all(color: PdfColors.red200),
        borderRadius: pw.BorderRadius.circular(6),
      ),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Row(
            mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
            children: [
              pw.Container(
                padding: const pw.EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: pw.BoxDecoration(color: PdfColors.red, borderRadius: pw.BorderRadius.circular(3)),
                child: pw.Text('ALERTA', style: pw.TextStyle(fontSize: 8, fontWeight: pw.FontWeight.bold, color: PdfColors.white)),
              ),
              pw.Text(date, style: const pw.TextStyle(fontSize: 8, color: PdfColors.grey600)),
            ],
          ),
          pw.SizedBox(height: 6),
          pw.Row(children: [
            pw.Expanded(
              child: pw.Column(crossAxisAlignment: pw.CrossAxisAlignment.start, children: [
                pw.Text('Vendedor', style: pw.TextStyle(fontSize: 8, fontWeight: pw.FontWeight.bold, color: PdfColors.grey600)),
                pw.Text(seller, style: const pw.TextStyle(fontSize: 10)),
                pw.Text('UID: $sellerUid', style: const pw.TextStyle(fontSize: 7, color: PdfColors.grey500)),
              ]),
            ),
            pw.Expanded(
              child: pw.Column(crossAxisAlignment: pw.CrossAxisAlignment.start, children: [
                pw.Text('Bicicleta', style: pw.TextStyle(fontSize: 8, fontWeight: pw.FontWeight.bold, color: PdfColors.grey600)),
                pw.Text('$brand $model', style: const pw.TextStyle(fontSize: 10)),
                pw.Text('Color: $color', style: const pw.TextStyle(fontSize: 8, color: PdfColors.grey600)),
              ]),
            ),
            pw.Expanded(
              child: pw.Column(crossAxisAlignment: pw.CrossAxisAlignment.start, children: [
                pw.Text('Serial', style: pw.TextStyle(fontSize: 8, fontWeight: pw.FontWeight.bold, color: PdfColors.grey600)),
                pw.Text(serial, style: const pw.TextStyle(fontSize: 10)),
                pw.Text('Ciudad: $city', style: const pw.TextStyle(fontSize: 8, color: PdfColors.grey600)),
              ]),
            ),
          ]),
        ],
      ),
    );
  }
}
