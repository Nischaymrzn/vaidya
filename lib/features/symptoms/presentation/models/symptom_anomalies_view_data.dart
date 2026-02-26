import 'package:vaidya/features/intelligence/domain/entities/prediction_entity.dart';

class SymptomAnomaliesViewData {
  final String summary;
  final List<SymptomAnomalyConditionViewData> conditions;

  const SymptomAnomaliesViewData({
    required this.summary,
    required this.conditions,
  });

  bool get hasData => conditions.isNotEmpty;

  factory SymptomAnomaliesViewData.fromPrediction(
    PredictionEntity? prediction,
  ) {
    final data = prediction?.data ?? const <String, dynamic>{};
    final summary = (data['analysisSummary'] ?? '').toString().trim();
    final rawTop = data['finalTop3'];

    final parsed = <SymptomAnomalyConditionViewData>[];
    if (rawTop is List) {
      for (final item in rawTop) {
        if (item is! Map) continue;
        final map = item.map((k, v) => MapEntry(k.toString(), v));
        final disease = (map['disease'] ?? '').toString().trim();
        if (disease.isEmpty) continue;
        final probability =
            double.tryParse((map['probability'] ?? 0).toString()) ?? 0;
        final explanation = (map['explanation'] ?? '').toString().trim();
        parsed.add(
          SymptomAnomalyConditionViewData(
            disease: disease,
            probability: probability.clamp(0, 100),
            explanation: explanation,
          ),
        );
      }
    }

    return SymptomAnomaliesViewData(summary: summary, conditions: parsed);
  }
}

class SymptomAnomalyConditionViewData {
  final String disease;
  final double probability;
  final String explanation;

  const SymptomAnomalyConditionViewData({
    required this.disease,
    required this.probability,
    required this.explanation,
  });

  String get priority => probability >= 60 ? 'High Priority' : 'Low Priority';

  String get initials {
    final chunks = disease
        .split(RegExp(r'\s+'))
        .where((part) => part.trim().isNotEmpty)
        .take(2)
        .map((part) => part.trim()[0].toUpperCase())
        .toList(growable: false);
    if (chunks.isEmpty) return 'NA';
    return chunks.join();
  }
}
