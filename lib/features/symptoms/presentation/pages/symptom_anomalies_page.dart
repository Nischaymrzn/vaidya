import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:vaidya/features/intelligence/presentation/state/prediction_state.dart';
import 'package:vaidya/features/intelligence/presentation/view_model/prediction_viewmodel.dart';
import 'package:vaidya/features/symptoms/presentation/models/symptom_anomalies_view_data.dart';
import 'package:vaidya/themes/colors.dart';

class SymptomAnomaliesPage extends ConsumerStatefulWidget {
  const SymptomAnomaliesPage({super.key});

  @override
  ConsumerState<SymptomAnomaliesPage> createState() =>
      _SymptomAnomaliesPageState();
}

class _SymptomAnomaliesPageState extends ConsumerState<SymptomAnomaliesPage> {
  static const _minSymptoms = 1;

  final TextEditingController _inputController = TextEditingController();
  final List<String> _symptoms = <String>[];
  bool _analysisRequested = false;

  @override
  void dispose() {
    _inputController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(predictionViewModelProvider);
    final viewData = SymptomAnomaliesViewData.fromPrediction(state.symptom);

    ref.listen<PredictionState>(predictionViewModelProvider, (prev, next) {
      if (next.errorMessage != null &&
          next.errorMessage != prev?.errorMessage) {
        _show(next.errorMessage!, error: true);
      }
    });

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        foregroundColor: AppColors.textPrimary,
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: IconButton(
          onPressed: () => Navigator.of(context).pop(),
          icon: const Icon(LucideIcons.arrowLeft),
        ),
        title: const Text(
          'Health Anomalies',
          style: TextStyle(
            fontFamily: 'Urbanist',
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
      ),
      body: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 720),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Enter your symptoms, and our AI will suggest possible health conditions',
                style: TextStyle(
                  fontFamily: 'Urbanist',
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: 12),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.fromLTRB(14, 14, 14, 14),
                decoration: BoxDecoration(
                  color: AppColors.card,
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(color: AppColors.border),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: _inputController,
                            onSubmitted: _addSymptom,
                            style: const TextStyle(
                              fontFamily: 'Urbanist',
                              fontSize: 15,
                              fontWeight: FontWeight.w500,
                              color: AppColors.textPrimary,
                            ),
                            decoration: InputDecoration(
                              hintText: 'Breathlessness',
                              hintStyle: const TextStyle(
                                fontFamily: 'Urbanist',
                                fontSize: 15,
                                fontWeight: FontWeight.w500,
                                color: AppColors.textSecondary,
                              ),
                              prefixIcon: const Icon(
                                LucideIcons.search,
                                size: 16,
                                color: AppColors.textSecondary,
                              ),
                              filled: true,
                              fillColor: const Color(0xFFF8FAFC),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: const BorderSide(
                                  color: AppColors.border,
                                ),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: const BorderSide(
                                  color: AppColors.primary,
                                ),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        OutlinedButton(
                          onPressed: () => _addSymptom(_inputController.text),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: AppColors.textSecondary,
                            side: const BorderSide(color: AppColors.border),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 13,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: const Text(
                            'Add',
                            style: TextStyle(
                              fontFamily: 'Urbanist',
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Add at least $_minSymptoms symptom${_minSymptoms > 1 ? 's' : ''} to improve accuracy.',
                      style: const TextStyle(
                        fontFamily: 'Urbanist',
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                        color: AppColors.textSecondary,
                      ),
                    ),
                    if (_symptoms.isNotEmpty) ...[
                      const SizedBox(height: 10),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: _symptoms
                            .map((symptom) {
                              return Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 10,
                                  vertical: 6,
                                ),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFE5E7EB),
                                  borderRadius: BorderRadius.circular(999),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Text(
                                      symptom,
                                      style: const TextStyle(
                                        fontFamily: 'Urbanist',
                                        fontSize: 14,
                                        fontWeight: FontWeight.w500,
                                        color: AppColors.textPrimary,
                                      ),
                                    ),
                                    const SizedBox(width: 4),
                                    GestureDetector(
                                      onTap: () => _removeSymptom(symptom),
                                      child: const Icon(
                                        Icons.close,
                                        size: 14,
                                        color: AppColors.textSecondary,
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            })
                            .toList(growable: false),
                      ),
                    ],
                    const SizedBox(height: 10),
                    SizedBox(
                      width: double.infinity,
                      child: FilledButton(
                        onPressed:
                            _symptoms.length < _minSymptoms ||
                                state.isSubmitting
                            ? null
                            : _analyze,
                        style: FilledButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          foregroundColor: Colors.white,
                          disabledBackgroundColor: const Color(0xFFE2E8F0),
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: Text(
                          state.isSubmitting
                              ? 'Analyzing...'
                              : 'Analyze symptoms',
                          style: const TextStyle(
                            fontFamily: 'Urbanist',
                            fontSize: 17,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'Results',
                style: TextStyle(
                  fontFamily: 'Urbanist',
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 10),
              _ResultsSection(
                analysisRequested: _analysisRequested,
                isLoading: state.isSubmitting,
                errorMessage: state.errorMessage,
                viewData: viewData,
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _addSymptom(String value) {
    final text = value.trim();
    if (text.isEmpty) return;
    final exists = _symptoms.any(
      (item) => item.toLowerCase() == text.toLowerCase(),
    );
    if (exists) {
      _inputController.clear();
      return;
    }
    setState(() {
      _symptoms.add(text);
      _inputController.clear();
      _analysisRequested = false;
    });
  }

  void _removeSymptom(String symptom) {
    setState(() {
      _symptoms.removeWhere((item) => item == symptom);
      _analysisRequested = false;
    });
  }

  List<String> _normalizeSymptoms(List<String> values) {
    String normalize(String value) {
      return value
          .toLowerCase()
          .trim()
          .replaceAll(RegExp(r'[^a-z0-9]+'), '_')
          .replaceAll(RegExp(r'_+'), '_')
          .replaceAll(RegExp(r'^_+|_+$'), '');
    }

    final set = <String>{};
    for (final symptom in values) {
      final normalized = normalize(symptom);
      if (normalized.isNotEmpty) {
        set.add(normalized);
      }
    }
    return set.toList(growable: false);
  }

  Future<void> _analyze() async {
    final normalized = _normalizeSymptoms(_symptoms);
    if (normalized.length < _minSymptoms) {
      _show('Please add at least $_minSymptoms symptom.', error: true);
      return;
    }

    setState(() => _analysisRequested = true);
    await ref
        .read(predictionViewModelProvider.notifier)
        .predictSymptom(normalized);
  }

  void _show(String message, {bool error = false}) {
    if (!mounted) return;
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(
            message,
            style: const TextStyle(fontFamily: 'Urbanist'),
          ),
          behavior: SnackBarBehavior.floating,
          backgroundColor: error ? const Color(0xFFDC2626) : null,
        ),
      );
  }
}

class _ResultsSection extends StatelessWidget {
  final bool analysisRequested;
  final bool isLoading;
  final String? errorMessage;
  final SymptomAnomaliesViewData viewData;

  const _ResultsSection({
    required this.analysisRequested,
    required this.isLoading,
    required this.errorMessage,
    required this.viewData,
  });

  @override
  Widget build(BuildContext context) {
    if (!analysisRequested) {
      return _hintCard(
        'Add symptoms above and tap "Analyze symptoms" to see possible conditions.',
      );
    }
    if (isLoading) {
      return _hintCard('Analyzing your symptoms...');
    }
    if (errorMessage != null && errorMessage!.trim().isNotEmpty) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: const Color(0xFFFEF2F2),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: const Color(0xFFFCA5A5)),
        ),
        child: Text(
          errorMessage!,
          style: const TextStyle(
            fontFamily: 'Urbanist',
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: Color(0xFFB91C1C),
          ),
        ),
      );
    }
    if (!viewData.hasData) {
      return _hintCard('No predictions available yet. Please try again.');
    }

    final topConditions = viewData.conditions.take(3).toList(growable: false);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.only(left: 2, bottom: 8),
          child: Text(
            'Top predictions',
            style: TextStyle(
              fontFamily: 'Urbanist',
              fontSize: 17,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
        ),
        ...topConditions.map(
          (condition) => _PredictionCard(condition: condition),
        ),
        if (viewData.summary.isNotEmpty)
          Container(
            width: double.infinity,
            margin: const EdgeInsets.only(top: 2),
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: AppColors.card,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: AppColors.border),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Summary',
                  style: TextStyle(
                    fontFamily: 'Urbanist',
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textSecondary,
                    letterSpacing: .7,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  viewData.summary,
                  style: const TextStyle(
                    fontFamily: 'Urbanist',
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: AppColors.textPrimary,
                    height: 1.3,
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }

  Widget _hintCard(String text) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border),
      ),
      child: Text(
        text,
        textAlign: TextAlign.center,
        style: const TextStyle(
          fontFamily: 'Urbanist',
          fontSize: 14,
          fontWeight: FontWeight.w500,
          color: AppColors.textSecondary,
        ),
      ),
    );
  }
}

class _PredictionCard extends StatelessWidget {
  final SymptomAnomalyConditionViewData condition;

  const _PredictionCard({required this.condition});

  @override
  Widget build(BuildContext context) {
    final probability = condition.probability.clamp(0, 100).toDouble();
    final color = _colorFor(probability);
    final confidenceText = '${probability.toStringAsFixed(0)}% confidence';

    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.fromLTRB(10, 10, 10, 10),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              color: color,
            ),
            alignment: Alignment.center,
            child: Text(
              condition.initials,
              style: const TextStyle(
                fontFamily: 'Urbanist',
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  condition.disease,
                  style: const TextStyle(
                    fontFamily: 'Urbanist',
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  '${condition.priority}    2 Suggestions',
                  style: const TextStyle(
                    fontFamily: 'Urbanist',
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 5),
                ClipRRect(
                  borderRadius: BorderRadius.circular(999),
                  child: LinearProgressIndicator(
                    value: probability / 100,
                    minHeight: 3.5,
                    color: color,
                    backgroundColor: const Color(0xFFE5E7EB),
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  confidenceText,
                  style: const TextStyle(
                    fontFamily: 'Urbanist',
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Color _colorFor(double probability) {
    if (probability >= 70) return const Color(0xFFF43F5E);
    if (probability >= 45) return const Color(0xFFF59E0B);
    return const Color(0xFF14B8A6);
  }
}
