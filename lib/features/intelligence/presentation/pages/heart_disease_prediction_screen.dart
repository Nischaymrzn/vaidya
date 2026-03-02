import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:vaidya/core/services/storage/user_session_service.dart';
import 'package:vaidya/core/utils/snackbar_utils.dart';
import 'package:vaidya/core/widgets/app_button_styles.dart';
import 'package:vaidya/features/intelligence/presentation/services/intelligence_report_service.dart';
import 'package:vaidya/features/intelligence/presentation/services/premium_report_access_service.dart';
import 'package:vaidya/features/intelligence/presentation/view_model/prediction_viewmodel.dart';
import 'package:vaidya/themes/colors.dart';

class HeartDiseasePredictionScreen extends ConsumerStatefulWidget {
  const HeartDiseasePredictionScreen({super.key});

  @override
  ConsumerState<HeartDiseasePredictionScreen> createState() =>
      _HeartDiseasePredictionScreenState();
}

class _HeartDiseasePredictionScreenState
    extends ConsumerState<HeartDiseasePredictionScreen> {
  final _formKey = GlobalKey<FormState>();
  final _ageController = TextEditingController();
  final _bmiController = TextEditingController();
  final _hba1cController = TextEditingController();
  final _glucoseController = TextEditingController();

  String _gender = 'Female';
  String _smoking = 'No Info';
  String _hypertension = '0';
  String _cardiacHistory = '0';
  String? _errorText;
  Map<String, dynamic>? _result;

  @override
  void dispose() {
    _ageController.dispose();
    _bmiController.dispose();
    _hba1cController.dispose();
    _glucoseController.dispose();
    super.dispose();
  }

  Future<void> _analyze() async {
    FocusScope.of(context).unfocus();
    setState(() => _errorText = null);

    if (!(_formKey.currentState?.validate() ?? false)) {
      return;
    }

    final payload = <String, dynamic>{
      'gender': _gender,
      'smoking_history': _smoking,
      'age': _ageController.text.trim(),
      'bmi': _bmiController.text.trim(),
      'HbA1c_level': _hba1cController.text.trim(),
      'blood_glucose_level': _glucoseController.text.trim(),
      'hypertension': _hypertension,
      'heart_disease': _cardiacHistory,
    };

    final ok = await ref
        .read(predictionViewModelProvider.notifier)
        .predictHeartDisease(payload);
    final state = ref.read(predictionViewModelProvider);

    if (!mounted) {
      return;
    }

    if (!ok) {
      setState(
        () =>
            _errorText = state.errorMessage ?? 'Unable to generate prediction.',
      );
      return;
    }

    setState(() {
      _result = Map<String, dynamic>.from(
        state.heartDisease?.data ?? const <String, dynamic>{},
      );
    });
  }

  Future<void> _downloadReport() async {
    if (_result == null) {
      SnackbarUtils.showWarning(
        context,
        'Run heart disease analysis before downloading report.',
      );
      return;
    }
    final allowed = await PremiumReportAccessService.ensurePremiumAccess(
      context,
      ref,
    );
    if (!allowed) return;

    final probability = _readHeartProbability(_result);
    final riskLevel = (_result?['riskLevel'] ?? 'Low').toString();
    final summary = probability == null
        ? 'Heart disease prediction generated.'
        : 'Predicted heart disease probability is $probability% ($riskLevel risk).';

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

    try {
      final path = await IntelligenceReportService.downloadPredictionReport(
        filename: 'heart-disease-risk-report.pdf',
        title: 'Heart Disease Risk Report',
        summary: summary,
        patient: PredictionReportPatient(
          name: 'Member',
          age: _ageController.text.trim(),
          sex: _gender,
        ),
        meta: PredictionReportMeta(
          module: 'Heart Disease Prediction',
          collectedAt: DateTime.now().toIso8601String(),
          referredBy: 'Vaidya AI',
        ),
        comments: const [
          'Results combine your input with recent health history to fine-tune probability.',
        ],
        metrics: [
          PredictionReportMetric(
            label: 'Heart disease probability',
            value: probability == null ? 'N/A' : '$probability%',
            reference: '0-100',
            status: riskLevel,
            unit: '%',
          ),
          PredictionReportMetric(
            label: 'Risk level',
            value: riskLevel,
            reference: 'Low / Moderate / High',
            status: riskLevel,
            unit: '-',
          ),
          PredictionReportMetric(
            label: 'Prediction',
            value: _predictionLabel(_result?['prediction']),
            reference: 'Model output',
            status: 'AI',
            unit: '-',
          ),
          PredictionReportMetric(
            label: 'Age',
            value: _ageController.text.trim(),
            reference: 'Adult',
            status: 'Input',
            unit: 'years',
          ),
          PredictionReportMetric(
            label: 'BMI',
            value: _bmiController.text.trim(),
            reference: '18.5-24.9',
            status: riskLevel,
            unit: 'kg/m2',
          ),
          PredictionReportMetric(
            label: 'HbA1c',
            value: _hba1cController.text.trim(),
            reference: '<5.7',
            status: riskLevel,
            unit: '%',
          ),
          PredictionReportMetric(
            label: 'Blood glucose',
            value: _glucoseController.text.trim(),
            reference: '70-140',
            status: riskLevel,
            unit: 'mg/dL',
          ),
        ],
        findings: insights,
        recommendations: const [
          'Keep blood pressure and glucose tracking consistent.',
          'Review high/moderate risk outputs with a clinician.',
          'Update labs periodically for better confidence.',
        ],
      );
      if (!mounted) return;
      final fileName = path.split(RegExp(r'[/\\\\]')).last.trim();
      SnackbarUtils.showSuccess(
        context,
        fileName.isEmpty
            ? 'Heart disease report downloaded successfully.'
            : 'Heart disease report downloaded: $fileName',
      );
    } catch (_) {
      if (!mounted) return;
      SnackbarUtils.showError(
        context,
        'Unable to download heart disease report. Please try again.',
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(predictionViewModelProvider);
    final isPremium = ref
        .read(userSessionServiceProvider)
        .getCurrentUserIsPremium();
    final isSubmitting = state.isSubmitting;
    final probability = _readHeartProbability(_result);
    final nonHeart = _readNonHeartProbability(_result);
    final riskLevel = (_result?['riskLevel'] ?? 'Waiting').toString();
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
        title: Text(
          'Heart Disease Prediction',
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
            Text(
              'Personalized estimates based on blood pressure, metabolic markers, lifestyle, and history.',
              style: TextStyle(
                color: AppColors.textSecondary,
                fontSize: 13,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 12),
            _panel(
              title: 'Input profile',
              child: Form(
                key: _formKey,
                child: Column(
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: _dropdown(
                            label: 'Gender',
                            value: _gender,
                            items: const ['Female', 'Male'],
                            onChanged: (v) => setState(() => _gender = v),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: _dropdown(
                            label: 'Smoking history',
                            value: _smoking,
                            items: const [
                              'No Info',
                              'current',
                              'ever',
                              'former',
                              'never',
                              'not current',
                            ],
                            onChanged: (v) => setState(() => _smoking = v),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        Expanded(
                          child: _field(
                            controller: _ageController,
                            label: 'Age',
                            hint: '45',
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: _field(
                            controller: _bmiController,
                            label: 'BMI',
                            hint: '27.5',
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        Expanded(
                          child: _field(
                            controller: _hba1cController,
                            label: 'HbA1c (%)',
                            hint: '5.8',
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: _field(
                            controller: _glucoseController,
                            label: 'Blood glucose (mg/dL)',
                            hint: '118',
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        Expanded(
                          child: _dropdown(
                            label: 'Hypertension',
                            value: _hypertension,
                            items: const ['0', '1'],
                            labels: const {'0': 'No', '1': 'Yes'},
                            onChanged: (v) => setState(() => _hypertension = v),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: _dropdown(
                            label: 'Cardiac history',
                            value: _cardiacHistory,
                            items: const ['0', '1'],
                            labels: const {'0': 'No', '1': 'Yes'},
                            onChanged: (v) =>
                                setState(() => _cardiacHistory = v),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: isSubmitting ? null : _analyze,
                        style: ElevatedButton.styleFrom(
                          minimumSize: Size.fromHeight(46),
                          backgroundColor: AppColors.primary,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(999),
                          ),
                        ),
                        child: Text(
                          isSubmitting ? 'Analyzing...' : 'Analyze heart risk',
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 12),
            _panel(
              title: 'AI analysis',
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Heart disease probability',
                        style: TextStyle(
                          color: AppColors.textSecondary,
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      _pill(riskLevel),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    probability == null ? '--' : '$probability%',
                    style: TextStyle(
                      color: AppColors.textPrimary,
                      fontSize: 32,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 10),
                  _kv('Prediction', _predictionLabel(_result?['prediction'])),
                  _kv(
                    'Non-heart probability',
                    nonHeart == null ? '--' : '$nonHeart%',
                  ),
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
                      icon: Icon(
                        isPremium
                            ? Icons.download_rounded
                            : Icons.lock_outline_rounded,
                        size: 18,
                      ),
                      label: Text(
                        isPremium
                            ? 'Download report PDF'
                            : 'Unlock PDF download',
                      ),
                      style: AppButtonStyles.pillOutlined(),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            _panel(
              title: 'Insights & guidance',
              child: insights.isEmpty
                  ? Container(
                      width: double.infinity,
                      padding: EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: AppColors.border),
                        color: AppColors.surfaceSoft,
                      ),
                      child: Text(
                        'Generate a prediction to view personalized insights.',
                        style: TextStyle(
                          color: AppColors.textSecondary,
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    )
                  : Column(
                      children: insights
                          .map(
                            (insight) => Container(
                              width: double.infinity,
                              margin: const EdgeInsets.only(bottom: 8),
                              padding: EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(14),
                                border: Border.all(color: AppColors.border),
                                color: AppColors.surfaceSoft,
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    (insight['title'] ?? '').toString(),
                                    style: TextStyle(
                                      color: AppColors.textPrimary,
                                      fontSize: 14,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  const SizedBox(height: 3),
                                  Text(
                                    (insight['description'] ?? '').toString(),
                                    style: TextStyle(
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
      padding: EdgeInsets.all(14),
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
            style: TextStyle(
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

  Widget _field({
    required TextEditingController controller,
    required String label,
    required String hint,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        isDense: true,
      ),
      validator: (value) {
        if (value == null || value.trim().isEmpty) return 'Required';
        final n = double.tryParse(value.trim());
        if (n == null) return 'Invalid';
        return null;
      },
    );
  }

  Widget _dropdown({
    required String label,
    required String value,
    required List<String> items,
    required ValueChanged<String> onChanged,
    Map<String, String> labels = const {},
  }) {
    return DropdownButtonFormField<String>(
      initialValue: value,
      decoration: InputDecoration(
        labelText: label,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        isDense: true,
      ),
      items: items
          .map(
            (v) =>
                DropdownMenuItem<String>(value: v, child: Text(labels[v] ?? v)),
          )
          .toList(),
      onChanged: (v) {
        if (v != null) onChanged(v);
      },
    );
  }

  Widget _pill(String text) {
    Color bg;
    Color fg;
    switch (text.toLowerCase()) {
      case 'high':
        bg = const Color(0xFFFEF2F2);
        fg = const Color(0xFFB91C1C);
        break;
      case 'moderate':
        bg = const Color(0xFFFFFBEB);
        fg = const Color(0xFFB45309);
        break;
      case 'low':
        bg = const Color(0xFFECFDF5);
        fg = Color(0xFF047857);
        break;
      default:
        bg = AppColors.border;
        fg = const Color(0xFF334155);
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        text,
        style: TextStyle(color: fg, fontSize: 12, fontWeight: FontWeight.w600),
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
              style: TextStyle(
                color: AppColors.textSecondary,
                fontSize: 13,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Text(
            v,
            style: TextStyle(
              color: AppColors.textPrimary,
              fontSize: 13,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  String _predictionLabel(dynamic prediction) {
    if (prediction is num) {
      if (prediction == 1) return 'Heart disease likely';
      if (prediction == 0) return 'Heart disease unlikely';
    }
    return '--';
  }

  String? _readHeartProbability(Map<String, dynamic>? result) {
    if (result == null) return null;
    final probs = (result['probabilities'] as List?) ?? const [];
    for (final item in probs) {
      if (item is Map && item['label']?.toString() == '1') {
        return item['probability']?.toString();
      }
    }
    return result['probability']?.toString();
  }

  String? _readNonHeartProbability(Map<String, dynamic>? result) {
    if (result == null) return null;
    final probs = (result['probabilities'] as List?) ?? const [];
    for (final item in probs) {
      if (item is Map && item['label']?.toString() == '0') {
        return item['probability']?.toString();
      }
    }
    return null;
  }
}

