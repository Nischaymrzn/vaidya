import 'package:equatable/equatable.dart';

enum FamilyMemberStatus { stable, warning, critical }

class FamilyStatusStyle extends Equatable {
  final String label;
  final int backgroundHex;
  final int textHex;

  const FamilyStatusStyle({
    required this.label,
    required this.backgroundHex,
    required this.textHex,
  });

  static FamilyStatusStyle fromStatus(FamilyMemberStatus status) {
    switch (status) {
      case FamilyMemberStatus.stable:
        return const FamilyStatusStyle(
          label: 'Stable',
          backgroundHex: 0xFFEAF3FF,
          textHex: 0xFF1F7AE0,
        );
      case FamilyMemberStatus.warning:
        return const FamilyStatusStyle(
          label: 'Watch',
          backgroundHex: 0xFFFFF8E8,
          textHex: 0xFF9A6700,
        );
      case FamilyMemberStatus.critical:
        return const FamilyStatusStyle(
          label: 'Critical',
          backgroundHex: 0xFFFEE2E2,
          textHex: 0xFFDC2626,
        );
    }
  }

  @override
  List<Object?> get props => [label, backgroundHex, textHex];
}

class FamilyVitalsViewData extends Equatable {
  final DateTime? recordedAt;
  final num? systolicBp;
  final num? diastolicBp;
  final num? glucoseLevel;
  final num? heartRate;
  final num? weight;
  final num? height;
  final num? bmi;

  const FamilyVitalsViewData({
    this.recordedAt,
    this.systolicBp,
    this.diastolicBp,
    this.glucoseLevel,
    this.heartRate,
    this.weight,
    this.height,
    this.bmi,
  });

  factory FamilyVitalsViewData.fromMap(Map<String, dynamic> map) {
    return FamilyVitalsViewData(
      recordedAt: _parseDate(map['recordedAt'] ?? map['createdAt']),
      systolicBp: _parseNum(map['systolicBp']),
      diastolicBp: _parseNum(map['diastolicBp']),
      glucoseLevel: _parseNum(map['glucoseLevel']),
      heartRate: _parseNum(map['heartRate']),
      weight: _parseNum(map['weight']),
      height: _parseNum(map['height']),
      bmi: _parseNum(map['bmi']),
    );
  }

  String get bloodPressure {
    if (systolicBp == null || diastolicBp == null) return '--';
    return '${systolicBp!.round()}/${diastolicBp!.round()}';
  }

  @override
  List<Object?> get props => [
    recordedAt,
    systolicBp,
    diastolicBp,
    glucoseLevel,
    heartRate,
    weight,
    height,
    bmi,
  ];
}

class FamilyMemberViewData extends Equatable {
  final String userId;
  final String role;
  final String name;
  final String? email;
  final String? relation;
  final DateTime? joinedAt;
  final int? age;
  final String? gender;
  final FamilyVitalsViewData? latestVitals;
  final List<FamilyVitalsViewData> recentVitals;
  final DateTime? lastUpdated;
  final int? healthScore;
  final FamilyMemberStatus status;

  const FamilyMemberViewData({
    required this.userId,
    required this.role,
    required this.name,
    this.email,
    this.relation,
    this.joinedAt,
    this.age,
    this.gender,
    this.latestVitals,
    this.recentVitals = const [],
    this.lastUpdated,
    this.healthScore,
    this.status = FamilyMemberStatus.warning,
  });

  factory FamilyMemberViewData.fromMap(Map<String, dynamic> map) {
    final latestVitalsMap = _asMap(map['latestVitals']);
    final recent = _asList(map['recentVitals'])
        .map(_asMap)
        .whereType<Map<String, dynamic>>()
        .map(FamilyVitalsViewData.fromMap)
        .toList(growable: false);

    return FamilyMemberViewData(
      userId: (map['userId'] ?? '').toString(),
      role: (map['role'] ?? 'member').toString(),
      name: _safeName((map['name'] ?? map['user']?['name'])?.toString()),
      email: map['email']?.toString() ?? map['user']?['email']?.toString(),
      relation: map['relation']?.toString(),
      joinedAt: _parseDate(map['joinedAt']),
      age: _parseInt(map['age']),
      gender: map['gender']?.toString(),
      latestVitals: latestVitalsMap == null
          ? null
          : FamilyVitalsViewData.fromMap(latestVitalsMap),
      recentVitals: recent,
      lastUpdated: _parseDate(map['lastUpdated']),
      healthScore: _parseInt(map['healthScore']),
      status: _parseStatus(map['status']?.toString()),
    );
  }

  FamilyStatusStyle get statusStyle => FamilyStatusStyle.fromStatus(status);

  String get initials {
    final parts = name
        .split(' ')
        .where((element) => element.trim().isNotEmpty)
        .toList(growable: false);
    if (parts.isEmpty) return 'M';
    if (parts.length == 1) {
      return parts.first.substring(0, 1).toUpperCase();
    }
    return (parts[0].substring(0, 1) + parts[1].substring(0, 1)).toUpperCase();
  }

  String relationLabel({required String? currentUserId}) {
    if (currentUserId != null && currentUserId == userId) return 'Self';
    final raw = relation?.trim() ?? '';
    if (raw.isEmpty) return 'Member';
    if (raw.toLowerCase() == 'self') return 'Admin';
    return _titleCase(raw);
  }

  String get displayName => _titleCase(name);

  String get vitalsSummary {
    final vitals =
        latestVitals ?? (recentVitals.isNotEmpty ? recentVitals.first : null);
    if (vitals == null) return 'BP -- | HR -- | Glucose --';
    final bp = vitals.bloodPressure;
    final hr = vitals.heartRate?.round().toString() ?? '--';
    final glucose = vitals.glucoseLevel?.round().toString() ?? '--';
    return 'BP $bp | HR $hr | Glucose $glucose';
  }

  @override
  List<Object?> get props => [
    userId,
    role,
    name,
    email,
    relation,
    joinedAt,
    age,
    gender,
    latestVitals,
    recentVitals,
    lastUpdated,
    healthScore,
    status,
  ];
}

class FamilyInsightViewData extends Equatable {
  final String title;
  final String detail;

  const FamilyInsightViewData({required this.title, required this.detail});

  @override
  List<Object?> get props => [title, detail];
}

class FamilySummaryViewData extends Equatable {
  final String groupId;
  final String groupName;
  final String adminId;
  final int? familyScore;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final String? currentUserId;
  final String currentUserRole;
  final String? currentUserRelation;
  final List<FamilyMemberViewData> members;

  const FamilySummaryViewData({
    this.groupId = '',
    this.groupName = 'Family Health',
    this.adminId = '',
    this.familyScore,
    this.createdAt,
    this.updatedAt,
    this.currentUserId,
    this.currentUserRole = 'member',
    this.currentUserRelation,
    this.members = const [],
  });

  bool get hasGroup => groupId.isNotEmpty;
  bool get isAdmin => currentUserRole.toLowerCase() == 'admin';

  int get totalMembers => members.length;

  int get stableCount => members
      .where((element) => element.status == FamilyMemberStatus.stable)
      .length;

  int get watchCount => members
      .where((element) => element.status == FamilyMemberStatus.warning)
      .length;

  int get criticalCount => members
      .where((element) => element.status == FamilyMemberStatus.critical)
      .length;

  int get averageHealthScore {
    if (familyScore != null) return familyScore!;
    final scores = members
        .map((member) => member.healthScore)
        .whereType<int>()
        .toList(growable: false);
    if (scores.isEmpty) return 0;
    final sum = scores.fold<int>(0, (value, element) => value + element);
    return (sum / scores.length).round();
  }

  FamilyMemberViewData? resolveMember(String? memberId) {
    if (members.isEmpty) return null;
    if (memberId != null && memberId.trim().isNotEmpty) {
      final found = members
          .where((member) => member.userId == memberId)
          .toList();
      if (found.isNotEmpty) return found.first;
    }
    if (currentUserId != null) {
      final mine = members
          .where((member) => member.userId == currentUserId)
          .toList();
      if (mine.isNotEmpty) return mine.first;
    }
    return members.first;
  }

  String get title {
    final cleanName = groupName.trim();
    if (cleanName.isNotEmpty && cleanName.toLowerCase() != 'family health') {
      return cleanName;
    }

    final self = resolveMember(currentUserId);
    final nameParts = self?.displayName.split(' ') ?? const <String>[];
    if (nameParts.length >= 2) {
      return '${nameParts.last} Family';
    }
    return 'Family Health';
  }

  int get averageHeartRate {
    final values = members
        .map((member) => member.latestVitals?.heartRate)
        .whereType<num>()
        .map((value) => value.toDouble())
        .toList(growable: false);
    if (values.isEmpty) return 0;
    final sum = values.fold<double>(0, (a, b) => a + b);
    return (sum / values.length).round();
  }

  List<FamilyInsightViewData> get insights {
    final missingVitals = members
        .where(
          (member) =>
              member.latestVitals == null && member.recentVitals.isEmpty,
        )
        .length;
    final critical = criticalCount;
    final output = <FamilyInsightViewData>[];

    if (critical > 0) {
      output.add(
        FamilyInsightViewData(
          title: 'Critical attention',
          detail: '$critical member(s) need immediate review.',
        ),
      );
    }

    if (missingVitals > 0) {
      output.add(
        FamilyInsightViewData(
          title: 'Missing vitals',
          detail: '$missingVitals member(s) have no recent vitals on file.',
        ),
      );
    }

    output.add(
      FamilyInsightViewData(
        title: 'Family stability',
        detail: 'Average health score is $averageHealthScore.',
      ),
    );

    return output.take(3).toList(growable: false);
  }

  factory FamilySummaryViewData.fromMaps({
    required Map<String, dynamic> summaryData,
    Map<String, dynamic>? groupData,
  }) {
    final groupMap =
        _asMap(summaryData['group']) ?? groupData ?? <String, dynamic>{};
    final currentUserMap =
        _asMap(summaryData['currentUser']) ?? <String, dynamic>{};
    final membersRaw = _asList(summaryData['members']);
    final parsedMembers = membersRaw
        .map(_asMap)
        .whereType<Map<String, dynamic>>()
        .map(FamilyMemberViewData.fromMap)
        .where((member) => member.userId.trim().isNotEmpty)
        .toList(growable: false);

    return FamilySummaryViewData(
      groupId: (groupMap['_id'] ?? groupMap['id'] ?? '').toString(),
      groupName: (groupMap['name'] ?? 'Family Health').toString(),
      adminId: (groupMap['adminId'] ?? '').toString(),
      familyScore: _parseInt(summaryData['familyScore'] ?? groupMap['score']),
      createdAt: _parseDate(groupMap['createdAt']),
      updatedAt: _parseDate(groupMap['updatedAt']),
      currentUserId: (currentUserMap['id'] ?? '').toString().trim().isEmpty
          ? null
          : currentUserMap['id'].toString(),
      currentUserRole: (currentUserMap['role'] ?? 'member').toString(),
      currentUserRelation: currentUserMap['relation']?.toString(),
      members: parsedMembers,
    );
  }

  @override
  List<Object?> get props => [
    groupId,
    groupName,
    adminId,
    familyScore,
    createdAt,
    updatedAt,
    currentUserId,
    currentUserRole,
    currentUserRelation,
    members,
  ];
}

Map<String, dynamic>? _asMap(dynamic value) {
  if (value is Map<String, dynamic>) return value;
  if (value is Map) {
    return value.map((key, element) => MapEntry(key.toString(), element));
  }
  return null;
}

List<dynamic> _asList(dynamic value) {
  if (value is List<dynamic>) return value;
  if (value is List) return value.cast<dynamic>();
  return const <dynamic>[];
}

DateTime? _parseDate(dynamic value) {
  if (value == null) return null;
  if (value is DateTime) return value;
  return DateTime.tryParse(value.toString());
}

num? _parseNum(dynamic value) {
  if (value == null) return null;
  if (value is num) return value;
  return num.tryParse(value.toString());
}

int? _parseInt(dynamic value) {
  if (value == null) return null;
  if (value is int) return value;
  if (value is num) return value.round();
  return int.tryParse(value.toString());
}

FamilyMemberStatus _parseStatus(String? value) {
  switch ((value ?? '').trim().toLowerCase()) {
    case 'stable':
      return FamilyMemberStatus.stable;
    case 'critical':
      return FamilyMemberStatus.critical;
    case 'warning':
    default:
      return FamilyMemberStatus.warning;
  }
}

String _titleCase(String value) {
  final clean = value.trim();
  if (clean.isEmpty) return 'Member';
  return clean
      .split(' ')
      .where((part) => part.trim().isNotEmpty)
      .map((part) {
        final head = part.substring(0, 1).toUpperCase();
        final tail = part.length > 1 ? part.substring(1).toLowerCase() : '';
        return '$head$tail';
      })
      .join(' ');
}

String _safeName(String? value) {
  final clean = value?.trim() ?? '';
  if (clean.isEmpty) return 'Member';
  return clean;
}
