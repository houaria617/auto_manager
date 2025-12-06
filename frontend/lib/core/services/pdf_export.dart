// lib/core/services/pdf_export_service.dart

import 'package:auto_manager/logic/cubits/analytics/analytics_state.dart';
import 'package:intl/intl.dart';
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

  Future<void> generatePaymentStatement({
    required int rentalId,
    required double totalRentalCost,
    required double totalPaid,
    required double remaining,
    required List<Map> payments,
  }) async {
    final pdf = pw.Document();
    final dateFormat = DateFormat('MMM dd, yyyy - HH:mm');

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        build: (pw.Context context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              // 1. Header
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Text(
                        "PAYMENT STATEMENT",
                        style: pw.TextStyle(
                          fontSize: 24,
                          fontWeight: pw.FontWeight.bold,
                          color: PdfColors.blue,
                        ),
                      ),
                      pw.Text(
                        "Rental ID: #$rentalId",
                        style: const pw.TextStyle(
                          fontSize: 14,
                          color: PdfColors.grey,
                        ),
                      ),
                    ],
                  ),
                  pw.Text(DateFormat('yyyy-MM-dd').format(DateTime.now())),
                ],
              ),
              pw.SizedBox(height: 20),
              pw.Divider(),
              pw.SizedBox(height: 20),

              // 2. Financial Summary Box
              pw.Container(
                padding: const pw.EdgeInsets.all(15),
                decoration: pw.BoxDecoration(
                  color: PdfColors.grey100,
                  borderRadius: pw.BorderRadius.circular(8),
                  border: pw.Border.all(color: PdfColors.grey300),
                ),
                child: pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceAround,
                  children: [
                    _buildTextStat("Total Cost", totalRentalCost),
                    _buildTextStat(
                      "Total Paid",
                      totalPaid,
                      color: PdfColors.green,
                    ),
                    _buildTextStat(
                      "Balance Due",
                      remaining,
                      color: remaining > 0 ? PdfColors.red : PdfColors.black,
                    ),
                  ],
                ),
              ),

              pw.SizedBox(height: 30),

              // 3. Transaction History Table
              pw.Text(
                "Transaction History",
                style: pw.TextStyle(
                  fontSize: 18,
                  fontWeight: pw.FontWeight.bold,
                ),
              ),
              pw.SizedBox(height: 10),

              pw.Table.fromTextArray(
                headers: ['Payment ID', 'Date', 'Amount'],
                data: payments.map((p) {
                  final date =
                      DateTime.tryParse(p['date'] ?? '') ?? DateTime.now();
                  final amount = (p['paid_amount'] as num).toDouble();
                  return [
                    "#${p['id']}",
                    dateFormat.format(date),
                    "\$${amount.toStringAsFixed(2)}",
                  ];
                }).toList(),
                headerStyle: pw.TextStyle(
                  fontWeight: pw.FontWeight.bold,
                  color: PdfColors.white,
                ),
                headerDecoration: const pw.BoxDecoration(color: PdfColors.blue),
                cellAlignment: pw.Alignment.centerLeft,
                // Right align the Amount column (index 2)
                cellAlignments: {2: pw.Alignment.centerRight},
              ),

              // Footer
              pw.Spacer(),
              pw.Divider(),
              pw.Center(child: pw.Text("Thank you for your business.")),
            ],
          );
        },
      ),
    );

    await Printing.layoutPdf(
      onLayout: (PdfPageFormat format) async => pdf.save(),
      name: 'Statement_Rental_$rentalId.pdf',
    );
  }

  pw.Widget _buildTextStat(
    String label,
    double value, {
    PdfColor color = PdfColors.black,
  }) {
    return pw.Column(
      children: [
        pw.Text(
          label,
          style: const pw.TextStyle(color: PdfColors.grey700, fontSize: 10),
        ),
        pw.SizedBox(height: 4),
        pw.Text(
          "\$${value.toStringAsFixed(2)}",
          style: pw.TextStyle(
            fontSize: 16,
            fontWeight: pw.FontWeight.bold,
            color: color,
          ),
        ),
      ],
    );
  }
}
