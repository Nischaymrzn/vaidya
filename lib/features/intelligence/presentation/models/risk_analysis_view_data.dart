import 'package:vaidya/features/intelligence/domain/entities/health_insight_entity.dart';
import 'package:vaidya/features/intelligence/domain/entities/risk_assessment_entity.dart';

class RiskAnalysisViewData {
  final String? latestAssessmentId;
  final bool analysisReady;
  final String riskLevel;
  final int? riskScore;
  final int? confidencePercent;
  final int? signalsAnalyzed;
  final String lastAnalyzedLabel;
  final String? primaryFocus;
  final String fullSummary;
  final List<RiskSummaryTileViewData> summaryTiles;
  final List<RiskTrendPointViewData> riskTrend;
  final List<RiskContributionViewData> contributions;
  final List<RiskSignalViewData> keySignals;
  final List<RiskInsightItemViewData> alertInsights;
  final List<RiskInsightItemViewData> improveInsights;
  final List<RiskSectionViewData> fullSections;

  const RiskAnalysisViewData({
    required this.latestAssessmentId,
    required this.analysisReady,
    required this.riskLevel,
    required this.riskScore,
    required this.confidencePercent,
    required this.signalsAnalyzed,
    required this.lastAnalyzedLabel,
    required this.primaryFocus,
    required this.fullSummary,
    required this.summaryTiles,
    required this.riskTrend,
    required this.contributions,
    required this.keySignals,
    required this.alertInsights,
    required this.improveInsights,
    required this.fullSections,
  });

  static String? resolveLatestAssessmentId(List<RiskAssessmentEntity> items) {
    final sorted = _sortedAssessments(items);
    if (sorted.isEmpty) return null;
    final latest = _pickLatest(sorted);
    final id = _stringOrNull(latest['_id']) ?? _stringOrNull(latest['id']);
    return id;
  }

  factory RiskAnalysisViewData.fromSources({
    required List<RiskAssessmentEntity> assessments,
    required List<HealthInsightEntity> insights,
  }) {
    final sorted = _sortedAssessments(assessments);
    final latest = _pickLatest(sorted);
    final latestAnalysis = _asMap(latest['analysis']);
    final sections = _asMap(latestAnalysis['sections']);
    final analysisReady = latestAnalysis.isNotEmpty;

    final latestAssessmentId =
        _stringOrNull(latest['_id']) ?? _stringOrNull(latest['id']);
    final riskScore = _toInt(latest['riskScore']);
    final confidencePercent = _confidenceToPercent(latest['confidenceScore']);
    final riskLevel = _normalizeRiskLevel(
      _stringOrNull(latest['riskLevel']),
      score: riskScore,
    );
    final signalsAnalyzed = sections.isEmpty
        ? null
        : sections.values
              .where((value) => value.toString().trim().isNotEmpty)
              .length;

    final lastAnalyzedDate =
        _toDate(latestAnalysis['generatedAt']) ??
        _toDate(latest['assessmentDate']) ??
        _toDate(latest['createdAt']) ??
        _toDate(latest['updatedAt']);

    final lastAnalyzedLabel = _formatDate(lastAnalyzedDate);
    final primaryFocus = _stringOrNull(latest['predictedCondition']);
    final fullSummary =
        _stringOrNull(latestAnalysis['summary']) ??
        'Run full analysis to generate a detailed health risk summary.';

    final summaryTiles = <RiskSummaryTileViewData>[
      RiskSummaryTileViewData(
        label: 'OVERALL RISK SCORE',
        value: riskScore != null ? '$riskScore%' : '--',
        detail: 'Weighted multi-disease index',
      ),
      RiskSummaryTileViewData(
        label: 'MODEL CONFIDENCE',
        value: confidencePercent != null ? '$confidencePercent%' : '--',
        detail: 'Based on data density',
      ),
      RiskSummaryTileViewData(
        label: 'SIGNALS ANALYZED',
        value: signalsAnalyzed != null ? '$signalsAnalyzed' : '--',
        detail: 'Vitals, symptoms, records',
      ),
      const RiskSummaryTileViewData(
        label: 'ACTIVE MODELS',
        value: '4',
        detail: 'Diabetes, heart, TB, brain',
      ),
    ];

    final riskTrend = _buildRiskTrend(sorted);
    final contributions = _buildContributions(analysisReady, latestAnalysis);
    final keySignals = _buildKeySignals(latestAnalysis, insights);
    final allInsights = _mapInsights(insights);
    final alertInsights = allInsights
        .where(
          (item) =>
              item.priority.toLowerCase() == 'high' ||
              item.priority.toLowerCase() == 'medium',
        )
        .toList(growable: false);
    final improveInsights = allInsights
        .where(
          (item) =>
              item.priority.toLowerCase() == 'low' ||
              item.priority.toLowerCase() == 'info',
        )
        .toList(growable: false);
    final fullSections = _buildFullSections(latestAnalysis);

    return RiskAnalysisViewData(
      latestAssessmentId: latestAssessmentId,
      analysisReady: analysisReady,
      riskLevel: riskLevel,
      riskScore: riskScore,
      confidencePercent: confidencePercent,
      signalsAnalyzed: signalsAnalyzed,
      lastAnalyzedLabel: lastAnalyzedLabel,
      primaryFocus: primaryFocus,
      fullSummary: fullSummary,
      summaryTiles: summaryTiles,
      riskTrend: riskTrend,
      contributions: contributions,
      keySignals: keySignals,
      alertInsights: alertInsights,
      improveInsights: improveInsights,
      fullSections: fullSections,
    );
  }

  static List<Map<String, dynamic>> _sortedAssessments(
    List<RiskAssessmentEntity> items,
  ) {
    final mapped = items.map((item) => item.data).toList(growable: false);
    final sorted = List<Map<String, dynamic>>.from(mapped);
    sorted.sort((a, b) {
      final bDate = _assessmentDate(b)?.millisecondsSinceEpoch ?? 0;
      final aDate = _assessmentDate(a)?.millisecondsSinceEpoch ?? 0;
      return bDate.compareTo(aDate);
    });
    return sorted;
  }

  static Map<String, dynamic> _pickLatest(List<Map<String, dynamic>> sorted) {
    if (sorted.isEmpty) return const <String, dynamic>{};
    for (final item in sorted) {
      final analysis = _asMap(item['analysis']);
      if (analysis.isNotEmpty) return item;
    }
    return sorted.first;
  }

  static DateTime? _assessmentDate(Map<String, dynamic> item) {
    final analysis = _asMap(item['analysis']);
    return _toDate(analysis['generatedAt']) ??
        _toDate(item['assessmentDate']) ??
        _toDate(item['createdAt']) ??
        _toDate(item['updatedAt']);
  }

  static List<RiskTrendPointViewData> _buildRiskTrend(
    List<Map<String, dynamic>> sorted,
  ) {
    if (sorted.isEmpty) {
      return const [
        RiskTrendPointViewData(month: 'Apr', value: 48),
        RiskTrendPointViewData(month: 'May', value: 44),
        RiskTrendPointViewData(month: 'Jun', value: 46),
        RiskTrendPointViewData(month: 'Jul', value: 39),
        RiskTrendPointViewData(month: 'Aug', value: 36),
        RiskTrendPointViewData(month: 'Sep', value: 32),
      ];
    }

    final recent = sorted.take(6).toList(growable: false).reversed;
    return recent
        .map((item) {
          final month = _formatMonth(_assessmentDate(item));
          final value = _toInt(item['riskScore']) ?? 0;
          return RiskTrendPointViewData(month: month, value: value);
        })
        .toList(growable: false);
  }

  static List<RiskContributionViewData> _buildContributions(
    bool analysisReady,
    Map<String, dynamic> analysis,
  ) {
    if (!analysisReady) {
      return const [
        RiskContributionViewData(label: 'Vitals', value: 32),
        RiskContributionViewData(label: 'Symptoms', value: 22),
        RiskContributionViewData(label: 'Records', value: 26),
        RiskContributionViewData(label: 'Imaging', value: 20),
      ];
    }

    final gaps = _asStringList(
      analysis['dataGaps'],
    ).map((e) => e.toLowerCase());
    final gapList = gaps.toList(growable: false);
    bool hasGap(String needle) =>
        gapList.any((gap) => gap.contains(needle.toLowerCase()));

    return [
      RiskContributionViewData(
        label: 'Vitals',
        value: hasGap('vitals') ? 12 : 32,
      ),
      RiskContributionViewData(
        label: 'Symptoms',
        value: hasGap('symptoms') ? 12 : 22,
      ),
      RiskContributionViewData(
        label: 'Records',
        value: hasGap('records') ? 12 : 26,
      ),
      RiskContributionViewData(
        label: 'Imaging',
        value: hasGap('imaging') ? 12 : 20,
      ),
    ];
  }

  static List<RiskSignalViewData> _buildKeySignals(
    Map<String, dynamic> analysis,
    List<HealthInsightEntity> insights,
  ) {
    final findingMaps = _asMapList(analysis['keyFindings']);
    if (findingMaps.isNotEmpty) {
      return findingMaps
          .take(4)
          .map((item) {
            return RiskSignalViewData(
              label: _stringOrNull(item['title']) ?? 'Key finding',
              value: _stringOrNull(item['detail']) ?? 'No detail provided.',
            );
          })
          .toList(growable: false);
    }

    if (insights.isNotEmpty) {
      return insights
          .take(4)
          .map((item) {
            final raw = item.data;
            return RiskSignalViewData(
              label: _stringOrNull(raw['insightTitle']) ?? 'Health insight',
              value: _stringOrNull(raw['description']) ?? 'No description.',
            );
          })
          .toList(growable: false);
    }

    return const [
      RiskSignalViewData(
        label: 'Glucose trend',
        value: 'Stable over last 6 logs',
      ),
      RiskSignalViewData(
        label: 'BP variability',
        value: 'Medium variance detected',
      ),
      RiskSignalViewData(
        label: 'Symptom clusters',
        value: 'Respiratory signals low',
      ),
      RiskSignalViewData(
        label: 'Recent records',
        value: '2 lab reports indexed',
      ),
    ];
  }

  static List<RiskInsightItemViewData> _mapInsights(
    List<HealthInsightEntity> insights,
  ) {
    return insights
        .map((item) {
          final raw = item.data;
          final priority = _normalizePriority(_stringOrNull(raw['priority']));
          return RiskInsightItemViewData(
            id: item.id,
            title: _stringOrNull(raw['insightTitle']) ?? 'Health insight',
            description: _stringOrNull(raw['description']) ?? 'No description',
            priority: priority,
          );
        })
        .toList(growable: false);
  }

  static List<RiskSectionViewData> _buildFullSections(
    Map<String, dynamic> analysis,
  ) {
    final sections = _asMap(analysis['sections']);
    if (sections.isEmpty) {
      return const [
        RiskSectionViewData(
          title: 'Vitals analysis',
          content: 'Run full analysis to see vitals interpretation.',
        ),
        RiskSectionViewData(
          title: 'Symptoms analysis',
          content: 'Run full analysis to see symptom interpretation.',
        ),
        RiskSectionViewData(
          title: 'Records analysis',
          content: 'Run full analysis to see record insights.',
        ),
        RiskSectionViewData(
          title: 'Medications analysis',
          content: 'Run full analysis to see medication insights.',
        ),
        RiskSectionViewData(
          title: 'Allergies analysis',
          content: 'Run full analysis to see allergy insights.',
        ),
        RiskSectionViewData(
          title: 'Immunizations analysis',
          content: 'Run full analysis to see immunization insights.',
        ),
      ];
    }

    String valueFor(String key, String fallback) =>
        _stringOrNull(sections[key]) ?? fallback;

    return [
      RiskSectionViewData(
        title: 'Vitals analysis',
        content: valueFor('vitals', 'No vitals insights available.'),
      ),
      RiskSectionViewData(
        title: 'Symptoms analysis',
        content: valueFor('symptoms', 'No symptom insights available.'),
      ),
      RiskSectionViewData(
        title: 'Records analysis',
        content: valueFor('records', 'No record insights available.'),
      ),
      RiskSectionViewData(
        title: 'Medications analysis',
        content: valueFor('medications', 'No medication insights available.'),
      ),
      RiskSectionViewData(
        title: 'Allergies analysis',
        content: valueFor('allergies', 'No allergy insights available.'),
      ),
      RiskSectionViewData(
        title: 'Immunizations analysis',
        content: valueFor(
          'immunizations',
          'No immunization insights available.',
        ),
      ),
    ];
  }

  static Map<String, dynamic> _asMap(dynamic raw) {
    if (raw is! Map) return const <String, dynamic>{};
    return raw.map((k, v) => MapEntry(k.toString(), v));
  }

  static List<Map<String, dynamic>> _asMapList(dynamic raw) {
    if (raw is! List) return const [];
    return raw
        .whereType<Map>()
        .map((item) => item.map((k, v) => MapEntry(k.toString(), v)))
        .toList(growable: false);
  }

  static List<String> _asStringList(dynamic raw) {
    if (raw is! List) return const [];
    return raw.map((item) => item.toString()).toList(growable: false);
  }

  static String _normalizeRiskLevel(String? riskLevel, {int? score}) {
    final raw = (riskLevel ?? '').toLowerCase().trim();
    if (raw == 'high') return 'High';
    if (raw == 'medium' || raw == 'moderate') return 'Medium';
    if (raw == 'low') return 'Low';
    if (score == null) return 'Medium';
    if (score >= 70) return 'High';
    if (score >= 40) return 'Medium';
    return 'Low';
  }

  static String _normalizePriority(String? priority) {
    final raw = (priority ?? '').toLowerCase().trim();
    if (raw == 'high') return 'High';
    if (raw == 'medium') return 'Medium';
    if (raw == 'low') return 'Low';
    return 'Info';
  }

  static int? _toInt(dynamic raw) {
    if (raw == null) return null;
    if (raw is int) return raw;
    if (raw is num) return raw.round();
    return int.tryParse(raw.toString());
  }

  static int? _confidenceToPercent(dynamic raw) {
    final value = _toDouble(raw);
    if (value == null) return null;
    if (value <= 1) return (value * 100).round();
    return value.round();
  }

  static double? _toDouble(dynamic raw) {
    if (raw == null) return null;
    if (raw is double) return raw;
    if (raw is num) return raw.toDouble();
    return double.tryParse(raw.toString());
  }

  static String? _stringOrNull(dynamic raw) {
    if (raw == null) return null;
    final value = raw.toString().trim();
    return value.isEmpty ? null : value;
  }

  static DateTime? _toDate(dynamic raw) {
    if (raw == null) return null;
    if (raw is DateTime) return raw;
    return DateTime.tryParse(raw.toString());
  }

  static String _formatDate(DateTime? date) {
    if (date == null) return '--';
    return '${date.month}/${date.day}/${date.year}';
  }

  static String _formatMonth(DateTime? date) {
    if (date == null) return '--';
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    return months[date.month - 1];
  }
}

class RiskSummaryTileViewData {
  final String label;
  final String value;
  final String detail;

  const RiskSummaryTileViewData({
    required this.label,
    required this.value,
    required this.detail,
  });
}

class RiskTrendPointViewData {
  final String month;
  final int value;

  const RiskTrendPointViewData({required this.month, required this.value});
}

class RiskContributionViewData {
  final String label;
  final int value;

  const RiskContributionViewData({required this.label, required this.value});
}

class RiskSignalViewData {
  final String label;
  final String value;

  const RiskSignalViewData({required this.label, required this.value});
}

class RiskInsightItemViewData {
  final String id;
  final String title;
  final String description;
  final String priority;

  const RiskInsightItemViewData({
    required this.id,
    required this.title,
    required this.description,
    required this.priority,
  });
}

class RiskSectionViewData {
  final String title;
  final String content;

  const RiskSectionViewData({required this.title, required this.content});
}
