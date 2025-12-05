// lib/core/services/pdf_export_service.dart

import 'dart:typed_data';
import 'package:auto_manager/logic/cubits/analytics/analytics_state.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

class PdfExportService {
  Future<void> generateAndPrintPdf(
    AnalyticsLoaded data,
    String timeframe,
  ) async {
    final pdf = pw.Document();

    // Add a page to the PDF
    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        build: (pw.Context context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              // 1. Header
              _buildHeader(timeframe),
              pw.SizedBox(height: 20),
              pw.Divider(),
              pw.SizedBox(height: 20),

              // 2. Key Metrics Grid
              _buildMetricsRow(data),
              pw.SizedBox(height: 30),

              // 3. Top Cars Table
              pw.Text(
                "Top Rented Vehicles",
                style: pw.TextStyle(
                  fontSize: 18,
                  fontWeight: pw.FontWeight.bold,
                ),
              ),
              pw.SizedBox(height: 10),
              _buildCarsTable(data.topCars),

              pw.SizedBox(height: 30),

              // 4. Client Stats
              pw.Text(
                "Client Overview",
                style: pw.TextStyle(
                  fontSize: 18,
                  fontWeight: pw.FontWeight.bold,
                ),
              ),
              pw.SizedBox(height: 10),
              _buildClientSummary(data),

              // Footer
              pw.Spacer(),
              pw.Divider(),
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Text("AutoManager App"),
                  pw.Text(
                    "Generated: ${DateTime.now().toString().split('.')[0]}",
                  ),
                ],
              ),
            ],
          );
        },
      ),
    );

    // This opens the native Print/Share dialog on Android/iOS/Desktop
    await Printing.layoutPdf(
      onLayout: (PdfPageFormat format) async => pdf.save(),
      name: 'AutoManager_Report_$timeframe.pdf',
    );
  }

  // --- Helper Widgets for PDF ---

  pw.Widget _buildHeader(String timeframe) {
    return pw.Row(
      mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
      children: [
        pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Text(
              "RENTAL ANALYTICS REPORT",
              style: pw.TextStyle(
                fontSize: 24,
                fontWeight: pw.FontWeight.bold,
                color: PdfColors.blue,
              ),
            ),
            pw.Text(
              "Period: $timeframe",
              style: const pw.TextStyle(fontSize: 14, color: PdfColors.grey),
            ),
          ],
        ),
        // You can add a logo here if you have one loaded as an image
      ],
    );
  }

  pw.Widget _buildMetricsRow(AnalyticsLoaded data) {
    return pw.Row(
      mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
      children: [
        _buildMetricBox(
          "Total Revenue",
          "\$${data.totalRevenue.toStringAsFixed(2)}",
        ),
        _buildMetricBox("Total Rentals", "${data.totalRentals}"),
        _buildMetricBox("Avg Duration", "${data.avgDurationDays} Days"),
      ],
    );
  }

  pw.Widget _buildMetricBox(String title, String value) {
    return pw.Container(
      padding: const pw.EdgeInsets.all(15),
      decoration: pw.BoxDecoration(
        border: pw.Border.all(color: PdfColors.grey300),
        borderRadius: pw.BorderRadius.circular(8),
        color: PdfColors.grey100,
      ),
      width: 150,
      child: pw.Column(
        children: [
          pw.Text(
            title,
            style: const pw.TextStyle(color: PdfColors.grey700, fontSize: 10),
          ),
          pw.SizedBox(height: 5),
          pw.Text(
            value,
            style: pw.TextStyle(
              fontSize: 18,
              fontWeight: pw.FontWeight.bold,
              color: PdfColors.blue,
            ),
          ),
        ],
      ),
    );
  }

  pw.Widget _buildCarsTable(List<Map<String, dynamic>> cars) {
    return pw.Table.fromTextArray(
      headers: ['Rank', 'Car Model', 'Rentals Count'],
      data: cars
          .map(
            (car) => [
              "#${car['rank']}",
              car['name'],
              car['rentals'].toString(),
            ],
          )
          .toList(),
      headerStyle: pw.TextStyle(
        fontWeight: pw.FontWeight.bold,
        color: PdfColors.white,
      ),
      headerDecoration: const pw.BoxDecoration(color: PdfColors.blue),
      cellAlignment: pw.Alignment.centerLeft,
      cellPadding: const pw.EdgeInsets.all(8),
    );
  }

  pw.Widget _buildClientSummary(AnalyticsLoaded data) {
    return pw.Row(
      children: [
        pw.Expanded(
          child: _buildMetricBox("Total Clients", "${data.totalClients}"),
        ),
        pw.SizedBox(width: 10),
        pw.Expanded(
          child: _buildMetricBox("Active in Period", "${data.activeClients}"),
        ),
      ],
    );
  }
}
