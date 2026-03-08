import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:intl/intl.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:permission_handler/permission_handler.dart';
import 'package:printing/printing.dart';

class PredictionReportMetric {
  final String label;
  final String value;
  final String? reference;
  final String? status;
  final String? unit;
  final String? note;

  const PredictionReportMetric({
    required this.label,
    required this.value,
    this.reference,
    this.status,
    this.unit,
    this.note,
  });
}

class PredictionReportPatient {
  final String? name;
  final String? age;
  final String? sex;
  final String? pid;

  const PredictionReportPatient({this.name, this.age, this.sex, this.pid});
}

class PredictionReportMeta {
  final String? module;
  final String? collectedAt;
  final String? referredBy;
  final String? reportId;

  const PredictionReportMeta({
    this.module,
    this.collectedAt,
    this.referredBy,
    this.reportId,
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
    final analysis =
        (assessment['analysis'] as Map?)?.cast<String, dynamic>() ??
        const <String, dynamic>{};
    final summary = (analysis['summary'] ?? 'No summary available.').toString();
    final demographics = (analysis['demographics'] as Map?)
        ?.cast<String, dynamic>();
    final vitalsSnapshot = (analysis['vitalsSnapshot'] as Map?)
        ?.cast<String, dynamic>();

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
      PredictionReportMetric(
        label: 'Assessment ID',
        value: id.isEmpty ? 'N/A' : id,
      ),
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

    return _savePdf(
      filename: 'risk-analysis-report.pdf',
      title: 'Risk Analysis Report',
      subtitle: 'Vaidya.ai',
      summary: summary,
      metrics: metrics,
      patient: PredictionReportPatient(
        name: (demographics?['name'] ?? 'Member').toString(),
        age: demographics?['age']?.toString(),
        sex: demographics?['gender']?.toString(),
        pid: id.isEmpty ? null : id,
      ),
      meta: PredictionReportMeta(
        module: 'Risk Analysis',
        collectedAt: vitalsSnapshot?['recordedAt']?.toString(),
        referredBy: 'Vaidya AI',
        reportId: id.isEmpty ? null : id,
      ),
      comments: [summary],
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
    PredictionReportPatient? patient,
    PredictionReportMeta? meta,
    List<String> comments = const [],
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
      patient: patient,
      meta: meta,
      comments: comments,
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
    PredictionReportPatient? patient,
    PredictionReportMeta? meta,
    List<String> comments = const [],
    List<String> findings = const [],
    List<String> recommendations = const [],
    List<String> notes = const [],
  }) async {
    final bytes = await _buildPdfBytes(
      title: title,
      subtitle: 'Vaidya.ai',
      summary: summary,
      metrics: metrics,
      patient: patient,
      meta: meta,
      comments: comments,
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
    PredictionReportPatient? patient,
    PredictionReportMeta? meta,
    List<String> comments = const [],
    required List<String> findings,
    required List<String> recommendations,
    required List<String> notes,
  }) async {
    final bytes = await _buildPdfBytes(
      title: title,
      subtitle: subtitle,
      summary: summary,
      metrics: metrics,
      patient: patient,
      meta: meta,
      comments: comments,
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
    final analysis =
        (assessment['analysis'] as Map?)?.cast<String, dynamic>() ??
        const <String, dynamic>{};
    final summary = (analysis['summary'] ?? 'No summary available.').toString();
    final demographics = (analysis['demographics'] as Map?)
        ?.cast<String, dynamic>();
    final vitalsSnapshot = (analysis['vitalsSnapshot'] as Map?)
        ?.cast<String, dynamic>();

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
      PredictionReportMetric(
        label: 'Assessment ID',
        value: id.isEmpty ? 'N/A' : id,
      ),
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
      patient: PredictionReportPatient(
        name: (demographics?['name'] ?? 'Member').toString(),
        age: demographics?['age']?.toString(),
        sex: demographics?['gender']?.toString(),
        pid: id.isEmpty ? null : id,
      ),
      meta: PredictionReportMeta(
        module: 'Risk Analysis',
        collectedAt: vitalsSnapshot?['recordedAt']?.toString(),
        referredBy: 'Vaidya AI',
        reportId: id.isEmpty ? null : id,
      ),
      comments: [summary],
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
    PredictionReportPatient? patient,
    PredictionReportMeta? meta,
    List<String> comments = const [],
    required List<String> findings,
    required List<String> recommendations,
    required List<String> notes,
  }) async {
    final doc = await _createPdfDocument();
    final generatedAt = DateTime.now();
    final reportNumber = meta?.reportId?.trim().isNotEmpty == true
        ? meta!.reportId!.trim()
        : 'VA-${generatedAt.millisecondsSinceEpoch.toString().substring(5)}';
    final summaryComment = summary.trim().isNotEmpty
        ? summary.trim()
        : 'No summary available.';
    final clinicalComments = comments
        .where((e) => e.trim().isNotEmpty)
        .toList(growable: false);
    final effectiveComments = clinicalComments.isEmpty
        ? <String>[summaryComment]
        : clinicalComments;
    final collectedAt = _displayDate(meta?.collectedAt);
    final patientName = _displayValue(patient?.name, fallback: 'Member');
    final patientAge = _displayValue(patient?.age);
    final patientSex = _displayValue(patient?.sex);
    final patientPid = _displayValue(patient?.pid, fallback: reportNumber);
    final module = _displayValue(meta?.module, fallback: title);
    final referredBy = _displayValue(meta?.referredBy, fallback: subtitle);

    doc.addPage(
      pw.MultiPage(
        pageTheme: const pw.PageTheme(
          margin: pw.EdgeInsets.fromLTRB(24, 20, 24, 30),
        ),
        header: (_) => _header(generatedAt),
        footer: (context) => pw.Align(
          alignment: pw.Alignment.bottomCenter,
          child: pw.Container(
            padding: const pw.EdgeInsets.only(top: 6),
            child: pw.Column(
              mainAxisSize: pw.MainAxisSize.min,
              children: [
                pw.Divider(
                  color: PdfColor.fromInt(0xFFD9E0EA),
                  thickness: 0.7,
                  height: 0,
                ),
                pw.SizedBox(height: 4),
                pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  children: [
                    pw.Text(
                      'Generated on: ${_formatDateTime(generatedAt)}',
                      style: const pw.TextStyle(
                        fontSize: 8.2,
                        color: PdfColor.fromInt(0xFF64748B),
                      ),
                    ),
                    pw.Text(
                      'Page ${context.pageNumber} of ${context.pagesCount}',
                      style: const pw.TextStyle(
                        fontSize: 8.2,
                        color: PdfColor.fromInt(0xFF64748B),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
        build: (context) => [
          pw.Text(
            title.toUpperCase(),
            style: pw.TextStyle(
              color: PdfColor.fromInt(0xFF0F172A),
              fontWeight: pw.FontWeight.bold,
              fontSize: 16,
              letterSpacing: 0.2,
            ),
          ),
          pw.SizedBox(height: 8),
          pw.Divider(
            color: PdfColor.fromInt(0xFFD9E0EA),
            thickness: 1,
            height: 0,
          ),
          pw.SizedBox(height: 10),
          _patientMetaGrid(
            patientName: patientName,
            patientAge: patientAge,
            patientSex: patientSex,
            patientPid: patientPid,
            collectedAt: collectedAt,
            referredBy: referredBy,
            module: module,
            reportNumber: reportNumber,
          ),
          pw.SizedBox(height: 10),
          _sectionCard(
            title: 'Investigation Summary',
            child: _metricTable(metrics),
          ),
          pw.SizedBox(height: 10),
          _sectionCard(
            title: 'Clinical Comments',
            child: _bulletList(effectiveComments, numbered: false),
          ),
          pw.SizedBox(height: 10),
          _sectionCard(
            title: 'AI Findings',
            child: _bulletList(
              findings.isEmpty ? const ['No findings available.'] : findings,
              numbered: true,
            ),
          ),
          pw.SizedBox(height: 10),
          _sectionCard(
            title: 'Recommendations',
            child: _bulletList(
              recommendations.isEmpty
                  ? const ['No recommendations available.']
                  : recommendations,
              numbered: true,
            ),
          ),
          if (notes.isNotEmpty) ...[
            pw.SizedBox(height: 10),
            _sectionCard(
              title: 'Additional Notes',
              child: _bulletList(notes, numbered: false),
            ),
          ],
          pw.SizedBox(height: 12),
          _signatureStrip(),
          pw.SizedBox(height: 8),
          pw.Text(
            'This report is AI-assisted and should be interpreted with clinical judgment.',
            style: const pw.TextStyle(
              fontSize: 8.6,
              color: PdfColor.fromInt(0xFF64748B),
            ),
          ),
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
      await _requestStoragePermission();
      final publicDownloads = Directory('/storage/emulated/0/Download');
      if (await _ensureDirectory(publicDownloads)) {
        return publicDownloads;
      }

      final androidDownloads = await getDownloadsDirectory();
      if (androidDownloads != null &&
          await _ensureDirectory(androidDownloads)) {
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

  static Future<void> _requestStoragePermission() async {
    try {
      if (!Platform.isAndroid) return;
      final storage = await Permission.storage.request();
      if (!storage.isGranted && !storage.isLimited) {
        await Permission.manageExternalStorage.request();
      }
    } catch (_) {
      // Ignore; fallback paths will still be used.
    }
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

  static pw.Widget _header(DateTime generatedAt) {
    return pw.Container(
      width: double.infinity,
      padding: const pw.EdgeInsets.fromLTRB(12, 9, 12, 9),
      decoration: pw.BoxDecoration(
        color: PdfColor.fromInt(0xFF232E3D),
        borderRadius: pw.BorderRadius.circular(10),
      ),
      child: pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Text(
                'VAIDYA DIAGNOSTIC REPORT',
                style: pw.TextStyle(
                  color: PdfColors.white,
                  fontWeight: pw.FontWeight.bold,
                  fontSize: 13.2,
                ),
              ),
              pw.SizedBox(height: 2),
              pw.Text(
                'Accurate | Caring | Instant',
                style: const pw.TextStyle(
                  color: PdfColor.fromInt(0xFFD1DEED),
                  fontSize: 9.2,
                ),
              ),
            ],
          ),
          pw.Text(
            'Generated on ${_formatDateTime(generatedAt)}',
            style: const pw.TextStyle(
              color: PdfColor.fromInt(0xFFD1DEED),
              fontSize: 8.8,
            ),
          ),
        ],
      ),
    );
  }

  static pw.Widget _patientMetaGrid({
    required String patientName,
    required String patientAge,
    required String patientSex,
    required String patientPid,
    required String collectedAt,
    required String referredBy,
    required String module,
    required String reportNumber,
  }) {
    return pw.Row(
      children: [
        pw.Expanded(
          child: _infoCard([
            ('Patient Name', patientName),
            ('Age', patientAge),
            ('Sex', patientSex),
            ('PID', patientPid),
          ]),
        ),
        pw.SizedBox(width: 10),
        pw.Expanded(
          child: _infoCard([
            ('Sample Collected', collectedAt),
            ('Ref. By', referredBy),
            ('Module', module),
            ('Report ID', reportNumber),
          ]),
        ),
      ],
    );
  }

  static pw.Widget _infoCard(List<(String, String)> rows) {
    return pw.Container(
      padding: const pw.EdgeInsets.fromLTRB(10, 8, 10, 8),
      decoration: pw.BoxDecoration(
        color: PdfColor.fromInt(0xFFF8FAFC),
        borderRadius: pw.BorderRadius.circular(8),
        border: pw.Border.all(color: PdfColor.fromInt(0xFFD9E0EA)),
      ),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: rows
            .map(
              (row) => pw.Padding(
                padding: const pw.EdgeInsets.only(bottom: 3),
                child: pw.Row(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Expanded(
                      flex: 3,
                      child: pw.Text(
                        '${row.$1}:',
                        style: pw.TextStyle(
                          fontSize: 8.8,
                          color: PdfColor.fromInt(0xFF334155),
                          fontWeight: pw.FontWeight.bold,
                        ),
                      ),
                    ),
                    pw.Expanded(
                      flex: 4,
                      child: pw.Text(
                        row.$2,
                        style: const pw.TextStyle(
                          fontSize: 8.8,
                          color: PdfColor.fromInt(0xFF334155),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            )
            .toList(growable: false),
      ),
    );
  }

  static pw.Widget _metricTable(List<PredictionReportMetric> metrics) {
    final normalized = metrics.isEmpty
        ? const [
            PredictionReportMetric(
              label: 'No investigations supplied',
              value: 'N/A',
              reference: 'N/A',
              status: 'Info',
              unit: '-',
            ),
          ]
        : metrics;
    final headers = ['Investigation', 'Result', 'Reference', 'Status', 'Unit'];
    final rows = normalized
        .map((metric) {
          final reference = metric.reference ?? metric.note ?? 'N/A';
          final status = metric.status ?? 'Info';
          final unit = metric.unit ?? '-';
          return <String>[metric.label, metric.value, reference, status, unit];
        })
        .toList(growable: false);
    final tableData = <List<String>>[headers, ...rows];

    return pw.TableHelper.fromTextArray(
      data: tableData,
      headerStyle: pw.TextStyle(
        fontWeight: pw.FontWeight.bold,
        color: PdfColor.fromInt(0xFF334155),
        fontSize: 8.8,
      ),
      cellStyle: const pw.TextStyle(
        color: PdfColor.fromInt(0xFF334155),
        fontSize: 8.5,
      ),
      headerDecoration: const pw.BoxDecoration(
        color: PdfColor.fromInt(0xFFE8EDF5),
      ),
      cellHeight: 22,
      headerHeight: 24,
      border: pw.TableBorder.all(color: PdfColor.fromInt(0xFFD9E0EA)),
      cellPadding: const pw.EdgeInsets.fromLTRB(6, 5, 6, 5),
      columnWidths: {
        0: const pw.FlexColumnWidth(2.8),
        1: const pw.FlexColumnWidth(1.4),
        2: const pw.FlexColumnWidth(1.4),
        3: const pw.FlexColumnWidth(1.2),
        4: const pw.FlexColumnWidth(1.0),
      },
    );
  }

  static pw.Widget _signatureStrip() {
    const labels = ['Medical Lab Technician', 'Pathologist', 'Consultant'];
    return pw.Row(
      children: labels
          .map(
            (label) => pw.Expanded(
              child: pw.Padding(
                padding: const pw.EdgeInsets.symmetric(horizontal: 3),
                child: pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.center,
                  children: [
                    pw.Divider(
                      color: PdfColor.fromInt(0xFFBFCAD8),
                      thickness: 0.7,
                      height: 0,
                    ),
                    pw.SizedBox(height: 3),
                    pw.Text(
                      label,
                      style: pw.TextStyle(
                        fontSize: 8.2,
                        fontWeight: pw.FontWeight.bold,
                        color: PdfColor.fromInt(0xFF475569),
                      ),
                    ),
                  ],
                ),
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

  static pw.Widget _bulletList(List<String> lines, {required bool numbered}) {
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
                    width: numbered ? 16 : 10,
                    alignment: pw.Alignment.topLeft,
                    child: pw.Text(
                      numbered ? '${entry.key + 1}.' : '-',
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

  static String _displayDate(String? input) {
    if (input == null || input.trim().isEmpty) {
      return DateFormat('MMM d, yyyy').format(DateTime.now());
    }
    final parsed = DateTime.tryParse(input);
    if (parsed == null) return input;
    return DateFormat('MMM d, yyyy').format(parsed.toLocal());
  }

  static String _displayValue(String? input, {String fallback = 'N/A'}) {
    if (input == null) return fallback;
    final trimmed = input.trim();
    return trimmed.isEmpty ? fallback : trimmed;
  }

  static Future<pw.Document> _createPdfDocument() async {
    try {
      final regular = pw.Font.ttf(
        await rootBundle.load('assets/fonts/Urbanist-Regular.ttf'),
      );
      final medium = pw.Font.ttf(
        await rootBundle.load('assets/fonts/Urbanist-Medium.ttf'),
      );
      final bold = pw.Font.ttf(
        await rootBundle.load('assets/fonts/Urbanist-Bold.ttf'),
      );

      return pw.Document(
        theme: pw.ThemeData.withFont(
          base: regular,
          bold: bold,
          italic: medium,
          boldItalic: bold,
        ),
      );
    } catch (_) {
      return pw.Document();
    }
  }

  static String _formatDateTime(DateTime dateTime) {
    return DateFormat('MMM d, yyyy HH:mm').format(dateTime.toLocal());
  }
}
