import 'package:vaidya/features/symptoms/domain/entities/symptom_entity.dart';

class SymptomViewData {
  final String id;
  final List<String> symptomList;
  final String? severity;
  final String status;
  final int? durationDays;
  final String? diagnosis;
  final String? disease;
  final String? notes;
  final DateTime? loggedAt;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const SymptomViewData({
    required this.id,
    required this.symptomList,
    required this.status,
    this.severity,
    this.durationDays,
    this.diagnosis,
    this.disease,
    this.notes,
    this.loggedAt,
    this.createdAt,
    this.updatedAt,
  });

  factory SymptomViewData.fromEntity(SymptomEntity entity) {
    final raw = entity.data;

    List<String> parseSymptomList(dynamic value) {
      if (value is List) {
        return value
            .map((e) => e.toString().trim())
            .where((e) => e.isNotEmpty)
            .toList(growable: false);
      }
      if (value is String && value.trim().isNotEmpty) {
        return value
            .split(',')
            .map((e) => e.trim())
            .where((e) => e.isNotEmpty)
            .toList(growable: false);
      }
      return const [];
    }

    String? parseNonEmpty(dynamic value) {
      final text = value?.toString().trim() ?? '';
      return text.isEmpty ? null : text;
    }

    int? parseInt(dynamic value) {
      if (value is int) return value;
      if (value is double) return value.round();
      return int.tryParse(value?.toString() ?? '');
    }

    DateTime? parseDate(dynamic value) {
      final rawText = value?.toString().trim();
      if (rawText == null || rawText.isEmpty) return null;
      return DateTime.tryParse(rawText);
    }

    return SymptomViewData(
      id: (raw['_id'] ?? raw['id'] ?? entity.id).toString(),
      symptomList: parseSymptomList(raw['symptomList']),
      severity: parseNonEmpty(raw['severity']),
      status: _normalizeStatus(raw['status']?.toString()),
      durationDays: parseInt(raw['durationDays']),
      diagnosis: parseNonEmpty(raw['diagnosis']),
      disease: parseNonEmpty(raw['disease']),
      notes: parseNonEmpty(raw['notes']),
      loggedAt: parseDate(raw['loggedAt']),
      createdAt: parseDate(raw['createdAt']),
      updatedAt: parseDate(raw['updatedAt']),
    );
  }

  String get title =>
      symptomList.isNotEmpty ? symptomList.join(', ') : 'Unnamed symptom';

  String get statusLabel => _toHeadline(status);

  String? get severityLabel =>
      severity == null ? null : _toHeadline(severity!.toLowerCase());

  DateTime? get relevantDate => loggedAt ?? createdAt ?? updatedAt;

  String get primarySymptom =>
      symptomList.isNotEmpty ? symptomList.first : 'symptoms';

  bool get isOngoing => status == 'ongoing' || status == 'unknown';

  Map<String, dynamic> toPayload() {
    final payload = <String, dynamic>{
      'symptomList': symptomList,
      'status': status,
    };

    if (severity != null && severity!.trim().isNotEmpty) {
      payload['severity'] = _toHeadline(severity!.toLowerCase());
    }
    if (durationDays != null && durationDays! > 0) {
      payload['durationDays'] = durationDays;
    }
    if (diagnosis != null && diagnosis!.trim().isNotEmpty) {
      payload['diagnosis'] = diagnosis!.trim();
    }
    if (disease != null && disease!.trim().isNotEmpty) {
      payload['disease'] = disease!.trim();
    }
    if (notes != null && notes!.trim().isNotEmpty) {
      payload['notes'] = notes!.trim();
    }
    if (loggedAt != null) {
      payload['loggedAt'] = loggedAt!.toIso8601String();
    }

    return payload;
  }

  static String _normalizeStatus(String? value) {
    final normalized = value?.trim().toLowerCase() ?? '';
    switch (normalized) {
      case 'resolved':
        return 'resolved';
      case 'unknown':
        return 'unknown';
      case 'ongoing':
      default:
        return 'ongoing';
    }
  }

  static String _toHeadline(String value) {
    final parts = value
        .split(RegExp(r'[\s_-]+'))
        .map((e) => e.trim())
        .where((e) => e.isNotEmpty)
        .toList(growable: false);
    if (parts.isEmpty) return value;
    return parts
        .map(
          (part) =>
              '${part[0].toUpperCase()}${part.substring(1).toLowerCase()}',
        )
        .join(' ');
  }
}

class SymptomsOverviewStats {
  final int total;
  final int ongoing;
  final int severe;
  final int unique;

  const SymptomsOverviewStats({
    required this.total,
    required this.ongoing,
    required this.severe,
    required this.unique,
  });

  factory SymptomsOverviewStats.fromItems(List<SymptomViewData> items) {
    final normalized = items
        .expand((item) => item.symptomList.map((symptom) => symptom.trim()))
        .where((symptom) => symptom.isNotEmpty)
        .map((symptom) => symptom.toLowerCase())
        .toSet();

    final severeCount = items.where((item) {
      final severity = item.severity?.toLowerCase().trim();
      return severity == 'severe';
    }).length;

    return SymptomsOverviewStats(
      total: items.length,
      ongoing: items.where((item) => item.isOngoing).length,
      severe: severeCount,
      unique: normalized.length,
    );
  }
}

class SymptomFrequencyViewData {
  final String name;
  final int count;

  const SymptomFrequencyViewData({required this.name, required this.count});
}

List<SymptomFrequencyViewData> topSymptomFrequencies(
  List<SymptomViewData> items, {
  int limit = 5,
}) {
  final counts = <String, int>{};

  for (final item in items) {
    for (final symptom in item.symptomList) {
      final normalized = symptom.trim();
      if (normalized.isEmpty) continue;
      counts[normalized] = (counts[normalized] ?? 0) + 1;
    }
  }

  final sorted = counts.entries.toList(growable: false)
    ..sort((a, b) => b.value.compareTo(a.value));

  return sorted
      .take(limit)
      .map(
        (entry) =>
            SymptomFrequencyViewData(name: entry.key, count: entry.value),
      )
      .toList(growable: false);
}
