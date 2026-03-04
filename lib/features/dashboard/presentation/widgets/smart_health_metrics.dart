import 'package:flutter/material.dart';
import 'package:vaidya/features/dashboard/domain/entities/dashboard_summary_entity.dart';
import 'package:vaidya/features/dashboard/presentation/widgets/metrics_card.dart';
import 'package:vaidya/themes/colors.dart';

class SmartHealthMetrics extends StatelessWidget {
  final List<DashboardVitalStatEntity> vitalStats;
  final List<DashboardRiskFactorEntity> riskFactors;
  final List<DashboardVitalPointEntity> vitalsData;

  const SmartHealthMetrics({
    super.key,
    required this.vitalStats,
    required this.riskFactors,
    required this.vitalsData,
  });

  @override
  Widget build(BuildContext context) {
    final heartRate = _metricData(
      key: 'heart rate',
      defaultName: 'Heart Rate',
      iconPath: 'assets/icons/heart_rate.svg',
      fallbackUnit: 'bpm',
      historySelector: (point) => point.heartRate,
    );

    final bloodPressure = _metricData(
      key: 'blood pressure',
      defaultName: 'Blood Pressure',
      iconPath: 'assets/icons/blood_pressure.svg',
      fallbackUnit: 'mmHg',
      historySelector: (point) => point.systolic,
    );

    final bloodSugar = _metricData(
      key: 'glucose',
      defaultName: 'Blood Sugar',
      iconPath: 'assets/icons/blood_sugar.svg',
      fallbackUnit: 'mg/dL',
      historySelector: (point) => point.glucose,
    );

    final bmi = _bmiMetricData();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Smart Health Metrics',
              style: TextStyle(
                fontSize: 20,
                color: AppColors.textPrimary,
                fontWeight: FontWeight.w500,
              ),
            ),
            Text(
              'View all',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: AppColors.primary.withValues(alpha: 0.85),
                fontWeight: FontWeight.w600,
                fontSize: 14,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        LayoutBuilder(
          builder: (context, constraints) {
            final crossAxisCount = constraints.maxWidth < 600 ? 2 : 4;

            return GridView.count(
              shrinkWrap: true,
              crossAxisCount: crossAxisCount,
              mainAxisSpacing: 10,
              crossAxisSpacing: 10,
              childAspectRatio: 166 / 139,
              physics: const NeverScrollableScrollPhysics(),
              children: [
                MetricsCard(
                  iconPath: heartRate.iconPath,
                  name: heartRate.name,
                  value: heartRate.value,
                  unit: heartRate.unit,
                  condition: heartRate.condition,
                  scorePercent: heartRate.scorePercent,
                  historyPoints: heartRate.historyPoints,
                ),
                MetricsCard(
                  iconPath: bloodPressure.iconPath,
                  name: bloodPressure.name,
                  value: bloodPressure.value,
                  unit: bloodPressure.unit,
                  condition: bloodPressure.condition,
                  scorePercent: bloodPressure.scorePercent,
                  historyPoints: bloodPressure.historyPoints,
                ),
                MetricsCard(
                  iconPath: bloodSugar.iconPath,
                  name: bloodSugar.name,
                  value: bloodSugar.value,
                  unit: bloodSugar.unit,
                  condition: bloodSugar.condition,
                  scorePercent: bloodSugar.scorePercent,
                  historyPoints: bloodSugar.historyPoints,
                ),
                MetricsCard(
                  iconPath: bmi.iconPath,
                  name: bmi.name,
                  value: bmi.value,
                  unit: bmi.unit,
                  condition: bmi.condition,
                  scorePercent: bmi.scorePercent,
                  historyPoints: bmi.historyPoints,
                ),
              ],
            );
          },
        ),
      ],
    );
  }

  _MetricCardData _metricData({
    required String key,
    required String defaultName,
    required String iconPath,
    required String fallbackUnit,
    required num? Function(DashboardVitalPointEntity point) historySelector,
  }) {
    final stat = vitalStats.firstWhere(
      (item) => item.label.toLowerCase().contains(key),
      orElse: () =>
          DashboardVitalStatEntity(label: defaultName, value: '--', note: ''),
    );

    final extracted = _extractValueAndUnit(
      stat.value,
      fallbackUnit: fallbackUnit,
      keepSlashValue: key == 'blood pressure',
    );

    final historyPoints = _extractHistory(historySelector);
    final averageValue = _average(historyPoints);
    final parsedValue = _firstNumeric(extracted.value);
    final valueForCondition = averageValue ?? parsedValue;

    final condition = _conditionForMetric(key, valueForCondition);
    final computedScore = _scoreFromAverage(
      key: key,
      averageValue: valueForCondition,
      fallbackCondition: condition,
    );

    return _MetricCardData(
      name: defaultName,
      iconPath: iconPath,
      value: extracted.value,
      unit: extracted.unit,
      condition: condition,
      scorePercent: computedScore,
      historyPoints: historyPoints,
    );
  }

  _MetricCardData _bmiMetricData() {
    final bmiRisk = riskFactors.firstWhere(
      (item) => item.label.toLowerCase().contains('bmi'),
      orElse: () => const DashboardRiskFactorEntity(
        label: 'BMI',
        level: 'Normal',
        score: 0,
      ),
    );

    final bmiStat = vitalStats.firstWhere(
      (item) => item.label.toLowerCase().contains('bmi'),
      orElse: () =>
          const DashboardVitalStatEntity(label: 'BMI', value: '--', note: ''),
    );

    final parsedBmi = _extractValueAndUnit(
      bmiStat.value,
      fallbackUnit: 'kg/m2',
    );
    final parsedBmiValue = _firstNumeric(parsedBmi.value);

    final value = parsedBmiValue != null
        ? parsedBmiValue.toStringAsFixed(parsedBmiValue % 1 == 0 ? 0 : 1)
        : (bmiRisk.score > 0 ? bmiRisk.score.toString() : '--');
    final condition = parsedBmiValue != null
        ? _conditionForMetric('bmi', parsedBmiValue)
        : _normalizeCondition(bmiRisk.level.isEmpty ? 'Normal' : bmiRisk.level);

    final scorePercent = parsedBmiValue != null
        ? _scoreFromAverage(
            key: 'bmi',
            averageValue: parsedBmiValue,
            fallbackCondition: condition,
          )
        : bmiRisk.score > 0
        ? (100 - bmiRisk.score).clamp(35, 95)
        : 72;

    return _MetricCardData(
      name: 'BMI',
      iconPath: 'assets/icons/bmi.svg',
      value: value,
      unit: 'kg/m2',
      condition: condition,
      scorePercent: scorePercent,
      historyPoints: parsedBmiValue != null ? [parsedBmiValue] : const [],
    );
  }

  List<double> _extractHistory(
    num? Function(DashboardVitalPointEntity point) selector,
  ) {
    return vitalsData
        .map(selector)
        .whereType<num>()
        .map((value) => value.toDouble())
        .toList();
  }

  _ParsedMetricValue _extractValueAndUnit(
    String raw, {
    required String fallbackUnit,
    bool keepSlashValue = false,
  }) {
    final value = raw.trim();
    if (value.isEmpty || value.toLowerCase() == 'n/a') {
      return _ParsedMetricValue(value: '--', unit: fallbackUnit);
    }

    if (keepSlashValue && value.contains('/')) {
      final cleaned = value.replaceAll(
        RegExp(r'\s*mmhg', caseSensitive: false),
        '',
      );
      return _ParsedMetricValue(value: cleaned.trim(), unit: fallbackUnit);
    }

    final regex = RegExp(r'^(-?\d+(?:\.\d+)?)\s*(.*)$');
    final match = regex.firstMatch(value);

    if (match == null) {
      return _ParsedMetricValue(value: value, unit: fallbackUnit);
    }

    final number = match.group(1) ?? '--';
    final unit = (match.group(2) ?? '').trim();
    return _ParsedMetricValue(
      value: number,
      unit: unit.isEmpty ? fallbackUnit : unit,
    );
  }

  String _conditionForMetric(String key, double? metricValue) {
    if (metricValue == null || !metricValue.isFinite) return 'Normal';

    if (key == 'heart rate') {
      if (metricValue < 60) return 'Low';
      if (metricValue > 100) return 'High';
      return 'Normal';
    }

    if (key == 'glucose') {
      if (metricValue < 70) return 'Low';
      if (metricValue > 140) return 'High';
      return 'Normal';
    }

    if (key == 'blood pressure') {
      if (metricValue < 90) return 'Low';
      if (metricValue > 130) return 'High';
      return 'Normal';
    }

    if (key == 'bmi') {
      if (metricValue < 18.5) return 'Low';
      if (metricValue > 24.9) return 'High';
      return 'Normal';
    }

    return 'Normal';
  }

  String _normalizeCondition(String input) {
    final value = input.toLowerCase();
    if (value.contains('low')) return 'Low';
    if (value.contains('high')) return 'High';
    return 'Normal';
  }

  int _scoreFromCondition(String condition, {required int fallback}) {
    switch (condition.toLowerCase()) {
      case 'normal':
        return 78;
      case 'high':
        return 64;
      case 'low':
        return 60;
      default:
        return fallback;
    }
  }

  double? _average(List<double> values) {
    if (values.isEmpty) return null;
    final sum = values.fold<double>(0, (acc, value) => acc + value);
    return sum / values.length;
  }

  double? _firstNumeric(String text) {
    final value = RegExp(r'-?\d+(?:\.\d+)?').firstMatch(text)?.group(0);
    return value == null ? null : double.tryParse(value);
  }

  int _scoreFromAverage({
    required String key,
    required double? averageValue,
    required String fallbackCondition,
  }) {
    if (averageValue == null || !averageValue.isFinite) {
      return _scoreFromCondition(fallbackCondition, fallback: 70);
    }

    final range = _idealRangeForMetric(key);
    if (range == null) {
      return _scoreFromCondition(fallbackCondition, fallback: 70);
    }

    final min = range.$1;
    final max = range.$2;
    final midpoint = (min + max) / 2;
    final halfRange = (max - min) / 2;

    if (averageValue >= min && averageValue <= max) {
      final centerDistance = (averageValue - midpoint).abs() / halfRange;
      final score = 90 - (centerDistance * 20);
      return score.round().clamp(70, 95);
    }

    final edgeDistance = averageValue < min
        ? (min - averageValue)
        : (averageValue - max);
    final penaltyFactor = edgeDistance / halfRange;
    final score = 70 - (penaltyFactor * 40);
    return score.round().clamp(25, 69);
  }

  (double, double)? _idealRangeForMetric(String key) {
    switch (key) {
      case 'heart rate':
        return (60, 100);
      case 'blood pressure':
        return (90, 130);
      case 'glucose':
        return (70, 140);
      case 'bmi':
        return (18.5, 24.9);
      default:
        return null;
    }
  }
}

class _ParsedMetricValue {
  final String value;
  final String unit;

  _ParsedMetricValue({required this.value, required this.unit});
}

class _MetricCardData {
  final String iconPath;
  final String name;
  final String value;
  final String unit;
  final String condition;
  final int scorePercent;
  final List<double> historyPoints;

  _MetricCardData({
    required this.iconPath,
    required this.name,
    required this.value,
    required this.unit,
    required this.condition,
    required this.scorePercent,
    required this.historyPoints,
  });
}
