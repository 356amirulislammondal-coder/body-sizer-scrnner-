import 'dart:io';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:path_provider/path_provider.dart';
import 'package:printing/printing.dart';
import 'package:intl/intl.dart';
import '../core/constants/app_constants.dart';
import '../core/utils/unit_converter.dart';
import '../models/body_measurement.dart';

/// Builds a clean, single-page PDF report for a scan result and saves it to
/// the device's local documents folder (never uploaded anywhere).
class PdfExportService {
  final _dateFmt = DateFormat('MMM d, yyyy • h:mm a');

  Future<File> generateReport(BodyMeasurement m) async {
    final doc = pw.Document();
    final blue = PdfColor.fromInt(0xFF1259F4);
    final photoImage = await pw.MemoryImage.fromFile(File(m.photoPath));

    doc.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(32),
        build: (context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Text(
                    AppConstants.appName,
                    style: pw.TextStyle(
                      fontSize: 22,
                      fontWeight: pw.FontWeight.bold,
                      color: blue,
                    ),
                  ),
                  pw.Text(
                    _dateFmt.format(m.scannedAt),
                    style: const pw.TextStyle(fontSize: 10, color: PdfColors.grey700),
                  ),
                ],
              ),
              pw.SizedBox(height: 4),
              pw.Text(
                'AI Body Measurement Report',
                style: const pw.TextStyle(fontSize: 12, color: PdfColors.grey700),
              ),
              pw.Divider(color: blue, thickness: 1.2),
              pw.SizedBox(height: 12),

              pw.Row(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Container(
                    width: 140,
                    height: 190,
                    decoration: pw.BoxDecoration(
                      borderRadius: pw.BorderRadius.circular(12),
                      border: pw.Border.all(color: PdfColors.grey300),
                    ),
                    child: pw.ClipRRect(
                      horizontalRadius: 12,
                      verticalRadius: 12,
                      child: pw.Image(photoImage, fit: pw.BoxFit.cover),
                    ),
                  ),
                  pw.SizedBox(width: 20),
                  pw.Expanded(
                    child: pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.start,
                      children: [
                        _summaryRow('Accuracy', m.accuracy.label),
                        _summaryRow('Body Shape', m.bodyShape.label),
                        _summaryRow('BMI', '${m.bmi.toStringAsFixed(1)} (${m.bmiCategory})'),
                        _summaryRow('Est. Weight', UnitConverter.formatKgWithLb(m.estimatedWeightKg)),
                        _summaryRow('Height used', UnitConverter.formatCmWithInches(m.heightCm)),
                        pw.SizedBox(height: 6),
                        pw.Text(
                          m.wasHeightCalibrated
                              ? 'Calibrated using your entered height.'
                              : 'Estimated using assumed capture distance (no manual height entered).',
                          style: const pw.TextStyle(fontSize: 9, color: PdfColors.grey600),
                        ),
                      ],
                    ),
                  ),
                ],
              ),

              pw.SizedBox(height: 20),
              pw.Text(
                'Measurements',
                style: pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold, color: blue),
              ),
              pw.SizedBox(height: 8),
              _measurementTable(m),

              pw.Spacer(),
              pw.Container(
                padding: const pw.EdgeInsets.all(10),
                decoration: pw.BoxDecoration(
                  color: PdfColors.blue50,
                  borderRadius: pw.BorderRadius.circular(8),
                ),
                child: pw.Text(
                  AppConstants.disclaimerFull,
                  style: const pw.TextStyle(fontSize: 8, color: PdfColors.grey800),
                ),
              ),
            ],
          );
        },
      ),
    );

    final dir = await getApplicationDocumentsDirectory();
    final reportsDir = Directory('${dir.path}/reports');
    if (!await reportsDir.exists()) await reportsDir.create(recursive: true);
    final file = File(
      '${reportsDir.path}/BodySizeReport_${m.id.substring(0, 8)}.pdf',
    );
    await file.writeAsBytes(await doc.save());
    return file;
  }

  /// Opens the OS share sheet with the PDF attached.
  Future<void> shareReport(File pdfFile) async {
    await Printing.sharePdf(
      bytes: await pdfFile.readAsBytes(),
      filename: pdfFile.uri.pathSegments.last,
    );
  }

  pw.Widget _summaryRow(String label, String value) => pw.Padding(
        padding: const pw.EdgeInsets.only(bottom: 4),
        child: pw.RichText(
          text: pw.TextSpan(
            children: [
              pw.TextSpan(
                text: '$label: ',
                style: pw.TextStyle(fontSize: 11, fontWeight: pw.FontWeight.bold),
              ),
              pw.TextSpan(text: value, style: const pw.TextStyle(fontSize: 11)),
            ],
          ),
        ),
      );

  pw.Widget _measurementTable(BodyMeasurement m) {
    final rows = <List<String>>[
      ['Chest', UnitConverter.formatCmWithInches(m.chestCm)],
      ['Waist', UnitConverter.formatCmWithInches(m.waistCm)],
      ['Hip', UnitConverter.formatCmWithInches(m.hipCm)],
      ['Shoulder Width', UnitConverter.formatCmWithInches(m.shoulderWidthCm)],
      ['Neck', UnitConverter.formatCmWithInches(m.neckCm)],
      ['Sleeve Length', UnitConverter.formatCmWithInches(m.sleeveLengthCm)],
      ['Arm Length', UnitConverter.formatCmWithInches(m.armLengthCm)],
      ['Inseam Length', UnitConverter.formatCmWithInches(m.inseamCm)],
      ['Height', UnitConverter.formatCmWithInches(m.heightCm)],
    ];

    return pw.Table(
      border: pw.TableBorder.symmetric(inside: const pw.BorderSide(color: PdfColors.grey300)),
      columnWidths: {
        0: const pw.FlexColumnWidth(1.3),
        1: const pw.FlexColumnWidth(2),
      },
      children: rows
          .map(
            (r) => pw.TableRow(
              children: [
                pw.Padding(
                  padding: const pw.EdgeInsets.symmetric(vertical: 6, horizontal: 4),
                  child: pw.Text(r[0], style: const pw.TextStyle(fontSize: 10)),
                ),
                pw.Padding(
                  padding: const pw.EdgeInsets.symmetric(vertical: 6, horizontal: 4),
                  child: pw.Text(r[1], style: const pw.TextStyle(fontSize: 10)),
                ),
              ],
            ),
          )
          .toList(),
    );
  }
}
