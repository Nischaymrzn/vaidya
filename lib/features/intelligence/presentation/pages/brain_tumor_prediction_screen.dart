import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:vaidya/features/intelligence/presentation/services/intelligence_report_service.dart';
import 'package:vaidya/features/intelligence/presentation/view_model/prediction_viewmodel.dart';
import 'package:vaidya/themes/colors.dart';

class BrainTumorPredictionScreen extends ConsumerStatefulWidget {
  const BrainTumorPredictionScreen({super.key});

  @override
  ConsumerState<BrainTumorPredictionScreen> createState() =>
      _BrainTumorPredictionScreenState();
}

class _BrainTumorPredictionScreenState
    extends ConsumerState<BrainTumorPredictionScreen> {
  bool _headache = false;
  bool _vision = false;
  bool _dizziness = false;
  bool _seizures = false;
  String _ageGroup = 'adult';
  String _severity = 'mild';
  String? _imagePath;
  String? _errorText;
  Map<String, dynamic>? _result;

  Future<void> _pickImage() async {
    final picked = await FilePicker.platform.pickFiles(
      type: FileType.image,
      allowMultiple: false,
    );
    if (picked == null || picked.files.isEmpty) return;
    final path = picked.files.single.path;
    if (path == null) return;
    setState(() => _imagePath = path);
  }

  Future<void> _analyze() async {
    FocusScope.of(context).unfocus();
    setState(() => _errorText = null);

    if (_imagePath == null || _imagePath!.trim().isEmpty) {
      setState(() => _errorText = 'Please upload an MRI scan image before analysis.');
      return;
    }

    final ok = await ref
        .read(predictionViewModelProvider.notifier)
        .predictBrainTumor(_imagePath!);
    final state = ref.read(predictionViewModelProvider);

    if (!mounted) return;

    if (!ok) {
      setState(
        () => _errorText = state.errorMessage ?? 'Unable to generate prediction.',
      );
      return;
    }

    setState(() {
      _result = Map<String, dynamic>.from(
        state.brainTumor?.data ?? const <String, dynamic>{},
      );
    });
  }

  Future<void> _downloadReport() async {
    if (_result == null) return;
    final probability = (_result?['probability'] ?? '--').toString();
    final prediction = (_result?['prediction'] ?? '--').toString();

    final insights = ((_result?['insights'] as List?) ?? const [])
        .whereType<Map>()
        .map((e) {
          final m = e.cast<String, dynamic>();
          final title = (m['title'] ?? '').toString().trim();
          final desc = (m['description'] ?? '').toString().trim();
          return title.isEmpty ? desc : '$title: $desc';
        })
        .where((e) => e.isNotEmpty)
        .toList(growable: false);

    final path = await IntelligenceReportService.downloadPredictionReport(
      filename: 'brain-tumor-risk-report.pdf',
      title: 'Brain Tumor Risk Report',
      summary: 'Prediction is "$prediction" with confidence $probability%.',
      metrics: [
        PredictionReportMetric(label: 'Prediction', value: prediction),
        PredictionReportMetric(label: 'Probability', value: '$probability%'),
        PredictionReportMetric(label: 'Age group', value: _ageGroup),
        PredictionReportMetric(label: 'Symptom severity', value: _severity),
        PredictionReportMetric(label: 'Persistent headaches', value: _yesNo(_headache)),
        PredictionReportMetric(label: 'Vision changes', value: _yesNo(_vision)),
        PredictionReportMetric(label: 'Dizziness', value: _yesNo(_dizziness)),
        PredictionReportMetric(label: 'Seizures', value: _yesNo(_seizures)),
      ],
      findings: insights,
      recommendations: const [
        'Consult a clinician for moderate/high risk outputs.',
        'Upload follow-up MRI scans to refine trend interpretation.',
        'Track neurological symptoms consistently.',
      ],
    );
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Report downloaded to: $path',
          style: const TextStyle(fontFamily: 'Urbanist'),
        ),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(predictionViewModelProvider);
    final isSubmitting = state.isSubmitting;
    final probability = (_result?['probability']?.toString() ?? '--');
    final prediction = (_result?['prediction']?.toString() ?? 'Waiting');
    final insights = ((_result?['insights'] as List?) ?? const [])
        .whereType<Map>()
        .map((e) => e.cast<String, dynamic>())
        .toList(growable: false);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        scrolledUnderElevation: 0,
        title: const Text(
          'Brain Tumor Prediction',
          style: TextStyle(
            color: AppColors.textPrimary,
            fontSize: 20,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Upload MRI scans and track neurological signals for AI-based risk estimation.',
              style: TextStyle(
                color: AppColors.textSecondary,
                fontSize: 13,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 12),
            _panel(
              title: 'Scan and signals',
              child: Column(
                children: [
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      onPressed: _pickImage,
                      icon: const Icon(Icons.upload_rounded),
                      label: Text(
                        _imagePath == null ? 'Upload MRI scan image' : 'Change MRI scan image',
                      ),
                      style: OutlinedButton.styleFrom(
                        minimumSize: const Size.fromHeight(46),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ),
                  if (_imagePath != null) ...[
                    const SizedBox(height: 10),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: Image.file(
                        File(_imagePath!),
                        height: 170,
                        width: double.infinity,
                        fit: BoxFit.cover,
                      ),
                    ),
                  ],
                  const SizedBox(height: 10),
                  _switchTile(
                    label: 'Persistent headaches',
                    value: _headache,
                    onChanged: (v) => setState(() => _headache = v),
                  ),
                  _switchTile(
                    label: 'Vision changes',
                    value: _vision,
                    onChanged: (v) => setState(() => _vision = v),
                  ),
                  _switchTile(
                    label: 'Dizziness',
                    value: _dizziness,
                    onChanged: (v) => setState(() => _dizziness = v),
                  ),
                  _switchTile(
                    label: 'Seizures',
                    value: _seizures,
                    onChanged: (v) => setState(() => _seizures = v),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(
                        child: DropdownButtonFormField<String>(
                          initialValue: _ageGroup,
                          decoration: InputDecoration(
                            labelText: 'Age group',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            isDense: true,
                          ),
                          items: const [
                            DropdownMenuItem(value: 'youth', child: Text('Below 18')),
                            DropdownMenuItem(value: 'adult', child: Text('18-50')),
                            DropdownMenuItem(value: 'senior', child: Text('50+')),
                          ],
                          onChanged: (v) {
                            if (v != null) setState(() => _ageGroup = v);
                          },
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: DropdownButtonFormField<String>(
                          initialValue: _severity,
                          decoration: InputDecoration(
                            labelText: 'Symptom severity',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            isDense: true,
                          ),
                          items: const [
                            DropdownMenuItem(value: 'mild', child: Text('Mild')),
                            DropdownMenuItem(value: 'moderate', child: Text('Moderate')),
                            DropdownMenuItem(value: 'severe', child: Text('Severe')),
                          ],
                          onChanged: (v) {
                            if (v != null) setState(() => _severity = v);
                          },
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: isSubmitting ? null : _analyze,
                      style: ElevatedButton.styleFrom(
                        minimumSize: const Size.fromHeight(46),
                        backgroundColor: AppColors.primary,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(999),
                        ),
                      ),
                      child: Text(
                        isSubmitting ? 'Analyzing...' : 'Analyze brain tumor risk',
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            _panel(
              title: 'AI analysis',
              child: Column(
                children: [
                  _kv('Prediction', prediction),
                  _kv('Probability', probability == '--' ? '--' : '$probability%'),
                  const SizedBox(height: 10),
                  if (_errorText != null)
                    Container(
                      width: double.infinity,
                      margin: const EdgeInsets.only(bottom: 10),
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFEF2F2),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: const Color(0xFFFECACA)),
                      ),
                      child: Text(
                        _errorText!,
                        style: const TextStyle(
                          color: Color(0xFFB91C1C),
                          fontSize: 12.5,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      onPressed: _result == null ? null : _downloadReport,
                      icon: const Icon(Icons.download_rounded, size: 18),
                      label: const Text('Download report PDF'),
                      style: OutlinedButton.styleFrom(
                        minimumSize: const Size.fromHeight(44),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(999),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            _panel(
              title: 'Next steps',
              child: insights.isEmpty
                  ? const Text(
                      'Generate a prediction to view personalized insights.',
                      style: TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                      ),
                    )
                  : Column(
                      children: insights
                          .map(
                            (insight) => Container(
                              width: double.infinity,
                              margin: const EdgeInsets.only(bottom: 8),
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(14),
                                border: Border.all(color: AppColors.border),
                                color: const Color(0xFFF8FAFC),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    (insight['title'] ?? '').toString(),
                                    style: const TextStyle(
                                      color: AppColors.textPrimary,
                                      fontSize: 14,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  const SizedBox(height: 3),
                                  Text(
                                    (insight['description'] ?? '').toString(),
                                    style: const TextStyle(
                                      color: AppColors.textSecondary,
                                      fontSize: 13,
                                      fontWeight: FontWeight.w500,
                                      height: 1.3,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          )
                          .toList(),
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _panel({required String title, required Widget child}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              color: AppColors.textPrimary,
              fontSize: 20 / 1.2,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 10),
          child,
        ],
      ),
    );
  }

  Widget _switchTile({
    required String label,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              label,
              style: const TextStyle(
                color: AppColors.textSecondary,
                fontSize: 13.5,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Switch.adaptive(value: value, onChanged: onChanged),
        ],
      ),
    );
  }

  Widget _kv(String k, String v) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        children: [
          Expanded(
            child: Text(
              k,
              style: const TextStyle(
                color: AppColors.textSecondary,
                fontSize: 13,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Text(
            v,
            style: const TextStyle(
              color: AppColors.textPrimary,
              fontSize: 13,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  String _yesNo(bool value) => value ? 'Yes' : 'No';
}
