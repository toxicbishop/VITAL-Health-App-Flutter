import 'dart:io';
import 'package:pdf/widgets.dart' as pw;
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import '../data/models.dart';

class ClinicalReportService {
  static Future<void> exportToPdf(List<LogEntry> logs, String userName) async {
    final pdf = pw.Document();

    pdf.addPage(
      pw.MultiPage(
        header: (pw.Context context) => pw.Row(
          mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
          children: [
            pw.Text(
              'VITAL Clinical Health Report',
              style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 18),
            ),
            pw.Text(userName),
          ],
        ),
        footer: (pw.Context context) => pw.Align(
          alignment: pw.Alignment.centerRight,
          child: pw.Text(
            'Report Generated on ${DateTime.now().toIso8601String().split('T')[0]}',
          ),
        ),
        build: (pw.Context context) => [
          pw.Header(level: 0, text: 'Monthly Log Summary'),
          pw.TableHelper.fromTextArray(
            headers: ['Date', 'Type', 'Value', 'Notes'],
            data: logs
                .map(
                  (l) => [
                    l.timestamp.toIso8601String().split('T')[0],
                    l.logType,
                    l.value,
                    l.notes ?? '',
                  ],
                )
                .toList(),
          ),
        ],
      ),
    );

    final dir = await getTemporaryDirectory();
    final file = File(
      '${dir.path}/VITAL_Report_${DateTime.now().millisecondsSinceEpoch}.pdf',
    );
    await file.writeAsBytes(await pdf.save());

    await SharePlus.instance.share(
      ShareParams(files: [XFile(file.path)], text: 'Health logs for $userName'),
    );
  }
}
