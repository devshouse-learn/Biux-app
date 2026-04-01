import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

class AlertPdfExportService {
  static Future<void> exportAlerts({
    required List<QueryDocumentSnapshot> alerts,
    required String Function(String) t,
    String? cityFilter,
    String? dateRange,
  }) async {
    final pdf = pw.Document();
    final now = DateTime.now();
    final dateStr = DateFormat('dd/MM/yyyy hh:mm a').format(now);

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
      final city = bike['city']?.toString() ?? t('pdf_unknown_city');
      uniqueCities.add(city);
    }

    // City stats
    final cityCount = <String, int>{};
    for (final doc in alerts) {
      final data = doc.data() as Map<String, dynamic>;
      final bike = data['bikeData'] as Map<String, dynamic>? ?? {};
      final c = bike['city']?.toString() ?? t('pdf_unknown_city');
      cityCount[c] = (cityCount[c] ?? 0) + 1;
    }
    final sortedCities = cityCount.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    // Brand stats
    final brandCount = <String, int>{};
    for (final doc in alerts) {
      final data = doc.data() as Map<String, dynamic>;
      final bike = data['bikeData'] as Map<String, dynamic>? ?? {};
      final b = bike['brand']?.toString() ?? t('pdf_unknown_city');
      brandCount[b] = (brandCount[b] ?? 0) + 1;
    }
    final sortedBrands = brandCount.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(32),
        header: (context) => _buildPdfHeader(dateStr, cityFilter, dateRange, t),
        footer: (context) => _buildPdfFooter(context, t),
        build: (context) => [
          // Summary
          _buildSummarySection(
            totalAlerts,
            uniqueSellers,
            uniqueCities.length,
            t,
          ),
          pw.SizedBox(height: 20),

          // City stats
          if (sortedCities.isNotEmpty) ...[
            _buildSectionTitle(t('pdf_alerts_by_city')),
            pw.SizedBox(height: 8),
            _buildStatsTable(
              headers: [t('pdf_city'), t('pdf_alerts'), t('pdf_percentage')],
              rows: sortedCities
                  .take(15)
                  .map(
                    (e) => [
                      e.key,
                      e.value.toString(),
                      '${(e.value / totalAlerts * 100).toStringAsFixed(1)}%',
                    ],
                  )
                  .toList(),
            ),
            pw.SizedBox(height: 20),
          ],

          // Brand stats
          if (sortedBrands.isNotEmpty) ...[
            _buildSectionTitle(t('pdf_most_affected_brands')),
            pw.SizedBox(height: 8),
            _buildStatsTable(
              headers: [t('pdf_brand'), t('pdf_alerts'), t('pdf_percentage')],
              rows: sortedBrands
                  .take(10)
                  .map(
                    (e) => [
                      e.key,
                      e.value.toString(),
                      '${(e.value / totalAlerts * 100).toStringAsFixed(1)}%',
                    ],
                  )
                  .toList(),
            ),
            pw.SizedBox(height: 20),
          ],

          // Detailed alerts
          _buildSectionTitle(t('pdf_alert_details')),
          pw.SizedBox(height: 8),
          ...alerts.map((doc) => _buildAlertRow(doc, t)),
        ],
      ),
    );

    await Printing.layoutPdf(
      onLayout: (format) async => pdf.save(),
      name: 'Reporte_Alertas_Biux_${DateFormat('yyyyMMdd_HHmm').format(now)}',
    );
  }

  static pw.Widget _buildPdfHeader(
    String date,
    String? city,
    String? dateRange,
    String Function(String) t,
  ) {
    return pw.Container(
      padding: const pw.EdgeInsets.only(bottom: 16),
      decoration: const pw.BoxDecoration(
        border: pw.Border(
          bottom: pw.BorderSide(color: PdfColors.red, width: 2),
        ),
      ),
      child: pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        children: [
          pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Text(
                'BIUX',
                style: pw.TextStyle(
                  fontSize: 28,
                  fontWeight: pw.FontWeight.bold,
                  color: PdfColors.red800,
                ),
              ),
              pw.SizedBox(height: 2),
              pw.Text(
                t('pdf_stolen_bike_report'),
                style: pw.TextStyle(fontSize: 12, color: PdfColors.grey700),
              ),
            ],
          ),
          pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.end,
            children: [
              pw.Text(
                '${t('pdf_generated')}: $date',
                style: const pw.TextStyle(
                  fontSize: 9,
                  color: PdfColors.grey600,
                ),
              ),
              if (city != null && city != 'Todas')
                pw.Text(
                  '${t('pdf_city')}: $city',
                  style: const pw.TextStyle(
                    fontSize: 9,
                    color: PdfColors.grey600,
                  ),
                ),
              if (dateRange != null)
                pw.Text(
                  '${t('pdf_period')}: $dateRange',
                  style: const pw.TextStyle(
                    fontSize: 9,
                    color: PdfColors.grey600,
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }

  static pw.Widget _buildPdfFooter(
    pw.Context context,
    String Function(String) t,
  ) {
    return pw.Container(
      padding: const pw.EdgeInsets.only(top: 8),
      decoration: const pw.BoxDecoration(
        border: pw.Border(top: pw.BorderSide(color: PdfColors.grey300)),
      ),
      child: pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        children: [
          pw.Text(
            'Biux - ${t('pdf_cycling_platform')}',
            style: const pw.TextStyle(fontSize: 8, color: PdfColors.grey500),
          ),
          pw.Text(
            '${t('pdf_page')} ${context.pageNumber} ${t('pdf_of')} ${context.pagesCount}',
            style: const pw.TextStyle(fontSize: 8, color: PdfColors.grey500),
          ),
        ],
      ),
    );
  }

  static pw.Widget _buildSummarySection(
    int total,
    int sellers,
    int cities,
    String Function(String) t,
  ) {
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
          _summaryItem(
            t('pdf_total_alerts'),
            total.toString(),
            PdfColors.red800,
          ),
          _summaryItem(
            t('pdf_unique_sellers'),
            sellers.toString(),
            PdfColors.orange800,
          ),
          _summaryItem(
            t('pdf_affected_cities'),
            cities.toString(),
            PdfColors.blue800,
          ),
        ],
      ),
    );
  }

  static pw.Widget _summaryItem(String label, String value, PdfColor color) {
    return pw.Column(
      children: [
        pw.Text(
          value,
          style: pw.TextStyle(
            fontSize: 24,
            fontWeight: pw.FontWeight.bold,
            color: color,
          ),
        ),
        pw.SizedBox(height: 4),
        pw.Text(
          label,
          style: const pw.TextStyle(fontSize: 9, color: PdfColors.grey700),
        ),
      ],
    );
  }

  static pw.Widget _buildSectionTitle(String title) {
    return pw.Container(
      width: double.infinity,
      padding: const pw.EdgeInsets.symmetric(vertical: 6, horizontal: 10),
      decoration: pw.BoxDecoration(
        color: PdfColors.grey800,
        borderRadius: pw.BorderRadius.circular(4),
      ),
      child: pw.Text(
        title,
        style: pw.TextStyle(
          fontSize: 12,
          fontWeight: pw.FontWeight.bold,
          color: PdfColors.white,
        ),
      ),
    );
  }

  static pw.Widget _buildStatsTable({
    required List<String> headers,
    required List<List<String>> rows,
  }) {
    return pw.TableHelper.fromTextArray(
      headerStyle: pw.TextStyle(
        fontSize: 10,
        fontWeight: pw.FontWeight.bold,
        color: PdfColors.white,
      ),
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

  static pw.Widget _buildAlertRow(
    QueryDocumentSnapshot doc,
    String Function(String) t,
  ) {
    final data = doc.data() as Map<String, dynamic>;
    final ts = data['timestamp'] as Timestamp?;
    final date = ts != null
        ? DateFormat('dd/MM/yyyy hh:mm a').format(ts.toDate())
        : t('pdf_no_date');
    final seller = data['sellerName']?.toString() ?? t('pdf_unknown_seller');
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
                padding: const pw.EdgeInsets.symmetric(
                  horizontal: 6,
                  vertical: 2,
                ),
                decoration: pw.BoxDecoration(
                  color: PdfColors.red,
                  borderRadius: pw.BorderRadius.circular(3),
                ),
                child: pw.Text(
                  t('pdf_alert_badge'),
                  style: pw.TextStyle(
                    fontSize: 8,
                    fontWeight: pw.FontWeight.bold,
                    color: PdfColors.white,
                  ),
                ),
              ),
              pw.Text(
                date,
                style: const pw.TextStyle(
                  fontSize: 8,
                  color: PdfColors.grey600,
                ),
              ),
            ],
          ),
          pw.SizedBox(height: 6),
          pw.Row(
            children: [
              pw.Expanded(
                child: pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Text(
                      t('pdf_seller'),
                      style: pw.TextStyle(
                        fontSize: 8,
                        fontWeight: pw.FontWeight.bold,
                        color: PdfColors.grey600,
                      ),
                    ),
                    pw.Text(seller, style: const pw.TextStyle(fontSize: 10)),
                    pw.Text(
                      'UID: $sellerUid',
                      style: const pw.TextStyle(
                        fontSize: 7,
                        color: PdfColors.grey500,
                      ),
                    ),
                  ],
                ),
              ),
              pw.Expanded(
                child: pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Text(
                      t('pdf_bicycle'),
                      style: pw.TextStyle(
                        fontSize: 8,
                        fontWeight: pw.FontWeight.bold,
                        color: PdfColors.grey600,
                      ),
                    ),
                    pw.Text(
                      '$brand $model',
                      style: const pw.TextStyle(fontSize: 10),
                    ),
                    pw.Text(
                      '${t('pdf_color')}: $color',
                      style: const pw.TextStyle(
                        fontSize: 8,
                        color: PdfColors.grey600,
                      ),
                    ),
                  ],
                ),
              ),
              pw.Expanded(
                child: pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Text(
                      t('pdf_serial'),
                      style: pw.TextStyle(
                        fontSize: 8,
                        fontWeight: pw.FontWeight.bold,
                        color: PdfColors.grey600,
                      ),
                    ),
                    pw.Text(serial, style: const pw.TextStyle(fontSize: 10)),
                    pw.Text(
                      '${t('pdf_city')}: $city',
                      style: const pw.TextStyle(
                        fontSize: 8,
                        color: PdfColors.grey600,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
