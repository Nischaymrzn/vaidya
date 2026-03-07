import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

class PredictionReportMetric {
  final String label;
  final String value;
  final String? note;

  const PredictionReportMetric({
    required this.label,
    required this.value,
    this.note,
  });
}

class IntelligenceReportService {
  const IntelligenceReportService._();

  static Future<String> downloadRiskAnalysisReport({
    required Map<String, dynamic> assessment,
    List<Map<String, dynamic>> insights = const [],
  }) async {
    final id = (assessment['_id'] ?? assessment['id'] ?? '').toString();
    final riskLevel = (assessment['riskLevel'] ?? 'N/A').toString();
    final riskScore = assessment['riskScore']?.toString() ?? 'N/A';
    final confidence = assessment['confidenceScore']?.toString() ?? 'N/A';
    final analysis = (assessment['analysis'] as Map?)?.cast<String, dynamic>() ??
        const <String, dynamic>{};
    final summary = (analysis['summary'] ?? 'No summary available.').toString();

    final keyFindingsRaw = (analysis['keyFindings'] as List?) ?? const [];
    final keyFindings = keyFindingsRaw
        .whereType<Map>()
        .map((e) {
          final m = e.cast<String, dynamic>();
          final title = (m['title'] ?? '').toString().trim();
          final detail = (m['detail'] ?? '').toString().trim();
          if (title.isEmpty && detail.isEmpty) return null;
          return title.isEmpty ? detail : '$title: $detail';
        })
        .whereType<String>()
        .toList(growable: false);

    final fallbackInsights = insights
        .map((e) {
          final title = (e['insightTitle'] ?? '').toString().trim();
          final desc = (e['description'] ?? '').toString().trim();
          if (title.isEmpty && desc.isEmpty) return null;
          return title.isEmpty ? desc : '$title: $desc';
        })
        .whereType<String>()
        .toList(growable: false);

    final sections =
        (analysis['sections'] as Map?)?.cast<String, dynamic>() ??
            const <String, dynamic>{};

    final metrics = <PredictionReportMetric>[
      PredictionReportMetric(label: 'Risk level', value: riskLevel),
      PredictionReportMetric(label: 'Risk score', value: riskScore),
      PredictionReportMetric(label: 'Confidence', value: confidence),
      PredictionReportMetric(label: 'Assessment ID', value: id.isEmpty ? 'N/A' : id),
    ];

    final findings =
        keyFindings.isNotEmpty ? keyFindings : fallbackInsights;

    final recommendations =
        ((analysis['recommendations'] as List?) ?? const [])
            .map((e) => e.toString())
            .where((e) => e.trim().isNotEmpty)
            .toList(growable: false);

    final details = <String>[
      'Vitals: ${(sections['vitals'] ?? 'N/A').toString()}',
      'Symptoms: ${(sections['symptoms'] ?? 'N/A').toString()}',
      'Records: ${(sections['records'] ?? 'N/A').toString()}',
      'Medications: ${(sections['medications'] ?? 'N/A').toString()}',
      'Allergies: ${(sections['allergies'] ?? 'N/A').toString()}',
      'Immunizations: ${(sections['immunizations'] ?? 'N/A').toString()}',
    ];

    return _savePdf(
      filename: 'risk-analysis-report.pdf',
      title: 'Risk Analysis Report',
      subtitle: 'Vaidya.ai',
      summary: summary,
      metrics: metrics,
      findings: findings,
      recommendations: recommendations,
      notes: details,
    );
  }

  static Future<String> downloadPredictionReport({
    required String filename,
    required String title,
    required String summary,
    required List<PredictionReportMetric> metrics,
    List<String> findings = const [],
    List<String> recommendations = const [],
    List<String> notes = const [],
  }) async {
    return _savePdf(
      filename: filename,
      title: title,
      subtitle: 'Vaidya.ai',
      summary: summary,
      metrics: metrics,
      findings: findings,
      recommendations: recommendations,
      notes: notes,
    );
  }

  static Future<void> shareRiskAnalysisReport({
    required Map<String, dynamic> assessment,
    List<Map<String, dynamic>> insights = const [],
  }) async {
    final bytes = await _buildRiskAnalysisPdfBytes(
      assessment: assessment,
      insights: insights,
    );
    await Printing.sharePdf(bytes: bytes, filename: 'risk-analysis-report.pdf');
  }

  static Future<void> sharePredictionReport({
    required String filename,
    required String title,
    required String summary,
    required List<PredictionReportMetric> metrics,
    List<String> findings = const [],
    List<String> recommendations = const [],
    List<String> notes = const [],
  }) async {
    final bytes = await _buildPdfBytes(
      title: title,
      subtitle: 'Vaidya.ai',
      summary: summary,
      metrics: metrics,
      findings: findings,
      recommendations: recommendations,
      notes: notes,
    );
    await Printing.sharePdf(bytes: bytes, filename: filename);
  }

  static Future<String> _savePdf({
    required String filename,
    required String title,
    required String subtitle,
    required String summary,
    required List<PredictionReportMetric> metrics,
    required List<String> findings,
    required List<String> recommendations,
    required List<String> notes,
  }) async {
    final bytes = await _buildPdfBytes(
      title: title,
      subtitle: subtitle,
      summary: summary,
      metrics: metrics,
      findings: findings,
      recommendations: recommendations,
      notes: notes,
    );
    return _persistPdfToDisk(filename: filename, bytes: bytes);
  }

  static Future<Uint8List> _buildRiskAnalysisPdfBytes({
    required Map<String, dynamic> assessment,
    required List<Map<String, dynamic>> insights,
  }) async {
    final id = (assessment['_id'] ?? assessment['id'] ?? '').toString();
    final riskLevel = (assessment['riskLevel'] ?? 'N/A').toString();
    final riskScore = assessment['riskScore']?.toString() ?? 'N/A';
    final confidence = assessment['confidenceScore']?.toString() ?? 'N/A';
    final analysis = (assessment['analysis'] as Map?)?.cast<String, dynamic>() ??
        const <String, dynamic>{};
    final summary = (analysis['summary'] ?? 'No summary available.').toString();

    final keyFindingsRaw = (analysis['keyFindings'] as List?) ?? const [];
    final keyFindings = keyFindingsRaw
        .whereType<Map>()
        .map((e) {
          final m = e.cast<String, dynamic>();
          final title = (m['title'] ?? '').toString().trim();
          final detail = (m['detail'] ?? '').toString().trim();
          if (title.isEmpty && detail.isEmpty) return null;
          return title.isEmpty ? detail : '$title: $detail';
        })
        .whereType<String>()
        .toList(growable: false);

    final fallbackInsights = insights
        .map((e) {
          final title = (e['insightTitle'] ?? '').toString().trim();
          final desc = (e['description'] ?? '').toString().trim();
          if (title.isEmpty && desc.isEmpty) return null;
          return title.isEmpty ? desc : '$title: $desc';
        })
        .whereType<String>()
        .toList(growable: false);

    final sections =
        (analysis['sections'] as Map?)?.cast<String, dynamic>() ??
            const <String, dynamic>{};

    final metrics = <PredictionReportMetric>[
      PredictionReportMetric(label: 'Risk level', value: riskLevel),
      PredictionReportMetric(label: 'Risk score', value: riskScore),
      PredictionReportMetric(label: 'Confidence', value: confidence),
      PredictionReportMetric(label: 'Assessment ID', value: id.isEmpty ? 'N/A' : id),
    ];

    final findings = keyFindings.isNotEmpty ? keyFindings : fallbackInsights;

    final recommendations = ((analysis['recommendations'] as List?) ?? const [])
        .map((e) => e.toString())
        .where((e) => e.trim().isNotEmpty)
        .toList(growable: false);

    final details = <String>[
      'Vitals: ${(sections['vitals'] ?? 'N/A').toString()}',
      'Symptoms: ${(sections['symptoms'] ?? 'N/A').toString()}',
      'Records: ${(sections['records'] ?? 'N/A').toString()}',
      'Medications: ${(sections['medications'] ?? 'N/A').toString()}',
      'Allergies: ${(sections['allergies'] ?? 'N/A').toString()}',
      'Immunizations: ${(sections['immunizations'] ?? 'N/A').toString()}',
    ];

    return _buildPdfBytes(
      title: 'Risk Analysis Report',
      subtitle: 'Vaidya.ai',
      summary: summary,
      metrics: metrics,
      findings: findings,
      recommendations: recommendations,
      notes: details,
    );
  }

  static Future<Uint8List> _buildPdfBytes({
    required String title,
    required String subtitle,
    required String summary,
    required List<PredictionReportMetric> metrics,
    required List<String> findings,
    required List<String> recommendations,
    required List<String> notes,
  }) async {
    final doc = pw.Document();
    final generatedAt = DateTime.now();
    final reportNumber =
        'RPT-${generatedAt.millisecondsSinceEpoch.toString().substring(5)}';

    doc.addPage(
      pw.MultiPage(
        pageTheme: const pw.PageTheme(
          margin: pw.EdgeInsets.fromLTRB(28, 26, 28, 28),
        ),
        footer: (context) => pw.Align(
          alignment: pw.Alignment.centerRight,
          child: pw.Text(
            'Page ${context.pageNumber}/${context.pagesCount}',
            style: const pw.TextStyle(
              fontSize: 9.5,
              color: PdfColor.fromInt(0xFF64748B),
            ),
          ),
        ),
        build: (context) => [
          pw.Container(
            padding: const pw.EdgeInsets.fromLTRB(14, 12, 14, 12),
            decoration: pw.BoxDecoration(
              color: PdfColor.fromInt(0xFF1F7AE0),
              borderRadius: pw.BorderRadius.circular(12),
            ),
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Text(
                  title,
                  style: pw.TextStyle(
                    color: PdfColors.white,
                    fontWeight: pw.FontWeight.bold,
                    fontSize: 19,
                  ),
                ),
                pw.SizedBox(height: 3),
                pw.Text(
                  subtitle,
                  style: const pw.TextStyle(
                    color: PdfColors.white,
                    fontSize: 11.2,
                  ),
                ),
                pw.SizedBox(height: 10),
                pw.Container(
                  width: double.infinity,
                  padding: const pw.EdgeInsets.all(8),
                  decoration: pw.BoxDecoration(
                    color: PdfColor.fromInt(0x3AFFFFFF),
                    borderRadius: pw.BorderRadius.circular(8),
                    border: pw.Border.all(color: PdfColor.fromInt(0x66FFFFFF)),
                  ),
                  child: pw.Row(
                    mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                    children: [
                      pw.Text(
                        'Generated: ${_formatDateTime(generatedAt)}',
                        style: const pw.TextStyle(
                          color: PdfColors.white,
                          fontSize: 10.5,
                        ),
                      ),
                      pw.Text(
                        'Report #$reportNumber',
                        style: const pw.TextStyle(
                          color: PdfColors.white,
                          fontSize: 10.5,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          pw.SizedBox(height: 12),
          _sectionCard(
            title: 'Executive summary',
            child: pw.Text(
              summary,
              style: const pw.TextStyle(
                fontSize: 11.4,
                color: PdfColor.fromInt(0xFF334155),
                lineSpacing: 2,
              ),
            ),
          ),
          pw.SizedBox(height: 10),
          _sectionCard(
            title: 'Assessment metrics',
            child: _metricGrid(metrics),
          ),
          pw.SizedBox(height: 10),
          _sectionCard(
            title: 'Clinical findings',
            child: _bulletList(
              findings.isEmpty ? const ['No findings available.'] : findings,
            ),
          ),
          pw.SizedBox(height: 10),
          _sectionCard(
            title: 'Recommendations',
            child: _bulletList(
              recommendations.isEmpty
                  ? const ['No recommendations available.']
                  : recommendations,
            ),
          ),
          if (notes.isNotEmpty) ...[
            pw.SizedBox(height: 10),
            _sectionCard(title: 'Additional notes', child: _bulletList(notes)),
          ],
        ],
      ),
    );

    return doc.save();
  }

  static Future<String> _persistPdfToDisk({
    required String filename,
    required Uint8List bytes,
  }) async {
    final safeName = filename.trim().isEmpty
        ? 'report-${DateTime.now().millisecondsSinceEpoch}.pdf'
        : filename.trim();
    final directory = await _resolveDownloadDirectory();
    final filePath = p.join(directory.path, safeName);
    final file = File(filePath);
    await file.writeAsBytes(bytes, flush: true);
    return file.path;
  }

  static Future<Directory> _resolveDownloadDirectory() async {
    if (kIsWeb) {
      return getTemporaryDirectory();
    }

    if (Platform.isAndroid) {
      final publicDownloads = Directory('/storage/emulated/0/Download');
      if (await _ensureDirectory(publicDownloads)) {
        return publicDownloads;
      }

      final androidDownloads = await getDownloadsDirectory();
      if (androidDownloads != null && await _ensureDirectory(androidDownloads)) {
        return androidDownloads;
      }

      final external = await getExternalStorageDirectory();
      if (external != null) {
        final downloadDir = Directory(p.join(external.path, 'Download'));
        if (await _ensureDirectory(downloadDir)) {
          return downloadDir;
        }
      }
    }

    final docs = await getApplicationDocumentsDirectory();
    final downloadDir = Directory(p.join(docs.path, 'downloads'));
    await _ensureDirectory(downloadDir);
    return downloadDir;
  }

  static Future<bool> _ensureDirectory(Directory directory) async {
    try {
      if (!await directory.exists()) {
        await directory.create(recursive: true);
      }
      return true;
    } catch (_) {
      return false;
    }
  }

  static pw.Widget _metricGrid(List<PredictionReportMetric> metrics) {
    if (metrics.isEmpty) {
      return pw.Text(
        'No metrics available.',
        style: const pw.TextStyle(
          fontSize: 11,
          color: PdfColor.fromInt(0xFF64748B),
        ),
      );
    }

    return pw.Wrap(
      spacing: 8,
      runSpacing: 8,
      children: metrics
          .map(
            (metric) => pw.Container(
              width: 245,
              padding: const pw.EdgeInsets.fromLTRB(10, 8, 10, 8),
              decoration: pw.BoxDecoration(
                color: PdfColor.fromInt(0xFFF8FAFC),
                borderRadius: pw.BorderRadius.circular(8),
                border: pw.Border.all(color: PdfColor.fromInt(0xFFD9E0EA)),
              ),
              child: pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Text(
                    metric.label.toUpperCase(),
                    style: pw.TextStyle(
                      fontSize: 9.5,
                      color: PdfColor.fromInt(0xFF64748B),
                      fontWeight: pw.FontWeight.bold,
                    ),
                  ),
                  pw.SizedBox(height: 4),
                  pw.Text(
                    metric.value,
                    style: pw.TextStyle(
                      fontSize: 14,
                      color: PdfColor.fromInt(0xFF0F172A),
                      fontWeight: pw.FontWeight.bold,
                    ),
                  ),
                  if (metric.note != null && metric.note!.trim().isNotEmpty) ...[
                    pw.SizedBox(height: 2),
                    pw.Text(
                      metric.note!,
                      style: const pw.TextStyle(
                        fontSize: 9.8,
                        color: PdfColor.fromInt(0xFF475569),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          )
          .toList(growable: false),
    );
  }

  static pw.Widget _sectionCard({
    required String title,
    required pw.Widget child,
  }) {
    return pw.Container(
      width: double.infinity,
      padding: const pw.EdgeInsets.fromLTRB(12, 10, 12, 10),
      decoration: pw.BoxDecoration(
        color: PdfColor.fromInt(0xFFFFFFFF),
        borderRadius: pw.BorderRadius.circular(10),
        border: pw.Border.all(color: PdfColor.fromInt(0xFFD9E0EA)),
      ),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text(
            title,
            style: pw.TextStyle(
              color: PdfColor.fromInt(0xFF0F172A),
              fontWeight: pw.FontWeight.bold,
              fontSize: 12.8,
            ),
          ),
          pw.SizedBox(height: 7),
          child,
        ],
      ),
    );
  }

  static pw.Widget _bulletList(List<String> lines) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: lines
          .asMap()
          .entries
          .map(
            (entry) => pw.Padding(
              padding: const pw.EdgeInsets.only(bottom: 5),
              child: pw.Row(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Container(
                    width: 16,
                    alignment: pw.Alignment.topLeft,
                    child: pw.Text(
                      '${entry.key + 1}.',
                      style: pw.TextStyle(
                        fontSize: 10.5,
                        color: PdfColor.fromInt(0xFF0F172A),
                        fontWeight: pw.FontWeight.bold,
                      ),
                    ),
                  ),
                  pw.Expanded(
                    child: pw.Text(
                      entry.value,
                      style: const pw.TextStyle(
                        fontSize: 11,
                        color: PdfColor.fromInt(0xFF334155),
                        lineSpacing: 1.7,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          )
          .toList(growable: false),
    );
  }

  static String _formatDateTime(DateTime dateTime) {
    String two(int value) => value.toString().padLeft(2, '0');
    return '${dateTime.year}-${two(dateTime.month)}-${two(dateTime.day)} '
        '${two(dateTime.hour)}:${two(dateTime.minute)}';
  }
}
