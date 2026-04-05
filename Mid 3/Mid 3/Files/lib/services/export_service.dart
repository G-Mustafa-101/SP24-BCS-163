import 'dart:io';

import 'package:csv/csv.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:share_plus/share_plus.dart';

import '../models/task_item.dart';

class ExportService {
  Future<void> exportCsv(List<TaskItem> tasks) async {
    final rows = <List<String>>[
      ['Title', 'Description', 'Due', 'Status', 'Repeat', 'Progress'],
    ];

    for (final task in tasks) {
      rows.add([
        task.title,
        task.description,
        task.dueDateTime.toIso8601String(),
        task.isCompleted ? 'Completed' : 'Pending',
        task.repeatSummary,
        '${(task.progress * 100).round()}%',
      ]);
    }

    final csv = const ListToCsvConverter().convert(rows);
    final file = await _writeFile('tasks_export.csv', csv.codeUnits);
    await SharePlus.instance.share(ShareParams(files: [XFile(file.path)]));
  }

  Future<void> exportPdf(List<TaskItem> tasks) async {
    final document = pw.Document();
    document.addPage(
      pw.MultiPage(
        pageTheme: pw.PageTheme(
          theme: pw.ThemeData.withFont(
            base: pw.Font.helvetica(),
            bold: pw.Font.helveticaBold(),
          ),
          margin: const pw.EdgeInsets.all(24),
        ),
        build: (context) => [
          pw.Text(
            'Task Sprint Pro Export',
            style: pw.TextStyle(
              fontSize: 24,
              fontWeight: pw.FontWeight.bold,
              color: PdfColors.blueGrey900,
            ),
          ),
          pw.SizedBox(height: 12),
          ...tasks.map(
            (task) => pw.Container(
              margin: const pw.EdgeInsets.only(bottom: 10),
              padding: const pw.EdgeInsets.all(12),
              decoration: pw.BoxDecoration(
                borderRadius: pw.BorderRadius.circular(10),
                border: pw.Border.all(color: PdfColors.blueGrey200),
              ),
              child: pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Text(
                    task.title,
                    style: pw.TextStyle(
                      fontSize: 16,
                      fontWeight: pw.FontWeight.bold,
                    ),
                  ),
                  pw.SizedBox(height: 4),
                  pw.Text(task.description.isEmpty ? 'No description' : task.description),
                  pw.SizedBox(height: 4),
                  pw.Text('Due: ${task.dueDateTime}'),
                  pw.Text('Repeat: ${task.repeatSummary}'),
                  pw.Text('Progress: ${(task.progress * 100).round()}%'),
                ],
              ),
            ),
          ),
        ],
      ),
    );

    final file = await _writeFile('tasks_export.pdf', await document.save());
    await SharePlus.instance.share(ShareParams(files: [XFile(file.path)]));
  }

  Future<void> exportEmail(List<TaskItem> tasks) async {
    final body = tasks
        .map(
          (task) =>
              '${task.title}\nDue: ${task.dueDateTime}\nStatus: ${task.isCompleted ? 'Completed' : 'Pending'}\nProgress: ${(task.progress * 100).round()}%',
        )
        .join('\n\n');

    await SharePlus.instance.share(
      ShareParams(
        subject: 'Task Sprint Pro Export',
        text: body,
      ),
    );
  }

  Future<File> _writeFile(String fileName, List<int> bytes) async {
    final directory = await getTemporaryDirectory();
    final file = File(p.join(directory.path, fileName));
    return file.writeAsBytes(bytes, flush: true);
  }
}
