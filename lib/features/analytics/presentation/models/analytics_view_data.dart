import 'dart:math' as math;

import 'package:vaidya/features/analytics/domain/entities/analytics_summary_entity.dart';

class AnalyticsViewData {
  final AnalyticsDateRangeViewData dateRange;
  final AnalyticsSummaryStatsViewData summary;
  final AnalyticsEncounterTotalsViewData encounterTotals;
  final List<AnalyticsEncounterPointViewData> encounterHistory;
  final List<AnalyticsSeverityPointViewData> allergySeverity;
  final List<AnalyticsCategoryCountViewData> topConditions;
  final List<AnalyticsCategoryCountViewData> procedureBreakdown;
  final List<AnalyticsMedicationHistoryPointViewData> medicationHistory;
  final List<AnalyticsImmunizationHistoryPointViewData> immunizationHistory;
  final AnalyticsProviderNetworkViewData providerNetwork;

  const AnalyticsViewData({
    required this.dateRange,
    required this.summary,
    required this.encounterTotals,
    required this.encounterHistory,
    required this.allergySeverity,
    required this.topConditions,
    required this.procedureBreakdown,
    required this.medicationHistory,
    required this.immunizationHistory,
    required this.providerNetwork,
  });

  factory AnalyticsViewData.fromEntity(AnalyticsSummaryEntity entity) {
    return AnalyticsViewData.fromMap(entity.data);
  }

  factory AnalyticsViewData.fromMap(Map<String, dynamic> json) {
    final dateRangeMap = _toMap(json['dateRange']);
    final summaryMap = _toMap(json['summary']);
    final noteMap = _toMap(summaryMap['notes']);
    final encounterTotalsMap = _toMap(json['encounterTotals']);
    final providerNetworkMap = _toMap(json['providerNetwork']);

    return AnalyticsViewData(
      dateRange: AnalyticsDateRangeViewData(
        start: _parseDate(dateRangeMap['start']),
        end: _parseDate(dateRangeMap['end']),
        months: _toInt(dateRangeMap['months']),
      ),
      summary: AnalyticsSummaryStatsViewData(
        activeConditions: _toInt(summaryMap['activeConditions']),
        activeMedications: _toInt(summaryMap['activeMedications']),
        encounters: _toInt(summaryMap['encounters']),
        immunizations: _toInt(summaryMap['immunizations']),
        recentConditions: _toInt(noteMap['recentConditions']),
        medicationChanges: _toInt(noteMap['medicationChanges']),
        telehealthVisits: _toInt(noteMap['telehealthVisits']),
        boostersDue: _toInt(noteMap['boostersDue']),
      ),
      encounterTotals: AnalyticsEncounterTotalsViewData(
        outpatient: _toInt(encounterTotalsMap['outpatient']),
        telehealth: _toInt(encounterTotalsMap['telehealth']),
        inpatient: _toInt(encounterTotalsMap['inpatient']),
      ),
      encounterHistory: _toListMap(json['encounterHistory'])
          .map(
            (item) => AnalyticsEncounterPointViewData(
              month: _toString(item['month']),
              outpatient: _toInt(item['outpatient']),
              telehealth: _toInt(item['telehealth']),
              inpatient: _toInt(item['inpatient']),
            ),
          )
          .toList(growable: false),
      allergySeverity: _toListMap(json['allergySeverity'])
          .map(
            (item) => AnalyticsSeverityPointViewData(
              name: _toString(item['name']),
              value: _toInt(item['value']),
            ),
          )
          .toList(growable: false),
      topConditions: _toListMap(json['topConditions'])
          .map(
            (item) => AnalyticsCategoryCountViewData(
              name: _toString(item['name']),
              count: _toInt(item['count']),
            ),
          )
          .toList(growable: false),
      procedureBreakdown: _toListMap(json['procedureBreakdown'])
          .map(
            (item) => AnalyticsCategoryCountViewData(
              name: _toString(item['name']),
              count: _toInt(item['count']),
            ),
          )
          .toList(growable: false),
      medicationHistory: _toListMap(json['medicationHistory'])
          .map(
            (item) => AnalyticsMedicationHistoryPointViewData(
              month: _toString(item['month']),
              active: _toInt(item['active']),
              newCount: _toInt(item['new']),
              stopped: _toInt(item['stopped']),
            ),
          )
          .toList(growable: false),
      immunizationHistory: _toListMap(json['immunizationHistory'])
          .map(
            (item) => AnalyticsImmunizationHistoryPointViewData(
              month: _toString(item['month']),
              routine: _toInt(item['routine']),
              booster: _toInt(item['booster']),
              travel: _toInt(item['travel']),
            ),
          )
          .toList(growable: false),
      providerNetwork: AnalyticsProviderNetworkViewData(
        activeProviders: _toInt(providerNetworkMap['activeProviders']),
        referralsYtd: _toInt(providerNetworkMap['referralsYtd']),
        careTouchpoints: _toInt(providerNetworkMap['careTouchpoints']),
        topProviders: _toListMap(providerNetworkMap['topProviders'])
            .map(
              (item) => AnalyticsTopProviderViewData(
                name: _toString(item['name']),
                count: _toInt(item['count']),
              ),
            )
            .where((item) => item.name.isNotEmpty)
            .toList(growable: false),
      ),
    );
  }

  List<AnalyticsSummaryCardViewData> get summaryCards {
    return [
      AnalyticsSummaryCardViewData(
        label: 'ACTIVE CONDITIONS',
        value: summary.activeConditions,
        detail: summary.recentConditions > 0
            ? '${summary.recentConditions} added in last 90 days'
            : 'No new conditions in last 90 days',
      ),
      AnalyticsSummaryCardViewData(
        label: 'ACTIVE MEDICATIONS',
        value: summary.activeMedications,
        detail: summary.medicationChanges > 0
            ? '${summary.medicationChanges} changes in last 90 days'
            : 'No recent medication changes',
      ),
      AnalyticsSummaryCardViewData(
        label: 'ENCOUNTERS',
        value: summary.encounters,
        detail: summary.telehealthVisits > 0
            ? '${summary.telehealthVisits} telehealth visits logged'
            : 'No telehealth visits logged',
      ),
      AnalyticsSummaryCardViewData(
        label: 'IMMUNIZATIONS',
        value: summary.immunizations,
        detail: summary.boostersDue > 0
            ? '${summary.boostersDue} boosters due soon'
            : 'No boosters due soon',
      ),
    ];
  }

  bool get hasEncounterData {
    return encounterHistory.any(
      (item) =>
          item.outpatient > 0 || item.telehealth > 0 || item.inpatient > 0,
    );
  }

  bool get hasAllergyData => allergySeverity.any((item) => item.value > 0);

  bool get hasConditionsData => topConditions.isNotEmpty;

  bool get hasProcedureData => procedureBreakdown.any((item) => item.count > 0);

  bool get hasMedicationData {
    return medicationHistory.any(
      (item) => item.active > 0 || item.newCount > 0 || item.stopped > 0,
    );
  }

  bool get hasImmunizationData {
    return immunizationHistory.any(
      (item) => item.routine > 0 || item.booster > 0 || item.travel > 0,
    );
  }

  bool get hasProviderData => providerNetwork.topProviders.isNotEmpty;
}

class AnalyticsDateRangeViewData {
  final DateTime? start;
  final DateTime? end;
  final int months;

  const AnalyticsDateRangeViewData({
    required this.start,
    required this.end,
    required this.months,
  });
}

class AnalyticsSummaryStatsViewData {
  final int activeConditions;
  final int activeMedications;
  final int encounters;
  final int immunizations;
  final int recentConditions;
  final int medicationChanges;
  final int telehealthVisits;
  final int boostersDue;

  const AnalyticsSummaryStatsViewData({
    required this.activeConditions,
    required this.activeMedications,
    required this.encounters,
    required this.immunizations,
    required this.recentConditions,
    required this.medicationChanges,
    required this.telehealthVisits,
    required this.boostersDue,
  });
}

class AnalyticsSummaryCardViewData {
  final String label;
  final int value;
  final String detail;

  const AnalyticsSummaryCardViewData({
    required this.label,
    required this.value,
    required this.detail,
  });
}

class AnalyticsEncounterTotalsViewData {
  final int outpatient;
  final int telehealth;
  final int inpatient;

  const AnalyticsEncounterTotalsViewData({
    required this.outpatient,
    required this.telehealth,
    required this.inpatient,
  });
}

class AnalyticsEncounterPointViewData {
  final String month;
  final int outpatient;
  final int telehealth;
  final int inpatient;

  const AnalyticsEncounterPointViewData({
    required this.month,
    required this.outpatient,
    required this.telehealth,
    required this.inpatient,
  });

  int get total => outpatient + telehealth + inpatient;
}

class AnalyticsSeverityPointViewData {
  final String name;
  final int value;

  const AnalyticsSeverityPointViewData({
    required this.name,
    required this.value,
  });
}

class AnalyticsCategoryCountViewData {
  final String name;
  final int count;

  const AnalyticsCategoryCountViewData({
    required this.name,
    required this.count,
  });
}

class AnalyticsMedicationHistoryPointViewData {
  final String month;
  final int active;
  final int newCount;
  final int stopped;

  const AnalyticsMedicationHistoryPointViewData({
    required this.month,
    required this.active,
    required this.newCount,
    required this.stopped,
  });

  int get total => active + newCount + stopped;
}

class AnalyticsImmunizationHistoryPointViewData {
  final String month;
  final int routine;
  final int booster;
  final int travel;

  const AnalyticsImmunizationHistoryPointViewData({
    required this.month,
    required this.routine,
    required this.booster,
    required this.travel,
  });

  int get total => routine + booster + travel;
}

class AnalyticsProviderNetworkViewData {
  final int activeProviders;
  final int referralsYtd;
  final int careTouchpoints;
  final List<AnalyticsTopProviderViewData> topProviders;

  const AnalyticsProviderNetworkViewData({
    required this.activeProviders,
    required this.referralsYtd,
    required this.careTouchpoints,
    required this.topProviders,
  });
}

class AnalyticsTopProviderViewData {
  final String name;
  final int count;

  const AnalyticsTopProviderViewData({required this.name, required this.count});
}

int _toInt(dynamic value) {
  if (value is int) return value;
  if (value is num) return value.toInt();
  if (value is String) return int.tryParse(value.trim()) ?? 0;
  return 0;
}

String _toString(dynamic value) {
  if (value == null) return '';
  return value.toString().trim();
}

DateTime? _parseDate(dynamic value) {
  final raw = _toString(value);
  if (raw.isEmpty) return null;
  return DateTime.tryParse(raw);
}

Map<String, dynamic> _toMap(dynamic value) {
  if (value is Map<String, dynamic>) return value;
  if (value is Map) {
    return value.map((key, val) => MapEntry(key.toString(), val));
  }
  return const <String, dynamic>{};
}

List<Map<String, dynamic>> _toListMap(dynamic value) {
  if (value is! List) return const <Map<String, dynamic>>[];
  return value.map(_toMap).toList(growable: false);
}

double _safeDiv(num a, num b) {
  if (b == 0) return 0;
  return a / b;
}

double ratioFromCount(int count, int maxCount) {
  return _safeDiv(count, math.max(maxCount, 1)).clamp(0.0, 1.0);
}
