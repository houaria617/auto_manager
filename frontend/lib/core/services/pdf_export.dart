import 'package:auto_manager/logic/cubits/analytics/analytics_state.dart';
import 'package:intl/intl.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

// generates pdf reports for analytics and payment statements
class PdfExportService {
  // creates and opens the analytics report pdf
  Future<void> generateAndPrintPdf(
    AnalyticsLoaded data,
    String timeframe,
  ) async {
    final pdf = pw.Document();

    // build the main report page
    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        build: (pw.Context context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              // report title and timeframe
              _buildHeader(timeframe),
              pw.SizedBox(height: 20),
              pw.Divider(),
              pw.SizedBox(height: 20),

              // revenue, rentals, avg duration
              _buildMetricsRow(data),
              pw.SizedBox(height: 30),

              // most rented vehicles table
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

              // client statistics
              pw.Text(
                "Client Overview",
                style: pw.TextStyle(
                  fontSize: 18,
                  fontWeight: pw.FontWeight.bold,
                ),
              ),
              pw.SizedBox(height: 10),
              _buildClientSummary(data),

              // push footer to bottom
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

    // opens native print dialog on all platforms
    await Printing.layoutPdf(
      onLayout: (PdfPageFormat format) async => pdf.save(),
      name: 'AutoManager_Report_$timeframe.pdf',
    );
  }

  // builds the report header with title and period
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
      ],
    );
  }

  // creates the row of key metrics
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

  // individual metric box with label and value
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

  // creates the top vehicles table
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

  // client count summary row
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

  // generates a detailed payment statement for a specific rental
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
              // statement header with rental id
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

              // financial summary showing total, paid, and remaining
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

              // list of all payment transactions
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
                cellAlignments: {2: pw.Alignment.centerRight},
              ),

              // footer message
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

  // helper for financial stat display
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
