import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:vaidya/core/services/storage/user_session_service.dart';
import 'package:vaidya/core/utils/snackbar_utils.dart';
import 'package:vaidya/core/widgets/app_button_styles.dart';
import 'package:vaidya/features/intelligence/presentation/services/intelligence_report_service.dart';
import 'package:vaidya/features/intelligence/presentation/services/premium_report_access_service.dart';
import 'package:vaidya/features/intelligence/presentation/view_model/prediction_viewmodel.dart';
import 'package:vaidya/themes/colors.dart';

class DiabetesPredictionScreen extends ConsumerStatefulWidget {
  const DiabetesPredictionScreen({super.key});

  @override
  ConsumerState<DiabetesPredictionScreen> createState() =>
      _DiabetesPredictionScreenState();
}

class _DiabetesPredictionScreenState
    extends ConsumerState<DiabetesPredictionScreen> {
  final _formKey = GlobalKey<FormState>();
  final _glucoseController = TextEditingController();
  final _hba1cController = TextEditingController();
  final _bmiController = TextEditingController();
  final _ageController = TextEditingController();
  final _bpController = TextEditingController();

  String _familyHistory = 'no';
  String? _errorText;
  Map<String, dynamic>? _result;

  @override
  void dispose() {
    _glucoseController.dispose();
    _hba1cController.dispose();
    _bmiController.dispose();
    _ageController.dispose();
    _bpController.dispose();
    super.dispose();
  }

  Future<void> _analyze() async {
    FocusScope.of(context).unfocus();
    setState(() => _errorText = null);
    if (!(_formKey.currentState?.validate() ?? false)) return;

    final glucose = double.parse(_glucoseController.text.trim());
    final bmi = double.parse(_bmiController.text.trim());
    final age = int.parse(_ageController.text.trim());
    final bp = double.parse(_bpController.text.trim());
    final pedigree = _familyHistory == 'yes' ? 0.78 : 0.32;

    final payload = <String, dynamic>{
      'Pregnancies': 0,
      'Glucose': glucose,
      'BloodPressure': bp,
      'SkinThickness': 20,
      'Insulin': 79,
      'BMI': bmi,
      'DiabetesPedigreeFunction': pedigree,
      'Age': age,
    };

    final ok = await ref
        .read(predictionViewModelProvider.notifier)
        .predictDiabetes(payload);
    final state = ref.read(predictionViewModelProvider);

    if (!mounted) return;

    if (!ok) {
      setState(
        () =>
            _errorText = state.errorMessage ?? 'Unable to generate prediction.',
      );
      return;
    }

    setState(() {
      _result = Map<String, dynamic>.from(
        state.diabetes?.data ?? const <String, dynamic>{},
      );
    });
  }

  Future<void> _downloadReport() async {
    if (_result == null) {
      SnackbarUtils.showWarning(
        context,
        'Run diabetes analysis before downloading report.',
      );
      return;
    }
    final allowed = await PremiumReportAccessService.ensurePremiumAccess(
      context,
      ref,
    );
    if (!allowed) return;
    final probability = (_result?['probability'] ?? '--').toString();
    final riskLevel = (_result?['riskLevel'] ?? 'Low').toString();
    final predictionLabel = (_result?['prediction'] ?? '--').toString();

    final findings = ((_result?['insights'] as List?) ?? const [])
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
        filename: 'diabetes-risk-report.pdf',
        title: 'Diabetes Risk Report',
        summary:
            'Predicted diabetes probability is $probability% ($riskLevel risk).',
        patient: PredictionReportPatient(
          name: 'Member',
          age: _ageController.text.trim(),
          sex: 'N/A',
        ),
        meta: PredictionReportMeta(
          module: 'Diabetes Prediction',
          collectedAt: DateTime.now().toIso8601String(),
          referredBy: 'Vaidya AI',
        ),
        comments: [
          'Run analysis to view personalized insights and recommendations.',
        ],
        metrics: [
          PredictionReportMetric(
            label: 'Probability',
            value: '$probability%',
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
            value: predictionLabel,
            reference: 'Model output',
            status: 'AI',
            unit: '-',
          ),
          PredictionReportMetric(
            label: 'Fasting glucose',
            value: _glucoseController.text.trim(),
            reference: '70-99',
            status: riskLevel,
            unit: 'mg/dL',
          ),
          PredictionReportMetric(
            label: 'HbA1c',
            value: _hba1cController.text.trim(),
            reference: '<5.7',
            status: riskLevel,
            unit: '%',
          ),
          PredictionReportMetric(
            label: 'BMI',
            value: _bmiController.text.trim(),
            reference: '18.5-24.9',
            status: riskLevel,
            unit: 'kg/m2',
          ),
          PredictionReportMetric(
            label: 'Age',
            value: _ageController.text.trim(),
            reference: 'Adult',
            status: 'Input',
            unit: 'years',
          ),
          PredictionReportMetric(
            label: 'Blood pressure',
            value: _bpController.text.trim(),
            reference: '90-120',
            status: riskLevel,
            unit: 'mmHg',
          ),
        ],
        findings: findings,
        recommendations: const [
          'Continue periodic glucose and HbA1c monitoring.',
          'Keep BMI and blood pressure within target range.',
          'Review moderate/high risk outputs with your clinician.',
        ],
      );
      if (!mounted) return;
      final fileName = path.split(RegExp(r'[/\\\\]')).last.trim();
      SnackbarUtils.showSuccess(
        context,
        fileName.isEmpty
            ? 'Diabetes report downloaded successfully.'
            : 'Diabetes report downloaded: $fileName',
      );
    } catch (e) {
      if (!mounted) return;
      SnackbarUtils.showError(
        context,
        'Unable to download diabetes report. Please try again.',
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
    final riskLevel = (_result?['riskLevel'] ?? 'Waiting').toString();
    final probability = (_result?['probability']?.toString() ?? '--');
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
          'Diabetes Prediction',
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
              'Fast risk estimation based on metabolic markers and lifestyle signals.',
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
                          child: _field(
                            _glucoseController,
                            'Fasting glucose (mg/dL)',
                            '95',
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: _field(_hba1cController, 'HbA1c (%)', '5.4'),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        Expanded(child: _field(_bmiController, 'BMI', '23.4')),
                        const SizedBox(width: 10),
                        Expanded(
                          child: _field(
                            _ageController,
                            'Age',
                            '32',
                            isInt: true,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        Expanded(
                          child: _field(
                            _bpController,
                            'Blood pressure (systolic)',
                            '118',
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: DropdownButtonFormField<String>(
                            initialValue: _familyHistory,
                            decoration: InputDecoration(
                              labelText: 'Family history',
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              isDense: true,
                            ),
                            items: const [
                              DropdownMenuItem(value: 'no', child: Text('No')),
                              DropdownMenuItem(
                                value: 'yes',
                                child: Text('Yes'),
                              ),
                            ],
                            onChanged: (v) {
                              if (v != null) setState(() => _familyHistory = v);
                            },
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
                          isSubmitting
                              ? 'Analyzing...'
                              : 'Analyze diabetes risk',
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
                        'Risk score',
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
                    probability == '--' ? '--' : '$probability%',
                    style: TextStyle(
                      color: AppColors.textPrimary,
                      fontSize: 32,
                      fontWeight: FontWeight.w600,
                    ),
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
              title: 'Lifestyle recommendations',
              child: insights.isEmpty
                  ? Text(
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

  Widget _field(
    TextEditingController controller,
    String label,
    String hint, {
    bool isInt = false,
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
        if (isInt) {
          if (int.tryParse(value.trim()) == null) return 'Invalid';
        } else {
          if (double.tryParse(value.trim()) == null) return 'Invalid';
        }
        return null;
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
}

