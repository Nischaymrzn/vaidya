import 'package:vaidya/features/vitals/domain/entities/vital_entity.dart';

class VitalsOverviewViewData {
  final List<VitalsSummaryCardViewData> cards;
  final List<VitalsTrendPointViewData> trend;
  final List<VitalRecordViewData> records;

  const VitalsOverviewViewData({
    this.cards = const [],
    this.trend = const [],
    this.records = const [],
  });

  factory VitalsOverviewViewData.fromSources({
    required VitalsSummaryEntity summary,
    required List<VitalEntity> items,
  }) {
    final data = summary.data;

    final cardsRaw = _asMapList(data['cards']);
    final cards = cardsRaw.map(VitalsSummaryCardViewData.fromMap).toList();

    final trendRaw = _asMapList(data['trend']);
    final trend = trendRaw.map(VitalsTrendPointViewData.fromMap).toList();

    final summaryRecordsRaw = _asMapList(data['records']);
    final itemsRecordsRaw = items
        .map((item) => item.data)
        .toList(growable: false);
    final recordSource = summaryRecordsRaw.isNotEmpty
        ? summaryRecordsRaw
        : itemsRecordsRaw;

    final records =
        recordSource.map(VitalRecordViewData.fromMap).toList(growable: false)
          ..sort((a, b) => b.sortTimestamp.compareTo(a.sortTimestamp));

    return VitalsOverviewViewData(cards: cards, trend: trend, records: records);
  }

  List<VitalsSummaryCardViewData> get topCards {
    const order = ['heartRate', 'bloodPressure', 'glucose'];
    final ordered = <VitalsSummaryCardViewData>[];

    for (final key in order) {
      final match = cardByKey(key);
      if (match != null) ordered.add(match);
    }

    return ordered;
  }

  VitalsSummaryCardViewData? cardByKey(String key) {
    for (final card in cards) {
      if (card.key == key) return card;
    }
    return null;
  }

  List<double> historyByKey(String key) {
    if (key == 'bmi') {
      return records
          .map((record) => record.bmi)
          .whereType<num>()
          .map((value) => value.toDouble())
          .toList(growable: false);
    }

    return trend
        .map((point) {
          switch (key) {
            case 'bloodPressure':
              return point.systolic;
            case 'glucose':
              return point.glucose;
            default:
              return point.heartRate;
          }
        })
        .whereType<double>()
        .toList(growable: false);
  }

  HeartRateStatsViewData get heartRateStats {
    final values = trend
        .map((point) => point.heartRate)
        .whereType<double>()
        .toList(growable: false);

    if (values.isEmpty) {
      return const HeartRateStatsViewData();
    }

    final sum = values.fold<double>(0, (acc, value) => acc + value);
    final avg = (sum / values.length).round();
    final min = values.reduce((a, b) => a < b ? a : b).round();
    final max = values.reduce((a, b) => a > b ? a : b).round();

    return HeartRateStatsViewData(avg: avg, min: min, max: max);
  }

  VitalsSummaryCardViewData? get highestRiskCard {
    final candidates = cards.where(
      (card) =>
          card.key == 'heartRate' ||
          card.key == 'bloodPressure' ||
          card.key == 'glucose',
    );

    if (candidates.isEmpty) return null;

    VitalsSummaryCardViewData? best;
    var bestPriority = -1;

    for (final card in candidates) {
      final priority = switch (card.status.toLowerCase()) {
        'high' => 4,
        'elevated' => 3,
        'borderline' => 3,
        'low' => 2,
        'normal' => 1,
        _ => 0,
      };

      if (priority > bestPriority) {
        bestPriority = priority;
        best = card;
      }
    }

    return best;
  }

  static List<Map<String, dynamic>> _asMapList(dynamic raw) {
    if (raw is! List) return const [];

    return raw
        .whereType<Map>()
        .map((item) => item.map((k, v) => MapEntry(k.toString(), v)))
        .toList(growable: false);
  }
}

class HeartRateStatsViewData {
  final int? avg;
  final int? min;
  final int? max;

  const HeartRateStatsViewData({this.avg, this.min, this.max});
}

class VitalsSummaryCardViewData {
  final String key;
  final String label;
  final String value;
  final String unit;
  final String status;
  final String delta;
  final DateTime? updatedAt;

  const VitalsSummaryCardViewData({
    required this.key,
    required this.label,
    required this.value,
    required this.unit,
    required this.status,
    required this.delta,
    required this.updatedAt,
  });

  factory VitalsSummaryCardViewData.fromMap(Map<String, dynamic> map) {
    return VitalsSummaryCardViewData(
      key: (map['key'] ?? '').toString(),
      label: (map['label'] ?? '--').toString(),
      value: (map['value'] ?? '--').toString(),
      unit: (map['unit'] ?? '').toString(),
      status: (map['status'] ?? 'No data').toString(),
      delta: (map['delta'] ?? 'No recent change').toString(),
      updatedAt: _toDateTime(map['updatedAt']),
    );
  }

  bool get hasData {
    final normalized = value.trim().toLowerCase();
    return normalized.isNotEmpty && normalized != 'n/a' && normalized != '--';
  }

  String get displayValue {
    if (!hasData) return '--';
    if (unit.trim().isEmpty) return value;

    final lower = value.toLowerCase();
    if (lower.contains(unit.toLowerCase())) {
      return value;
    }

    if (key == 'bloodPressure') {
      return value;
    }

    return '$value $unit';
  }

  String get detailCondition {
    final normalized = status.toLowerCase();
    if (normalized.contains('high') ||
        normalized.contains('elevated') ||
        normalized.contains('borderline')) {
      return 'high';
    }
    if (normalized.contains('low')) {
      return 'low';
    }
    return 'normal';
  }

  int get detailScorePercent {
    return switch (status.toLowerCase()) {
      'normal' => 78,
      'elevated' => 64,
      'borderline' => 55,
      'high' => 40,
      'low' => 45,
      _ => 0,
    };
  }

  static DateTime? _toDateTime(dynamic value) {
    if (value == null) return null;
    final date = DateTime.tryParse(value.toString());
    return date?.toLocal();
  }
}

class VitalsTrendPointViewData {
  final String label;
  final double? heartRate;
  final double? systolic;
  final double? glucose;

  const VitalsTrendPointViewData({
    required this.label,
    required this.heartRate,
    required this.systolic,
    required this.glucose,
  });

  factory VitalsTrendPointViewData.fromMap(Map<String, dynamic> map) {
    return VitalsTrendPointViewData(
      label: (map['label'] ?? '').toString(),
      heartRate: _toDouble(map['heartRate']),
      systolic: _toDouble(map['systolic']),
      glucose: _toDouble(map['glucose']),
    );
  }

  static double? _toDouble(dynamic raw) {
    if (raw == null) return null;
    if (raw is num) return raw.toDouble();
    return double.tryParse(raw.toString());
  }
}

class VitalRecordViewData {
  final String id;
  final num? heartRate;
  final num? systolicBp;
  final num? diastolicBp;
  final num? glucoseLevel;
  final num? weight;
  final num? height;
  final num? bmi;
  final String notes;
  final DateTime? recordedAt;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const VitalRecordViewData({
    required this.id,
    required this.heartRate,
    required this.systolicBp,
    required this.diastolicBp,
    required this.glucoseLevel,
    required this.weight,
    required this.height,
    required this.bmi,
    required this.notes,
    required this.recordedAt,
    required this.createdAt,
    required this.updatedAt,
  });

  factory VitalRecordViewData.fromMap(Map<String, dynamic> map) {
    return VitalRecordViewData(
      id: (map['_id'] ?? map['id'] ?? '').toString(),
      heartRate: _toNum(map['heartRate']),
      systolicBp: _toNum(map['systolicBp']),
      diastolicBp: _toNum(map['diastolicBp']),
      glucoseLevel: _toNum(map['glucoseLevel']),
      weight: _toNum(map['weight']),
      height: _toNum(map['height']),
      bmi: _toNum(map['bmi']),
      notes: (map['notes'] ?? '').toString(),
      recordedAt: _toDateTime(map['recordedAt']),
      createdAt: _toDateTime(map['createdAt']),
      updatedAt: _toDateTime(map['updatedAt']),
    );
  }

  DateTime? get displayDate => recordedAt ?? createdAt ?? updatedAt;

  int get sortTimestamp => displayDate?.millisecondsSinceEpoch ?? 0;

  String get bloodPressureValue {
    final systolic = _displayValue(systolicBp);
    final diastolic = _displayValue(diastolicBp);
    if (systolic == '--' && diastolic == '--') return '--/--';
    return '$systolic/$diastolic';
  }

  static num? _toNum(dynamic raw) {
    if (raw == null) return null;
    if (raw is num) return raw;
    return num.tryParse(raw.toString());
  }

  static DateTime? _toDateTime(dynamic value) {
    if (value == null) return null;
    final date = DateTime.tryParse(value.toString());
    return date?.toLocal();
  }

  static String _displayValue(num? value) {
    if (value == null) return '--';
    if (value % 1 == 0) return value.toInt().toString();
    return value.toStringAsFixed(1);
  }
}

String displayNum(num? value, {int fractionDigits = 0}) {
  if (value == null) return '--';
  if (fractionDigits <= 0 && value % 1 == 0) {
    return value.toInt().toString();
  }
  return value.toStringAsFixed(fractionDigits);
}
